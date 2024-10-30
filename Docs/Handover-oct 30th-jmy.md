# Elastic Stack Molecule Testing Project Handover

## Current Status

We're working on implementing Molecule tests for an Elastic Stack setup, specifically focusing on the fleet-server container dependencies. The main challenge has been handling the sequential startup requirements between containers, as Molecule doesn't support Docker Compose's `depends_on` functionality.

## Key Findings

1. **Environment Variables**
   - Confirmed that only the `env` key works for setting environment variables in Molecule containers
   ```yaml
   env:
     TEST4: "fromplainenv"
     FLEET_SERVER_ENABLE: "1"
     FLEET_SERVER_ELASTICSEARCH_HOST: https://elasticsearch:9200
   ```

2. **Fleet Server Requirements**
   - Must use exact command: `elastic-agent container`
   - Cannot wrap the command in bash scripts
   - Configuration must be done via environment variables

## Current Implementation

### Container Sequence
1. Elasticsearch starts first
2. es-setup container runs to generate certificates
3. Fleet server starts only after certificate generation

### Key Files

1. `molecule.yml`:
   - Only defines elasticsearch and es-setup initially
   - Fleet server is created during convergence

2. `prepare.yml`:
   - Handles initial setup
   - Checks for certificates
   - Waits for Elasticsearch and Kibana
   - Contains all health checks

3. `converge.yml`:
   - Creates fleet-server container after es-setup completes
   - Manages dependencies through sequential creation

## Next Steps

1. **Need to Test**:
   - Complete certificate generation workflow
   - Fleet server startup with certificates
   - Health check responses

2. **To Be Implemented**:
   - Error handling for certificate generation
   - Cleanup procedures
   - Additional health checks if needed

## Known Issues

1. Certificate handling needs verification
2. Health check timeouts might need adjustment
3. Network connectivity between containers needs testing

## Environment Variables Required

Make sure these are set:
- ELASTICSEARCH_HOST
- ELASTICSEARCH_USERNAME
- ELASTIC_PASSWORD
- KIBANA_FLEET_HOST
- FLEET_HOST
- FLEET_SERVER_SERVICE_TOKEN
- FLEET_SERVER_POLICY_ID

## Testing Instructions

1. Run the tests:
```bash
molecule create
molecule converge
```

2. Check container status:
```bash
molecule list
```

3. Check logs:
```bash
molecule login -h fleet-server
```

## Reference Documentation

1. Elastic Agent Container Documentation:
   - Key command: `elastic-agent container --help`
   - All configuration must be done via environment variables

2. Related configuration files:
   - `/workspaces/elastic-stack-fleet-docker-compose/pre-stack/es-agent/.env`
   - Current molecule configuration files

## Support Contacts

[Add relevant team members and their contact information]

## Additional Notes

- The fleet-server container must be created only after certificate generation is complete
- All health checks are implemented in the prepare playbook
- The setup uses the Molecule ephemeral directory for certificate storage

## Open Questions

1. Optimal timeout values for health checks
2. Additional error handling requirements
3. Specific certificate requirements for your environment

Please reach out if you need any clarification or run into issues.