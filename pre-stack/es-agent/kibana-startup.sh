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

# Set environment variables for Kibana
export SERVERNAME=kibana
export ELASTICSEARCH_HOSTS=https://elasticsearch:9200
export ELASTICSEARCH_USERNAME=kibana_system
export ELASTICSEARCH_PASSWORD=${KIBANA_PASSWORD}
export ELASTICSEARCH_SSL_CERTIFICATEAUTHORITIES=config/certs/ca/ca.crt
export SERVER_SSL_ENABLED=true
export SERVER_SSL_KEY=config/certs/kibana/kibana.key
export SERVER_SSL_CERTIFICATE=config/certs/kibana/kibana.crt
export XPACK_ENCRYPTEDSAVEDOBJECTS_ENCRYPTIONKEY=abc45678901234567890123456789012
export XPACK_ACTIONS_PRECONFIGUREDALERTHISTORYESINDEX=true

export KIBANA_FLEET_SETUP=1
export KIBANA_FLEET_HOST=https://kibana:5601
export KIBANA_FLEET_USERNAME=kibana_system
export KIBANA_FLEET_PASSWORD=${KIBANA_PASSWORD}
export KIBANA_FLEET_CA=/usr/share/kibana/config/certs/ca/ca.crt

export XPACK_FLEET_ENABLED=true
export XPACK_FLEET_AGENTS_ENABLED=true
export XPACK_FLEET_AGENTS_FLEET_SERVER_HOSTS=["${FLEET_HOST:-https://fleet-server:8220}"]
export ES_URL=${ES_URL:-https://elasticsearch:9200}

# Copy base configuration if it exists
if [ -f /usr/share/kibana/pre-stack/es-agent/kibana.yml ]; then
    cp /usr/share/kibana/pre-stack/es-agent/kibana.yml /usr/share/kibana/config/kibana.yml
fi

# Start Kibana
exec /usr/local/bin/kibana-docker