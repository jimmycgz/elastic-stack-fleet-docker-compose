# Test Ansible Role ES-Agent with ELK Cloud

## Pre-setup
* Create a free tail free trial at cloud.elastic.co, free for 14 days

* Create a New API KEY at KIBANA console
Go to Management → Security → API Keys
Click "Create API key

* Get Enrollment Token 

The Basic auth doesn't work, use API KEY instead
```
curl -X GET "${ELK_KIBANA_HOST}/api/fleet/enrollment-api-keys" \
     -H "kbn-xsrf: true" \
     -H "Authorization: ApiKey $ELK_API" \
     -k
```

## Test Playbook
Change the Basic auth to the API Key, then follow the README.md to run the playbook under `ansible` folder

## Test Molecule
Follow the README.md under molecule folder for details.

When `molecule test -s es-agent` throws error, you can try step by step as below:

```
molecule create     # Only create the instance
molecule converge   # Only run ansible playbook
molecule login      # SSH into the instance
```

TASK [../../roles/es-agent : Fail if Kibana is not reachable] 