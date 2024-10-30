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
# ENV_FILE="/usr/share/kibana/pre-stack/es-agent/.env"
# if [ -f "$ENV_FILE" ]; then
#     echo "Sourcing environment file: $ENV_FILE"
#     source "$ENV_FILE"
# else
#     echo "Warning: Environment file not found, using defaults"
# fi

# Debug: Print all environment variables
env | sort

cp /usr/share/kibana/pre-stack/es-agent/kibana.yml /usr/share/kibana/config/

# Start Kibana
exec /usr/local/bin/kibana-docker