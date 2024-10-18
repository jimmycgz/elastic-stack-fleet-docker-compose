## Resolving Hostname Resolution Issue: End-to-End Guide

### Root Cause
The Molecule test container runs in isolation and doesn't inherently have access to the hostname resolution of the Docker Compose network where the Elastic stack services are running. This leads to an inability to resolve hostnames like 'elastic-stack-fleet-docker-compose-kib01-1' within the test environment.

### Step-by-Step Resolution

1. **Identify the Docker network**:
   ```bash
   docker network ls
   ```
   Look for a network named something like `elastic-stack-fleet-docker-compose_default`.

2. **Inspect the network to get IP addresses**:
   ```bash
   docker network inspect elastic-stack-fleet-docker-compose_default
   ```
   This command provides detailed information about the network, including connected containers and their IP addresses.

3. **Note down the IP addresses** for the relevant services:
   - Kibana: Look for a container name like `elastic-stack-fleet-docker-compose-kib01-1`
   - Elasticsearch: Look for a container name like `elastic-stack-fleet-docker-compose-es01-1`
   - Fleet: Look for a container named `fleet`

4. **Update the `molecule.yml` file**:
   Add the `extra_hosts` section under the `platforms` item:
   ```yaml
   platforms:
     - name: instance
       # ... other configurations ...
       extra_hosts:
         - "elastic-stack-fleet-docker-compose-kib01-1:172.19.0.4"
         - "elastic-stack-fleet-docker-compose-es01-1:172.19.0.3"
         - "fleet:172.19.0.2"
   ```
   Replace the IP addresses with the ones you noted in step 3.

5. **Remove any tasks** from your `converge.yml` `prepare.yml`, no need the dummy ELK stack

6. **Run the Molecule test**:
   ```bash
   molecule test
   ```

7. **Troubleshooting**:
   If you encounter issues, you can:
   - Use `molecule login` to access the test container and manually check `/etc/hosts`
   - Use `ping` or `curl` within the test container to verify connectivity to the Elastic stack services

### Maintaining the Solution

- Regularly check if the IP addresses of your Elastic stack services have changed, especially after updates or restarts.
- If IP addresses change, update the `extra_hosts` section in `molecule.yml` accordingly.
- Consider automating the IP address discovery and `molecule.yml` update process for longer-term maintenance.
