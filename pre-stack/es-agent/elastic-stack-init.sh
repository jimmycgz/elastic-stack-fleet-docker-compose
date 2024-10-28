#!/bin/bash

# Exit on any error
set -e

# Enable debug output
set -x

# Error handling function
handle_error() {
    local exit_code=$?
    local line_number=$1
    echo "Error: Command failed at line $line_number with exit code $exit_code"
    exit $exit_code
}

# Set up error trap
trap 'handle_error ${LINENO}' ERR

# Initialize environment variables
init_environment() {
    echo "Initializing environment..."
    if [ ! -f /usr/share/elasticsearch/pre-stack/.env ]; then
        echo "Error: .env file not found at /usr/share/elasticsearch/pre-stack/.env"
        ls -la /usr/share/elasticsearch/pre-stack/
        return 1
    fi

    source /usr/share/elasticsearch/pre-stack/.env
    echo "Starting setup with ELASTIC_PASSWORD=$ELASTIC_PASSWORD"

    # Validate required environment variables
    if [ -z "$ELASTIC_PASSWORD" ]; then
        echo "Error: ELASTIC_PASSWORD is not set in .env file"
        return 1
    fi

    if [ -z "$KIBANA_PASSWORD" ]; then
        echo "Error: KIBANA_PASSWORD is not set in .env file"
        return 1
    fi
}

# Generate CA certificate
generate_ca() {
    echo "Generating CA certificate..."
    mkdir -p config/certs
    if [ ! -f config/certs/ca.zip ]; then
        if ! bin/elasticsearch-certutil ca --silent --pem -out config/certs/ca.zip; then
            echo "Error: Failed to generate CA certificate"
            return 1
        fi
        if ! unzip config/certs/ca.zip -d config/certs; then
            echo "Error: Failed to unzip CA certificate"
            return 1
        fi
    else
        echo "CA certificate already exists"
    fi
}

# Generate certificates for services
generate_certificates() {
    echo "Generating certificates for services..."
    if [ ! -f config/certs/certs.zip ]; then
        # Create instances configuration
        if ! cat > config/certs/instances.yml << 'EOF'
instances:
  - name: elasticsearch
    dns:
      - elasticsearch
      - localhost
    ip:
      - 127.0.0.1
  - name: kibana
    dns:
      - kibana
      - localhost
    ip:
      - 127.0.0.1
  - name: fleet-server
    dns:
      - fleet-server
      - localhost
    ip:
      - 127.0.0.1
EOF
        then
            echo "Error: Failed to create instances configuration"
            return 1
        fi

        # Generate certificates
        if ! bin/elasticsearch-certutil cert --silent --pem \
            -out config/certs/certs.zip \
            --in config/certs/instances.yml \
            --ca-cert config/certs/ca/ca.crt \
            --ca-key config/certs/ca/ca.key; then
            echo "Error: Failed to generate service certificates"
            return 1
        fi

        if ! unzip config/certs/certs.zip -d config/certs; then
            echo "Error: Failed to unzip service certificates"
            return 1
        fi


        # Add explicit touch of a flag file after setup is complete
        sleep 5
        touch /usr/share/elasticsearch/config/certs/setup.complete

    else
        echo "Service certificates already exist"
    fi
}

# Set proper file permissions
set_permissions() {
    echo "Setting file permissions..."
    if ! chown -R root:root config/certs || ! find config/certs -type d -exec chmod 750 {} \; || ! find config/certs -type f -exec chmod 640 {} \;; then
        echo "Error: Failed to set file permissions"
        return 1
    fi
}

# Wait for Elasticsearch to be available
wait_for_elasticsearch() {
    echo "Waiting for Elasticsearch availability..."
    local max_attempts=30
    local attempt=1

    while [ $attempt -le $max_attempts ]; do
        if curl -s --cacert /usr/share/elasticsearch/config/certs/ca/ca.crt https://elasticsearch:9200 | grep -q "missing authentication credentials"; then
            echo "Elasticsearch is available"
            return 0
        fi
        echo "Attempt $attempt/$max_attempts: Elasticsearch is not ready - waiting..."
        sleep 30
        attempt=$((attempt + 1))
    done

    echo "Error: Elasticsearch did not become available after $max_attempts attempts"
    return 1
}

# Configure Kibana user password
configure_kibana_password() {
    echo "Configuring kibana_system password..."
    local max_attempts=30
    local attempt=1

    while [ $attempt -le $max_attempts ]; do
        local response
        response=$(curl -v -X POST \
            --cacert /usr/share/elasticsearch/config/certs/ca/ca.crt \
            -u "elastic:${ELASTIC_PASSWORD}" \
            -H "Content-Type: application/json" \
            -w "\n%{http_code}" \
            --silent \
            https://elasticsearch:9200/_security/user/kibana_system/_password \
            -d "{\"password\":\"${KIBANA_PASSWORD}\"}" 2>&1)
        
        local status_code
        status_code=$(echo "$response" | tail -n1)
        local curl_exit=$?

        if [ $curl_exit -ne 0 ]; then
            echo "Attempt $attempt/$max_attempts: Curl command failed with exit code $curl_exit"
            echo "Response: $response"
        else
            case $status_code in
                200)
                    echo "Successfully set kibana_system password"
                    return 0
                    ;;
                401)
                    echo "Attempt $attempt/$max_attempts: Authentication failed. Check ELASTIC_PASSWORD"
                    ;;
                404)
                    echo "Attempt $attempt/$max_attempts: Elasticsearch endpoint not found"
                    ;;
                *)
                    echo "Attempt $attempt/$max_attempts: Received status code: $status_code"
                    echo "Response: $response"
                    ;;
            esac
        fi

        if [ $attempt -eq $max_attempts ]; then
            echo "Error: Failed to set kibana_system password after $max_attempts attempts"
            return 1
        fi
        echo "Retrying in 10s..."
        sleep 10
        attempt=$((attempt + 1))
    done
}

# Main execution
main() {
    local step
    for step in init_environment generate_ca generate_certificates set_permissions wait_for_elasticsearch configure_kibana_password; do
        echo "Executing step: $step"
        if ! $step; then
            echo "Error: Step '$step' failed"
            return 1
        fi
    done
    echo "Setup completed successfully!"
    return 0
}

# Execute main function
main "$@"
exit $?
