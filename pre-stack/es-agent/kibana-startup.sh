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

# Source environment file if exists
ENV_FILE="/usr/share/kibana/pre-stack/es-agent/.env"
if [ -f "$ENV_FILE" ]; then
    echo "Sourcing environment file: $ENV_FILE"
    source "$ENV_FILE"
else
    echo "Warning: Environment file not found, using defaults"
fi

# Set all necessary environment variables with defaults
export SERVER_HOST=0.0.0.0
export SERVER_NAME=kibana
export SERVER_PUBLICBASEURL=https://localhost:5601

# SSL Configuration
export SERVER_SSL_ENABLED=true
export SERVER_SSL_CERTIFICATE=/usr/share/kibana/config/certs/kibana/kibana.crt
export SERVER_SSL_KEY=/usr/share/kibana/config/certs/kibana/kibana.key
export SERVER_SSL_CERTIFICATEAUTHORITIES=/usr/share/kibana/config/certs/ca/ca.crt

# Elasticsearch Configuration
export ELASTICSEARCH_HOSTS=https://elasticsearch:9200
export ELASTICSEARCH_USERNAME=kibana_system
export ELASTICSEARCH_PASSWORD=${KIBANA_PASSWORD:-elastic}
export ELASTICSEARCH_SSL_CERTIFICATEAUTHORITIES=/usr/share/kibana/config/certs/ca/ca.crt
export ELASTICSEARCH_SSL_VERIFICATIONMODE=certificate

# Security Keys - using consistent 32-char keys
ENCRYPTION_KEY=xkb123456789012345678901234567890
export XPACK_SECURITY_ENCRYPTIONKEY=$ENCRYPTION_KEY
export XPACK_ENCRYPTEDSAVEDOBJECTS_ENCRYPTIONKEY=$ENCRYPTION_KEY
export XPACK_REPORTING_ENCRYPTIONKEY=$ENCRYPTION_KEY

# Fleet Configuration
export XPACK_FLEET_ENABLED=true
export XPACK_FLEET_AGENTS_ENABLED=true
export FLEET_SERVER_HOST=${FLEET_HOST:-https://fleet-server:8220}
# Properly format the fleet server hosts array
export XPACK_FLEET_AGENTS_FLEET_SERVER_HOSTS="[\"$FLEET_SERVER_HOST\"]"

export KIBANA_FLEET_SETUP=1
export KIBANA_FLEET_HOST=https://kibana:5601
export KIBANA_FLEET_USERNAME=kibana_system
export KIBANA_FLEET_PASSWORD=${KIBANA_PASSWORD:-elastic}
export KIBANA_FLEET_CA=/usr/share/kibana/config/certs/ca/ca.crt

# Additional Settings
export XPACK_SECURITY_LOGINASSISTANCEMESSAGE="Default credentials: elastic / elastic"
export XPACK_SECURITY_SESSION_IDLETIMEOUT=1h
export TELEMETRY_ENABLED=false
export XPACK_REPORTING_CSV_MAXSIZEBYTES=10485760

# Debug: Print all environment variables
env | sort

# Start Kibana
exec /usr/local/bin/kibana-docker