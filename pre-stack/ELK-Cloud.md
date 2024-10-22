I've launched a free tail free trial at cloud.elastic.co

how to get the enrollment token by curl command?

curl -X GET "https://YOUR_KIBANA_URL/api/fleet/enrollment-api-keys" \
     -H "kbn-xsrf: true" \
     -H "Authorization: ApiKey YOUR_API_KEY" \
     -k