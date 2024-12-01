# Elastic Agent Ansible Role

This Ansible role automates the installation and configuration of Elastic Agent on Ubuntu and Debian systems. It's designed to work with Elastic Stack and integrates with Kibana Fleet for agent management.

## Features

- Supports Ubuntu and Debian distributions
- Automatically fetches or creates enrollment tokens
- Creates a default policy if none exists
- Downloads and installs the specified version of Elastic Agent
- Configures the agent to connect to your Elastic Stack
- Handles distribution-specific installation differences
- Supports both API Key and Basic Auth authentication methods

## Requirements

- Ansible 2.9 or higher
- Docker containers running Ubuntu and Debian
- Internet access on target systems for package installation and Elastic Agent download
- Elastic Stack (Elasticsearch, Kibana, and Fleet) already set up and accessible

## Role Variables

The following variables need to be set in the .env file in the pre-stack directory:

- `AUTH_METHOD`: Set to 'api_key' or 'basic_auth' to specify the authentication method
- `ELK_KIBANA_HOST`: The URL of your Kibana instance
- `FLEET_HOST`: The URL of your Fleet server
- `STACK_VERSION`: The version of the Elastic Stack you're using

**Scenario A: When using API Key authentication**
- `ELK_API_KEY`: The API key for authentication

**Scenario B: When using Basic Auth authentication**
- `ELK_USERNAME`: The username for Basic Auth
- `ELK_PASSWORD`: The password for Basic Auth

## Usage

1. Ensure Docker containers are running:
   ```
   cd $HOME/projects/ansible/elastic-stack-fleet-docker-compose/pre-stack
   docker-compose up -d
   ```

2. Update the .env file in the pre-stack directory with the appropriate values for your setup, including the `AUTH_METHOD`.

3. Source the .env file:
   ```
   source $HOME/projects/ansible/elastic-stack-fleet-docker-compose/pre-stack/.env
   echo $AUTH_METHOD
   ```

4. Run the Ansible playbook:
   ```
   cd $HOME/projects/ansible/elastic-stack-fleet-docker-compose/ansible
   ansible-playbook -i inventory.yml playbook.yml \
     -e "elk_kibana_host=$ELK_KIBANA_HOST" \
     -e "fleet_host=$FLEET_HOST" \
     -e "stack_version=$STACK_VERSION" \
     -e "auth_method=$AUTH_METHOD" \
     -e "elk_api_key=$ELK_API_KEY" \
     -e "elk_username=$ELK_USERNAME" \
     -e "elk_password=$ELK_PASSWORD" \
     -v
   ```

   Note: You only need to include the variables relevant to your chosen authentication method (either `elk_api_key` or `elk_username` and `elk_password`).

## Role Structure

```
es-agent/
├── tasks/
│   ├── main.yml
│   ├── agent-setup-common.yml
│   ├── agent-setup-ubuntu.yml
│   └── agent-setup-debian.yml
├── templates/
├── vars/
│   └── main.yml
└── README.md
```

## Customization

- For Debian installations, you can customize the systemd service by editing the installation tasks in `agent-setup-debian.yml`.

## Notes

- This role uses the `--insecure` flag when installing the Elastic Agent. For production environments, proper SSL/TLS configuration is recommended.
- Ensure that the target systems can reach the specified Kibana and Fleet hosts.
- When using Basic Auth, make sure to use a secure method to pass the username and password, such as Ansible Vault for sensitive information.

## Troubleshooting

- Check Ansible logs for any error messages during execution.
- Verify that the provided URLs and authentication credentials are correct in the .env file.
- Ensure your Elastic Stack is properly set up and accessible from the target systems.
- Make sure the Docker containers are running before executing the playbook.

## Testing

This role is tested using Docker containers to simulate Ubuntu and Debian systems. Refer to the included Docker Compose file for the test setup.
