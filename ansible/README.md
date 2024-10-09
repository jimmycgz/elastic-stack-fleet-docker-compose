# Elastic Agent Ansible Role

This Ansible role automates the installation and configuration of Elastic Agent on Ubuntu and Debian systems. It's designed to work with Elastic Stack and integrates with Kibana Fleet for agent management.

## Features

- Supports Ubuntu and Debian distributions
- Automatically fetches or creates enrollment tokens
- Creates a default policy if none exists
- Downloads and installs the specified version of Elastic Agent
- Configures the agent to connect to your Elastic Stack

## Requirements

- Ansible 2.9 or higher
- Target systems running Ubuntu or Debian
- Internet access on target systems for package installation and Elastic Agent download

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
- hosts: servers
  roles:
    - elastic-agent
```

2. Run your playbook:

```
ansible-playbook your-playbook.yml
```

## Role Structure

```
elastic-agent/
├── tasks/
│   ├── main.yml
│   ├── agent-setup-ubuntu.yml
│   └── agent-setup-debian.yml
└── vars/
    └── main.yml
```

- `main.yml`: Primary task file that orchestrates the installation process
- `agent-setup-ubuntu.yml`: Ubuntu-specific setup tasks
- `agent-setup-debian.yml`: Debian-specific setup tasks
- `vars/main.yml`: Variable definitions for the role

## Notes

- This role uses the `--insecure` flag when installing the Elastic Agent. For production environments, proper SSL/TLS configuration is recommended.
- Ensure that the target systems can reach the specified Kibana and Fleet hosts.

## Testing

This role was developed and tested using a Docker Compose environment to simulate Ubuntu and Debian systems. Refer to the included Docker Compose file for the test setup.

