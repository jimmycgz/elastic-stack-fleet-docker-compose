#!/bin/bash

# Exit on any error
set -e

# Enable debug output
set -x

# Wait for certificates and elasticsearch
until [ -f /usr/share/kibana/config/certs/kibana/kibana.crt ] && \
      curl -s --cacert /usr/share/kibana/config/certs/ca/ca.crt https://elasticsearch:9200 | grep -q "missing authentication credentials"; do
    echo "Waiting for certificates and elasticsearch..."
    sleep 5
done

# Source environment variables
ENV_FILE="/usr/share/kibana/pre-stack/es-agent/.env"
if [ -f "$ENV_FILE" ]; then
    echo "Sourcing environment file: $ENV_FILE"
    source "$ENV_FILE"
else
    echo "Warning: Environment file not found"
    export ELASTIC_PASSWORD=${ELASTIC_PASSWORD:-elastic}
    export KIBANA_PASSWORD=${KIBANA_PASSWORD:-elastic}
fi

# Create Kibana configuration
cat > /usr/share/kibana/config/kibana.yml << EOL
server.host: "0.0.0.0"
server.name: kibana
server.ssl.enabled: true
server.ssl.certificate: /usr/share/kibana/config/certs/kibana/kibana.crt
server.ssl.key: /usr/share/kibana/config/certs/kibana/kibana.key
elasticsearch.hosts: ["https://elasticsearch:9200"]
elasticsearch.username: "kibana_system"
elasticsearch.password: "${KIBANA_PASSWORD}"
elasticsearch.ssl.certificateAuthorities: ["/usr/share/kibana/config/certs/ca/ca.crt"]
elasticsearch.ssl.verificationMode: certificate
xpack.encryptedSavedObjects.encryptionKey: "abc45678901234567890123456789012"
xpack.fleet.enabled: true
xpack.fleet.agents.enabled: true
xpack.fleet.agents.fleet_server.hosts: ["https://fleet-server:8220"]
xpack.actions.preconfiguredAlertHistoryESIndex: true
xpack.security.encryptionKey: "${KIBANA_PASSWORD}"
xpack.reporting.encryptionKey: "${KIBANA_PASSWORD}"
EOL

# Replace environment variables in config
envsubst < /usr/share/kibana/config/kibana.yml > /usr/share/kibana/config/kibana.yml.tmp && \
mv /usr/share/kibana/config/kibana.yml.tmp /usr/share/kibana/config/kibana.yml

# Start Kibana
exec /usr/local/bin/kibana-docker