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
- Target systems running Ubuntu or Debian
- Internet access on target systems for package installation and Elastic Agent download
- Elastic Stack (Elasticsearch, Kibana, and Fleet) already set up and accessible

## Role Variables

Edit `vars/main.yml` to configure the following variables:

```yaml
kibana_fleet_host: "https://your-kibana-host:5601"
fleet_host: "https://your-fleet-host:8220"
elastic_password: "your_elastic_password"
stack_version: "8.15.2"
```

## Usage

1. Include this role in your playbook:

   ```yaml
   ---
   - hosts: localhost
     connection: local
     collections:
       - community.general
     become: yes
     roles:
       - es-agent
   ```

2. Add inventory:

   ```
   [servers]
   localhost ansible_connection=local
   ```

3. Run your playbook (-v to run in verbose mode):

   ```
   ansible-playbook -i inventory playbook.yml -v
   ```

## Role Structure

```
es-agent/
├── tasks/
│   ├── main.yml
│   ├── agent-setup-ubuntu.yml
│   └── agent-setup-debian.yml
├── templates/
│   └── elastic-agent.service.j2
├── vars/
│   └── main.yml
└── README.md
```

- `main.yml`: Primary task file that orchestrates the installation process
- `agent-setup-ubuntu.yml`: Ubuntu-specific setup tasks
- `agent-setup-debian.yml`: Debian-specific setup tasks
- `vars/main.yml`: Variable definitions for the role

## How it Works

1. The role first performs common tasks like installing dependencies and fetching enrollment tokens.
2. It then detects the target system's distribution (Ubuntu or Debian) and includes the appropriate setup file.
3. For Ubuntu, it uses the built-in `install` command of the Elastic Agent.
4. For Debian, it performs a more manual installation, including setting up a systemd service.

## Customization

- Modify the variables in `vars/main.yml` to match your Elastic Stack setup.
- For Debian installations, you can customize the systemd service by editing the installation tasks in `agent-setup-debian.yml`.

## Notes

- This role uses the `--insecure` flag when installing the Elastic Agent. For production environments, proper SSL/TLS configuration is recommended.
- Ensure that the target systems can reach the specified Kibana and Fleet hosts.

## Troubleshooting

- Check Ansible logs for any error messages during execution.
- Verify that the provided URLs and credentials in `vars/main.yml` are correct.
- Ensure your Elastic Stack is properly set up and accessible from the target systems.

## Testing

This role was developed and tested using a Docker Compose environment to simulate Ubuntu and Debian systems. Refer to the included Docker Compose file for the test setup.

## Contributing

Contributions to improve the role are welcome. Please submit pull requests or open issues on the project repository.

## License

[Specify your license here]