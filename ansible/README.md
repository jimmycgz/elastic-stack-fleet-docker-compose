# Elastic Agent Ansible Role

This Ansible role automates the installation and configuration of Elastic Agent on Ubuntu and Debian systems. It's designed to work with Elastic Stack and integrates with Kibana Fleet for agent management.

## Features

- Supports Ubuntu and Debian distributions
- Automatically fetches or creates enrollment tokens
- Creates a default policy if none exists
- Downloads and installs the specified version of Elastic Agent
- Configures the agent to connect to your Elastic Stack
- Handles distribution-specific installation differences
- Preserves existing installations

## Requirements

- Ansible 2.9 or higher
- Target systems running Ubuntu or Debian
- Internet access on target systems for package installation and Elastic Agent download
- Elastic Stack (Elasticsearch, Kibana, and Fleet) already set up and accessible

## Role Variables

Edit `vars/main.yml` to configure the following variables:

```yaml
kibana_fleet_host: "https://kibana:5601"
fleet_host: "https://fleet-server:8220"
elastic_password: "your_elastic_password"
stack_version: "8.15.2"
```

## Project Structure

```
ansible/
├── README.md
├── inventory.yml          # Inventory file for Docker containers
├── playbook.yml          # Main playbook file
├── requirements.txt      # Python dependencies
├── molecule/            # Molecule test configuration
│   ├── README.md        # Molecule testing guide
│   └── es-agent/        # Test scenario for es-agent role
│       ├── molecule.yml # Molecule configuration
│       ├── converge.yml # Playbook to test the role
│       ├── prepare.yml  # Pre-test setup
│       └── verify.yml   # Post-test verification
└── roles/
    └── es-agent/        # Elastic Agent role
        ├── tasks/
        │   ├── main.yml              # Main task file
        │   ├── agent-setup-common.yml # Common setup tasks
        │   ├── agent-setup-ubuntu.yml # Ubuntu-specific tasks
        │   └── agent-setup-debian.yml # Debian-specific tasks
        ├── templates/
        │   └── elastic-agent.service.j2 # Systemd service template
        ├── vars/
        │   └── main.yml              # Role variables
        └── defaults/
            └── main.yml              # Default variables
```

## Usage

1. Install Python packages:
```bash
pip install -r requirements.txt
```

2. Run the playbook:
```bash
ansible-playbook -i inventory.yml playbook.yml -v
```

## How it Works

1. The role first performs common tasks like installing dependencies and fetching enrollment tokens.
2. It detects the target system's distribution (Ubuntu or Debian) and includes the appropriate setup file.
3. For Ubuntu:
   - Checks for existing installation using `elastic-agent version`
   - Uses the built-in `install` command if not installed
4. For Debian:
   - Checks for existing installation by file presence and version
   - Uses manual `enroll` and run steps if not installed

## Installation Process

The role follows these steps:
1. Checks if Elastic Agent is already installed
2. If not installed:
   - Downloads and extracts the agent
   - Installs dependencies (curl, jq, procps)
   - Fetches enrollment token from Kibana
   - Installs and enrolls the agent
3. If already installed:
   - Skips installation steps
   - Preserves existing configuration

## Testing

This role includes Molecule tests to verify functionality:

```bash
# Run full test suite
molecule test -s es-agent

# Or step by step for debugging
molecule create     # Create test containers
molecule converge   # Run the playbook
molecule verify     # Run verification
molecule destroy    # Clean up
```

See `molecule/README.md` for detailed testing information.

## Notes

- The role preserves existing installations and only installs if the agent is not present
- Different installation checks are used for Ubuntu and Debian
- For production environments, proper SSL/TLS configuration is recommended
- Ensure target systems can reach the specified Kibana and Fleet hosts

## Troubleshooting

- Check Ansible logs for any error messages
- Verify URLs and credentials in `vars/main.yml`
- Ensure Elastic Stack is accessible from target systems
- For Molecule test issues, refer to `molecule/README.md`
