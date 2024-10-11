cat <<EOF > rendered_config.yml
outputs:
  default:
    type: elasticsearch
    hosts: ["${ELASTICSEARCH_HOST}"]
    username: "${ELASTICSEARCH_USERNAME}"
    password: "${ELASTIC_PASSWORD}"
    ssl.certificate_authorities: 
      - ${CA_CERT_PATH}

agent:
  logging:
    level: ${LOG_LEVEL:-debug}
    to_files: true
    files:
      path: ${ELASTIC_AGENT_PATH}/logs
  ssl.ca_cert: ${CA_CERT_PATH}

fleet:
  enabled: true
  access_api_key: "${FLEET_ACCESS_API_KEY}"
  host: "${FLEET_HOST}"
  insecure: ${FLEET_INSECURE:-true}

providers:
  provider:
    type: "fleet"
    url: "${FLEET_HOST}"
    insecure: ${FLEET_INSECURE:-true}
    poll_timeout: ${FLEET_POLL_TIMEOUT:-1m}
EOF