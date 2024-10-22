# Elastic Agent Ansible Role

This Ansible role automates the installation and configuration of Elastic Agent on Ubuntu and Debian systems. It's designed to work with Elastic Stack and integrates with Kibana Fleet for agent management.

## Features

- Supports Ubuntu and Debian distributions
- Automatically fetches or creates enrollment tokens
- Creates a default policy if none exists
- Downloads and installs the specified version of Elastic Agent
- Configures the agent to connect to your Elastic Stack
- Handles distribution-specific installation differences

## Requirements

- Ansible 2.9 or higher
- Docker containers running Ubuntu and Debian
- Internet access on target systems for package installation and Elastic Agent download
- Elastic Stack (Elasticsearch, Kibana, and Fleet) already set up and accessible

## Role Variables

The following variables need to be passed to the playbook:

- `elk_kibana_host`: The URL of your Kibana instance
- `fleet_host`: The URL of your Fleet server
- `elk_api_key`: The API key for authentication
- `stack_version`: The version of the Elastic Stack you're using

These variables are sourced from the .env file in the pre-stack directory.

## Usage

1. Ensure Docker containers are running:
   ```
   cd $HOME/projects/ansible/elastic-stack-fleet-docker-compose/pre-stack
   docker-compose up -d
   ```

2. Source the .env file:
   ```
   source $HOME/projects/ansible/elastic-stack-fleet-docker-compose/pre-stack/.env
   ```

3. Run the Ansible playbook:
   ```
   cd $HOME/projects/ansible/elastic-stack-fleet-docker-compose/ansible
   ansible-playbook -i inventory.yml playbook.yml \
     -e "elk_kibana_host=$ELK_KIBANA_HOST" \
     -e "fleet_host=$FLEET_HOST" \
     -e "elk_api_key=$ELK_API_KEY" \
     -e "stack_version=$STACK_VERSION" \
     -v
   ```

## Role Structure

```
es-agent/
├── tasks/
│   ├── main.yml
│   ├── agent-setup-common.yml
│   ├── agent-setup-ubuntu.yml
│   └── agent-setup-debian.yml
├── templates/
│   └── elastic-agent.service.j2
├── vars/
│   └── main.yml
└── README.md
```

## Customization

- For Debian installations, you can customize the systemd service by editing the installation tasks in `agent-setup-debian.yml`.

## Notes

- This role uses the `--insecure` flag when installing the Elastic Agent. For production environments, proper SSL/TLS configuration is recommended.
- Ensure that the target systems can reach the specified Kibana and Fleet hosts.

## Troubleshooting

- Check Ansible logs for any error messages during execution.
- Verify that the provided URLs and API key are correct in the .env file.
- Ensure your Elastic Stack is properly set up and accessible from the target systems.
- Make sure the Docker containers are running before executing the playbook.

## Testing

This role is tested using Docker containers to simulate Ubuntu and Debian systems. Refer to the included Docker Compose file for the test setup.
