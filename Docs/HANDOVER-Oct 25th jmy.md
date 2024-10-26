# Elastic Stack Fleet Docker Compose to Molecule Conversion - Handover Document

## Current Status

Converting Docker Compose ELK stack setup to Molecule scenario for testing es-agent role.

### Completed Work
1. Basic structure conversion
2. Certificate handling improvements:
   - Using relative path './shared-certs'
   - Implemented tmpfs mounts for runtime
   - Added proper cleanup

3. Environment variable handling:
   - Centralized in .env
   - Added .env.example
   - Fixed quoting issues (ES_JAVA_OPTS)

4. Script improvements:
   - Renamed setup-certs.sh to elastic-stack-init.sh
   - Added error handling
   - Improved logging

### Current Issues
1. Elasticsearch container exits with error:
   ```
   FileSystemException: Device or resource busy
   ```
   - Related to certificate directory handling
   - Current attempt uses tmpfs but might need adjustment

2. Fleet Server container exits:
   - Logs need investigation
   - Might be related to certificate permissions

### Next Steps
1. Debug Elasticsearch container:
   - Check if tmpfs mount is working
   - Verify certificate copying process
   - May need to adjust timing of operations

2. Investigate Fleet Server:
   - Check logs with `docker logs fleet-server`
   - Verify certificate permissions
   - Check connectivity to Elasticsearch

3. Test full workflow:
   - Run complete molecule test sequence
   - Verify agent enrollment
   - Check secure communication

### File Locations
- Main configuration: `molecule/es-agent/molecule.yml`
- Environment: `pre-stack/es-agent/.env`
- Init script: `pre-stack/es-agent/elastic-stack-init.sh`
- Prepare playbook: `molecule/es-agent/prepare.yml`
- Cleanup playbook: `molecule/es-agent/cleanup.yml`

### Important Commands
```bash
# View container status
docker ps -a

# Check container logs
docker logs elastic-setup
docker logs elasticsearch
docker logs fleet-server

# Run molecule commands
molecule test -s es-agent
molecule destroy -s es-agent && molecule converge -s es-agent

# Clean certificates
rm -rf shared-certs
```

### Environment Details
- Working directory: /workspaces/elastic-stack-fleet-docker-compose
- Branch: molecule-elk-jmy
- Stack version: 8.15.2

### Notes
- All paths in molecule.yml are relative to scenario directory
- Certificates are handled in three stages:
  1. Generation in shared-certs
  2. Read-only mount to containers
  3. Copy to tmpfs for runtime
- Current focus is on fixing certificate-related container exits

### Resources
- Original docker-compose.yml in pre-stack/es-agent/
- Molecule documentation: https://molecule.readthedocs.io/
- Elastic Stack documentation: https://www.elastic.co/guide/index.html

## Contact
Please reach out for any questions about:
- Current implementation status
- Known issues
- Planned improvements
