#!/bin/bash
set -x


curl -k https://localhost:5601/api/status
curl -k https://kibana:5601/api/status
{"status":{"overall":{"level":"available"}}}


curl -k https://elasticsearch:9200/_cluster/health -u elastic:elastic

curl -k https://localhost:9200/_cluster/health -u elastic:elastic


https://localhost:8220/api/status


echo "1. Check Fleet Server env variables:"
env | grep -E "FLEET_|ELASTICSEARCH_|KIBANA_"

echo -e "\n2. Check Elasticsearch connection:"
curl --cacert $ELASTICSEARCH_CA -u $ELASTICSEARCH_USERNAME:$ELASTICSEARCH_PASSWORD $ELASTICSEARCH_HOST/_cluster/health

echo -e "\n3. Check Kibana connection:"
curl -k --cacert $KIBANA_FLEET_CA -u $KIBANA_FLEET_USERNAME:$KIBANA_FLEET_PASSWORD $KIBANA_FLEET_HOST/api/status

curl --cacert $KIBANA_FLEET_CA -u $KIBANA_FLEET_USERNAME:$KIBANA_FLEET_PASSWORD $KIBANA_FLEET_HOST/api/status -I -s

echo -e "\n4. Check Fleet initialization status:"
curl -k --cacert $KIBANA_FLEET_CA -u $KIBANA_FLEET_USERNAME:$KIBANA_FLEET_PASSWORD $KIBANA_FLEET_HOST/api/fleet/setup

echo -e "\n5. Check Fleet Server policy:"
curl -k --cacert $KIBANA_FLEET_CA -u $KIBANA_FLEET_USERNAME:$KIBANA_FLEET_PASSWORD "$KIBANA_FLEET_HOST/api/fleet/agent_policies?kuery=id:fleet-server-policy"

echo -e "\n6. List all agent policies:"
curl -k --cacert $KIBANA_FLEET_CA -u $KIBANA_FLEET_USERNAME:$KIBANA_FLEET_PASSWORD "$KIBANA_FLEET_HOST/api/fleet/agent_policies"
