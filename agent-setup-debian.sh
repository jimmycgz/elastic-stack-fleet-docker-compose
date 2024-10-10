#!/bin/bash

set -eo pipefail

echo "Starting Elastic Agent setup..."

# Check for required environment variables
if [ -z "$KIBANA_FLEET_HOST" ] || [ -z "$FLEET_HOST" ] || [ -z "$ELASTIC_PASSWORD" ] || [ -z "$STACK_VERSION" ]; then
    echo "ERROR: Required environment variables are not set."
    echo "Please set KIBANA_FLEET_HOST, FLEET_HOST, ELASTIC_PASSWORD, and STACK_VERSION."
    exit 1
fi

# Install dependencies
echo "Installing dependencies..."
apt-get update && apt-get install -y curl jq procps

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
AGENT_TOKEN=$(echo "${ENROLLMENT_TOKENS}" | jq -r '.list[] | select(.policy_id != "fleet-server-policy") | .api_key' | head -n1)

if [ -z "$AGENT_TOKEN" ]; then
    echo "No suitable agent token found. Creating a new one..."
    
    # Check for default policy
    DEFAULT_POLICY_ID=$(curl -s -X GET "${KIBANA_FLEET_HOST}/api/fleet/agent_policies" \
         -H "kbn-xsrf: true" \
         -u elastic:${ELASTIC_PASSWORD} \
         -k | jq -r '.items[] | select(.is_default_fleet_server == false) | .id')
    
    if [ -z "${DEFAULT_POLICY_ID}" ]; then
        echo "No default agent policy found. Creating a new policy..."
        NEW_POLICY_RESPONSE=$(curl -s -X POST "${KIBANA_FLEET_HOST}/api/fleet/agent_policies" \
             -H "kbn-xsrf: true" \
             -H "Content-Type: application/json" \
             -u elastic:${ELASTIC_PASSWORD} \
             -k \
             -d '{"name":"Default Agent Policy","namespace":"default","description":"Default policy created by setup script","monitoring_enabled":["logs","metrics"]}')
        
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

# Download and extract Elastic Agent
echo "Downloading Elastic Agent..."
curl -L -o elastic-agent.tar.gz "https://artifacts.elastic.co/downloads/beats/elastic-agent/elastic-agent-${STACK_VERSION}-linux-x86_64.tar.gz"
tar xzvf elastic-agent.tar.gz
cd elastic-agent-${STACK_VERSION}-linux-x86_64

# Enroll the agent
echo "Enrolling Elastic Agent..."
./elastic-agent enroll --url="${FLEET_HOST}" --enrollment-token="${AGENT_TOKEN}" --insecure --force -f

# Check if enrollment was successful
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to enroll Elastic Agent."
    exit 1
fi

echo "Elastic Agent enrolled successfully."

# Start the Elastic Agent
echo "Starting Elastic Agent..."
./elastic-agent run -e &
AGENT_PID=$!

# Wait for the agent to start
echo "Waiting for Elastic Agent to start..."
sleep 30

# Check if the agent is running
if ! ps -p $AGENT_PID > /dev/null; then
    echo "ERROR: Elastic Agent failed to start."
    echo "Elastic Agent logs:"
    cat elastic-agent.log
    exit 1
fi

echo "Elastic Agent started successfully with PID: $AGENT_PID"

# Print some debug information
echo "Debug information:"
echo "Elastic Agent version:"
./elastic-agent version
echo "Elastic Agent status:"
./elastic-agent status

echo "Elastic Agent setup completed successfully."

# Keep the script running to keep the container alive
tail -f elastic-agent.log