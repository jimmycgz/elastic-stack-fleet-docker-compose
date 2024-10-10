#!/bin/bash

set -eo pipefail

echo "Starting Elastic Agent setup..."

# Check for required environment variables
if [ -z "$KIBANA_FLEET_HOST" ] || [ -z "$FLEET_HOST" ] || [ -z "$ELASTIC_PASSWORD" ] || [ -z "$STACK_VERSION" ]; then
    echo "ERROR: Required environment variables are not set."
    echo "Please set KIBANA_FLEET_HOST, FLEET_HOST, ELASTIC_PASSWORD, and STACK_VERSION."
    exit 1
fi

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
else
    OS=$(uname -s)
    VER=$(uname -r)
fi
echo "Detected OS: $OS $VER"

# Install dependencies
echo "Installing dependencies..."
apt-get update && apt-get install -y curl jq

# Fetch enrollment tokens
echo "Fetching enrollment tokens..."
ENROLLMENT_TOKENS=$(curl -s -X GET "${KIBANA_FLEET_HOST}/api/fleet/enrollment-api-keys" \
     -H "kbn-xsrf: true" \
     -u elastic:${ELASTIC_PASSWORD} \
     -k)

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to fetch enrollment tokens. Please check your Kibana Fleet host and credentials."
    exit 1
fi

# Parse agent token
echo "Parsing agent token..."
AGENT_TOKEN=$(echo "${ENROLLMENT_TOKENS}" | jq -r '.list[] | select(.policy_id != "fleet-server-policy" and (.name | type=="string") and (.name | contains("Default"))) | .api_key' | head -n1)

# If no default is there, we would get any non fleet server policy
if [ -z "$AGENT_TOKEN" ]; then
    AGENT_TOKEN=$(echo "${ENROLLMENT_TOKENS}" | jq -r '.list[] | select(.policy_id != "fleet-server-policy") | .api_key' | head -n1)
fi

if [ -z "$AGENT_TOKEN" ]; then
    echo "No suitable agent token found. Creating a new one..."
    
    # Check for default policy
    DEFAULT_POLICY_ID=$(curl -s -X GET "${KIBANA_FLEET_HOST}/api/fleet/agent_policies" \
         -H "kbn-xsrf: true" \
         -u elastic:${ELASTIC_PASSWORD} \
         -k | jq -r '.items[] | select(.is_default == true) | .id')
    
    if [ -z "${DEFAULT_POLICY_ID}" ]; then
        echo "No default policy found. Creating a new policy..."
        NEW_POLICY_RESPONSE=$(curl -s -X POST "${KIBANA_FLEET_HOST}/api/fleet/agent_policies" \
             -H "kbn-xsrf: true" \
             -H "Content-Type: application/json" \
             -u elastic:${ELASTIC_PASSWORD} \
             -k \
             -d '{"name":"Default Policy","namespace":"default","description":"Default policy created by setup script","monitoring_enabled":["logs","metrics"]}')
        
        DEFAULT_POLICY_ID=$(echo "${NEW_POLICY_RESPONSE}" | jq -r '.item.id')
        
        if [ -z "${DEFAULT_POLICY_ID}" ]; then
            echo "ERROR: Failed to create new policy. Response: ${NEW_POLICY_RESPONSE}"
            exit 1
        fi
        echo "Created new policy with ID: ${DEFAULT_POLICY_ID}"
    fi
    
    echo "Creating new enrollment token for policy ${DEFAULT_POLICY_ID}"
    NEW_TOKEN_RESPONSE=$(curl -s -X POST "${KIBANA_FLEET_HOST}/api/fleet/enrollment-api-keys" \
         -H "kbn-xsrf: true" \
         -H "Content-Type: application/json" \
         -u elastic:${ELASTIC_PASSWORD} \
         -k \
         -d "{\"policy_id\": \"${DEFAULT_POLICY_ID}\"}")
    
    AGENT_TOKEN=$(echo "${NEW_TOKEN_RESPONSE}" | jq -r '.item.api_key')
    
    if [ -z "${AGENT_TOKEN}" ]; then
        echo "ERROR: Failed to create new enrollment token. Response: ${NEW_TOKEN_RESPONSE}"
        exit 1
    fi
fi

echo "Agent Enrollment Token: ${AGENT_TOKEN}"
export ENROLLMENT_TOKEN="${AGENT_TOKEN}"

echo "Removing any existing Elastic Agent installation..."
if [ -d "/opt/Elastic/Agent" ]; then
    rm -rf /opt/Elastic/Agent
fi

# need to add error handling

# Download and install Elastic Agent
echo "Downloading Elastic Agent..."
if ! curl -L -O "https://artifacts.elastic.co/downloads/beats/elastic-agent/elastic-agent-${STACK_VERSION}-linux-x86_64.tar.gz"; then
    echo "ERROR: Failed to download Elastic Agent."
    exit 1
fi

echo "Extracting Elastic Agent..."
if ! tar xzvf "elastic-agent-${STACK_VERSION}-linux-x86_64.tar.gz"; then
    echo "ERROR: Failed to extract Elastic Agent."
    exit 1
fi

echo "Renaming Elastic Agent folder..."
mkdir -p /opt/Elastic
mv elastic-agent-${STACK_VERSION}-linux-x86_64 /opt/Elastic/Agent
if [ ! -d "/opt/Elastic/Agent" ]; then
    echo "ERROR: Failed to rename Elastic Agent folder."
    exit 1
fi

echo "Creating elastic-agent.yml file"
cd "/opt/Elastic/Agent"
cat > elastic-agent.yml << EOL
outputs:
  default:
    type: elasticsearch
    hosts: 
      - ${ELASTICSEARCH_HOST}
    username: ${ELASTICSEARCH_USERNAME}
    password: ${ELASTIC_PASSWORD}
    ssl.certificate_authorities: 
      - /usr/share/elastic-agent/config/certs/ca/ca.crt

agent:
  logging:
    to_files: true
    files:
      path: /var/log/elastic-agent
      name: elastic-agent.log
      keepfiles: 7
      permissions: 0644
  download:
    sourceuri: "https://artifacts.elastic.co/downloads/"
  ssl.ca_cert: /usr/share/elastic-agent/config/certs/ca/ca.crt

providers:
  provider:
    type: "fleet"
    url: "${FLEET_HOST}"
    insecure: true
    poll_timeout: 1m
EOL

echo "Installing Elastic Agent..."
if ! ./elastic-agent install \
    --url="${FLEET_HOST}" \
    --enrollment-token="${ENROLLMENT_TOKEN}" \
    --insecure \
    --non-interactive \
    --v \
    --force; then
    echo "ERROR: Failed to install Elastic Agent."
    echo "Starting Elastic Agent manually..."
    tail -f /var/log/elastic-agent.log
    exit 1
fi

echo "Elastic Agent installed successfully."

# Clean up
echo "Cleaning up..."
cd ..
rm -rf "elastic-agent-${STACK_VERSION}-linux-x86_64" "elastic-agent-${STACK_VERSION}-linux-x86_64.tar.gz"

echo "Elastic Agent setup completed successfully."

echo "Starting Elastic Agent manually..."
/opt/Elastic/Agent/elastic-agent run &

# Keep the script running to keep the container alive
tail -f /var/log/elastic-agent.log

# Function to check if Elastic Agent is running
is_agent_running() {
    pgrep -f "/opt/Elastic/Agent/elastic-agent" > /dev/null
}

# Keep the container running and restart Elastic Agent if it stops
echo "Entering main loop to keep container running and monitor Elastic Agent..."
while true; do
    if ! is_agent_running; then
        echo "Elastic Agent is not running. Attempting to restart..."
        /opt/Elastic/Agent/elastic-agent run &
    fi
    sleep 60
done
