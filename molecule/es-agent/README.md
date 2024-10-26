# Elastic Agent Role - Molecule Tests

This directory contains Molecule tests for the Elastic Agent role. The tests verify the role's ability to deploy and configure the Elastic Agent in both container and VM environments.

## Prerequisites

- Docker
- Molecule
- Ansible
- Required collections (automatically installed via requirements.yml):
  - community.docker
  - ansible.posix

## Test Structure

- `molecule.yml`: Main configuration file that sets up the test environment including Elasticsearch, Kibana, and Fleet Server
- `prepare.yml`: Handles environment preparation and prerequisite services
- `converge.yml`: Tests the es-agent role deployment
- `verify.yml`: Verifies agent installation and connectivity
- `cleanup.yml`: Ensures clean environment between test runs
- `requirements.yml`: Specifies required Ansible collections

## Security Considerations

### Environment Variables
- Never commit `.env` files containing real credentials
- Use `.env.example` as a template with dummy values
- Keep `.env` files secure and restrict access
- Regularly rotate passwords and update `.env` accordingly

### Certificate Management
- All certificates are generated during test runs
- Certificates are stored in `shared-certs` directory
- Containers use tmpfs mounts for runtime certificate storage
- Never commit certificates or private keys
- Clean up certificate directories after testing

## Environment Configuration

Environment variables are managed through two files:

1. `/workspaces/elastic-stack-fleet-docker-compose/pre-stack/es-agent/.env`:
   - Contains actual configuration values
   - Never committed to repository
   - Required for running tests
   - Mounted at `/usr/share/elasticsearch/pre-stack/.env`

2. `/workspaces/elastic-stack-fleet-docker-compose/pre-stack/es-agent/.env.example`:
   - Template with dummy values
   - Committed to repository
   - Used as reference for required variables
   - Copy to .env and update values

The .env file contains:
- Stack versions and passwords
- Service configurations
- Security settings
- Network configurations

## Stack Initialization

The Elastic Stack initialization is handled by `/workspaces/elastic-stack-fleet-docker-compose/pre-stack/es-agent/elastic-stack-init.sh` which:
- Validates environment variables
- Generates CA certificate
- Creates service certificates
- Sets proper permissions
- Configures security settings
- Handles error conditions

## Certificate Handling

Certificates are managed in three stages:
1. Generation: elastic-setup container generates certificates in shared-certs directory
2. Distribution: Certificates are mounted read-only from shared-certs to each container
3. Runtime: Each container:
   - Uses tmpfs mount for certificate directory
   - Copies certificates from shared mount to tmpfs
   - Sets proper ownership and permissions
   - Uses certificates from tmpfs mount

This approach ensures:
- Secure certificate handling
- Proper permissions per service
- Clean environment between runs
- No certificate conflicts

## Running Tests

All commands should be run from the root directory of the repository:

```bash
# Run full test sequence
molecule test -s es-agent

# Run specific steps
molecule create -s es-agent    # Create test instances
molecule prepare -s es-agent   # Set up prerequisites
molecule converge -s es-agent  # Run the role
molecule verify -s es-agent    # Run verification
molecule destroy -s es-agent   # Clean up
```

## Verification

The tests verify:
- Agent process is running
- Agent is properly enrolled with Fleet
- Agent can communicate with Fleet Server
- Agent version matches stack version

Works universally across:
- Container deployments
- VM deployments

## Debugging

The setup provides extensive debugging information:
- Stack initialization logs
- Service startup status
- Container logs
- Error details when issues occur

To view logs for specific containers:
```bash
# View elastic-setup logs
docker logs elastic-setup

# View elasticsearch logs
docker logs elasticsearch

# View kibana logs
docker logs kibana

# View fleet-server logs
docker logs fleet-server
```

## Troubleshooting

Common issues and solutions:

1. Environment Setup Fails
   - Copy .env.example to .env and update values
   - Verify .env file exists at correct path
   - Check file permissions on .env file
   - Ensure all required variables are set

2. Certificate Generation Fails
   - Check shared-certs directory permissions
   - Verify elastic-setup container logs
   - Ensure proper volume mounts

3. Services Fail to Start
   - Check container logs for errors
   - Verify certificate paths and permissions
   - Check tmpfs mounts and permissions

4. Fleet Server Connection Issues
   - Verify network connectivity between containers
   - Check certificate paths and permissions
   - Ensure proper enrollment token configuration

To clean up and retry:
```bash
# Full cleanup and retry
molecule destroy -s es-agent
molecule test -s es-agent

# Clean certificates and retry prepare
rm -rf shared-certs
molecule prepare -s es-agent
```

## Notes

- The setup uses Docker-in-Docker for the ELK stack
- Certificates use tmpfs mounts in containers
- Network connectivity uses Docker network mode
- Error handling is implemented at all levels
- All molecule commands must be run from the repository root with `-s es-agent`
- Dependencies are automatically installed via requirements.yml
- Environment variables are centralized in a single .env file (not committed)
- Example environment variables provided in .env.example
