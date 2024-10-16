# Running ES, Kibana and Fleet server in docker-compose

## Intro
This setup runs ES, Kibana and Fleet server in docker-compose, is suitable for full on-prem stack PoCs where a single server install with ES, Kibana and Fleet server is enough, but will have all the enterprise features enabled (including Kibana Alerting) with a trial license automatically turned on.

## Feature List:
* Use `.env` file to manage the server config items, to be rendered in docker-compose
* Auto-generate self-signed certificates for es, kib and fleet, eg: the internal resolvable dns name for ES is https://es01:9200
* Config GUI (https://localhost:5601/app/fleet/agents) with full security turned on that supports Kibana alerts. 
* When starting docker-compose, it will gradually start ES with Kibana, then will bring up Fleet server and register it with Kibana. 

## Quick Test

All variables got pre-defined values, so simply follow below steps to test the Role by Ansible playbook. Or find below section `Detailed Setup` for more information.

1. Download the repo and go with main branch, start DevContainer
1. At root folder, spin up the ELK stack ``` docker compose up -d```
1. Login Kibana UI via https://localhost:5601, user/password: elastic/elastic
1. Check the new agent added to the fleet via the Kib UI
1. Goto ansible folder, test the role with command 
```
pip install -r requirements.txt
ansible-playbook -i inventory.yml playbook.yml -v
```

## Detailed Setup
The current setup is specifying ES and Fleet server endpoints as `localhost`. It is possible to change it to the real hostname of the server in the `.env` file.

```bash
# Externally accessible URLs of ES and Fleet servers
FLEET_HOST=https://localhost:8220
ES_HOST=https://localhost:9200
```

## Running it
To start the whole stack:
```bash
docker-compose up -d
```
Output:
```bash
Creating network "docker-compose_default" with the default driver
Creating volume "docker-compose_certs" with local driver
Creating docker-compose_setup_1 ... done
Creating docker-compose_es01_1  ... done
Creating docker-compose_kib01_1 ... done
Creating fleet                  ... done
```
## Validate the services
Once the stack is up, validate the following services and connections
* Attach to the Fleet container
```
docker exec -it fleet bash
```
* Inside the fleet container run below command line
```
curl -s --cacert config/certs/ca/ca.crt https://es01:9200
```
You should see the message like below which shows ES is working.
```
root@6c5b8e6af16d:/usr/share/elastic-agent# curl -s --cacert config/certs/ca/ca.crt https://es01:9200
{"error":{"root_cause":[{"type":"security_exception","reason":"missing authentication credentials for REST request [/]","header":{"WWW-Authenticate":["Basic realm=\"security\", charset=\"UTF-8\"","Bearer realm=\"security\"","ApiKey"]}}],"type":"security_exception","reason":"missing authentication credentials for REST request [/]","header":{"WWW-Authenticate":["Basic realm=\"security\", charset=\"UTF-8\"","Bearer realm=\"security\"","ApiKey"]}},"status":401}root@6c5b8e6af16d:/usr/share/elastic-agent#

```
* Kibana GUI: log into Kibana (https://localhost:5601 by default) with the credentials specified in the `.env` file (elastic:elastic is the default). 
* Add Agent via GUI: Under `Add Agent` flyout in Fleet UI, use the provided commands to install and enroll the agent, but add the `--insecure` flag to the command. Change the Fleet server url, if needed.


## Add agent to the fleet

You can spin up a new container by adding the config in the docker compose file, eg: ubuntu-agent, debian-agent, install curl command if needed troubleshooting.
```bash
docker exec -it ubuntu-agent bash

apt update
apt install -y curl jq

export KIBANA_HOST="https://kib01:5601"
export FLEET_HOST="https://fleet:8220"
export ELASTIC_PASSWORD="your_elastic_password_here"
export STACK_VERSION=8.15.2
export ES_PORT=9200
export KIBANA_PORT=5601
export FLEET_PORT=8220

export ENROLLMENT_TOKEN=your_enrollment_token_here

curl -s -X GET "${KIBANA_HOST}/api/fleet/enrollment-api-keys" \
     -H 'kbn-xsrf: true' \
     -u elastic:${ELASTIC_PASSWORD} \
     -k

#!/bin/bash

# Set your variables


# Fetch all enrollment tokens
echo "Fetching enrollment tokens..."
ENROLLMENT_TOKENS=$(curl -s -X GET "${KIBANA_HOST}/api/fleet/enrollment-api-keys" \
     -H 'kbn-xsrf: true' \
     -u elastic:${ELASTIC_PASSWORD} \
     -k)

# Display all tokens
echo "All Enrollment Tokens:"
echo "${ENROLLMENT_TOKENS}" | jq -r '.list[] | "Policy: \(.policy_id), Name: \(.name), Token: \(.api_key)"'

# Extract the agent policy token (not the fleet-server-policy)
AGENT_TOKEN=$(echo "${ENROLLMENT_TOKENS}" | jq -r '.list[] | select(.policy_id != "fleet-server-policy") | .api_key')

if [ -n "${AGENT_TOKEN}" ]; then
    echo "Agent Enrollment Token: ${AGENT_TOKEN}"
    export ENROLLMENT_TOKEN="${AGENT_TOKEN}"
else
    echo "Agent token not found. Please check the tokens in the Fleet UI."
fi

# Extract the fleet server policy token
FLEET_SERVER_TOKEN=$(echo "${ENROLLMENT_TOKENS}" | jq -r '.list[] | select(.policy_id == "fleet-server-policy") | .api_key')

if [ -n "${FLEET_SERVER_TOKEN}" ]; then
    echo "Fleet Server Enrollment Token: ${FLEET_SERVER_TOKEN}"
    export FLEET_SERVER_ENROLLMENT_TOKEN="${FLEET_SERVER_TOKEN}"
else
    echo "Fleet server token not found. Please check the tokens in the Fleet UI."
fi     

# For Linux TAR
mkdir -p /ubuntu-agent
cd /ubuntu-agent
curl -L -O https://artifacts.elastic.co/downloads/beats/elastic-agent/elastic-agent-${STACK_VERSION}-linux-x86_64.tar.gz
tar xzvf elastic-agent-${STACK_VERSION}-linux-x86_64.tar.gz
cd elastic-agent-${STACK_VERSION}-linux-x86_64
./elastic-agent install --url=${FLEET_HOST} --enrollment-token=${ENROLLMENT_TOKEN}

# For Debian, the install will throw error so use entrol instead
if ! ./elastic-agent enroll \
    --url="${FLEET_HOST}" \
    --enrollment-token="${ENROLLMENT_TOKEN}" \
    --insecure \
    --v \
    --force; then
    echo "ERROR: Failed to install Elastic Agent."
    # echo "Starting Elastic Agent manually..."
    # ./elastic-agent run &
else
    echo "Elastic Agent installed successfully."
fi


# For Debian, you could use the deb package as below, but it's recommended using the above TAR format which supports upgrade via the console.
curl -L -O https://artifacts.elastic.co/downloads/beats/elastic-agent/elastic-agent-${STACK_VERSION}-amd64.deb
sudo dpkg -i elastic-agent-${STACK_VERSION}-amd64.deb
sudo elastic-agent enroll --url=${FLEET_HOST} --enrollment-token=${ENROLLMENT_TOKEN}
sudo systemctl enable elastic-agent 
sudo systemctl start elastic-agent
```
Output:
```bash
Elastic Agent will be installed at /Library/Elastic/Agent and will run as a service. Do you want to continue? [Y/n]:
{"log.level":"warn","@timestamp":"2022-08-13T12:29:16.034+1000","log.logger":"tls","log.origin":{"file.name":"tlscommon/tls_config.go","file.line":104},"message":"SSL/TLS verifications disabled.","ecs.version":"1.6.0"}
{"log.level":"info","@timestamp":"2022-08-13T12:29:16.550+1000","log.origin":{"file.name":"cmd/enroll_cmd.go","file.line":471},"message":"Starting enrollment to URL: https://localhost:8220/","ecs.version":"1.6.0"}
{"log.level":"warn","@timestamp":"2022-08-13T12:29:16.664+1000","log.logger":"tls","log.origin":{"file.name":"tlscommon/tls_config.go","file.line":104},"message":"SSL/TLS verifications disabled.","ecs.version":"1.6.0"}
{"log.level":"info","@timestamp":"2022-08-13T12:29:17.500+1000","log.origin":{"file.name":"cmd/enroll_cmd.go","file.line":273},"message":"Successfully triggered restart on running Elastic Agent.","ecs.version":"1.6.0"}
Successfully enrolled the Elastic Agent.
Elastic Agent has been successfully installed.
```