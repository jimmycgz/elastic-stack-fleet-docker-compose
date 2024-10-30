## Install Gcloud

# Install prerequisites
apt-get update && apt-get install -y apt-transport-https ca-certificates gnupg curl

# Add the gcloud repo and key
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

# Install gcloud
apt-get update && apt-get install -y google-cloud-sdk

# Verify installation
gcloud --version

# Copy certs to local 
 dk cp instance:/usr/share/elasticsearch/config/certs $HOME/es-agent/certs

# Test Variable config for molecule.yml
```
# molecule/default/molecule.yml
---
dependency:
  name: galaxy

driver:
  name: docker

platforms:
  - name: test-instance
    image: ubuntu:22.04
    pre_build_image: true
    # Let's try different env methods to see which ones work
    docker_args:
      - "--env=TEST1=fromargs"
    docker_env:
      - "TEST2=fromenv"
    environment:
      TEST3: "fromenvkey"
    env:
      TEST4: "fromplainenv"

provisioner:
  name: ansible

verifier:
  name: ansible

scenarios:
  - name: default
```


# Test fleet config by docker
docker run -d \
  --name fleet-server \
  --platform linux/amd64 \
  -p 8220:8220 \
  -v $HOME/es-agent/certs:/usr/share/elastic-agent/config/certs \
  --network elastic \
  docker.elastic.co/beats/elastic-agent:8.15.2 \
  elastic-agent container \
  FLEET_SERVER_ENABLE=1 \
  FLEET_SERVER_ELASTICSEARCH_HOST=https://elasticsearch:9200 \
  FLEET_SERVER_ELASTICSEARCH_CA=/usr/share/elastic-agent/config/certs/ca/ca.crt \
  FLEET_SERVER_CERT=/usr/share/elastic-agent/config/certs/fleet-server/fleet-server.crt \
  FLEET_SERVER_CERT_KEY=/usr/share/elastic-agent/config/certs/fleet-server/fleet-server.key \
  FLEET_SERVER_HOST=0.0.0.0 \
  FLEET_SERVER_PORT=8220 \
  FLEET_SERVER_POLICY_ID=fleet-server-policy \
  FLEET_ENROLL=1 \
  ELASTICSEARCH_USERNAME=elastic \
  ELASTICSEARCH_PASSWORD=elastic \
  KIBANA_FLEET_HOST=https://kibana:5601 \
  KIBANA_FLEET_USERNAME=elastic \
  KIBANA_FLEET_PASSWORD=elastic \
  KIBANA_FLEET_CA=/usr/share/elastic-agent/config/certs/ca/ca.crt \
  FLEET_URL=https://fleet-server:8220