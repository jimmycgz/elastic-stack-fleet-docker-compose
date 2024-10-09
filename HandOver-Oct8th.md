# Handover document

## Progress on Oct 8th
### Successful tasks:
* Docker compose to setup ES, fleet
* Bash script to config a ubuntu container, add agent to the containerized fleet/es 

### Need continue
* Debian 11 gets hung at docker compose step, need manually try the agent entroll step by step following the script `agent-setup.sh`
* Test the ansible role, start with ubuntu `elastic-stack-fleet-docker-compose\ansible\roles\es-agent\tasks\main.yml` calling `agent-setup-ubuntu.yml`
* Test the ansible role, debian11 `elastic-stack-fleet-docker-compose\ansible\roles\es-agent\tasks\main.yml` calling `agent-setup-debian.yml`, find the difference with ubuntu. If almost same, recommend use ubuntu version for debian which supports upgrading from UI.


## Development and Testing Process

We used a Docker Compose environment to develop and test the Elastic Agent installation process before creating the Ansible playbooks. This approach allowed us to iterate quickly and identify potential issues in a controlled environment. Here's an overview of the process:

1. **Docker Compose Setup**:
   We created a `docker-compose.yml` file with services for Elasticsearch, Kibana, and Fleet Server. We also included services for Ubuntu and Debian containers to test the agent installation.
   We pre-configured most of the variables in .env file, which can be auto-rendered by docker-compose.

2. **Bash Script Development**:
   Initially, we developed a bash script (`agent-setup.sh`) to handle the Elastic Agent installation process. This script was tested and refined within the Docker containers.

3. **Docker Compose Testing**:
   We used commands like `docker compose up -d` to start the environment and `docker logs -f agent-ubuntu` to monitor the installation process in real-time.

4. **Iterative Improvements**:
   Through multiple iterations, we identified and resolved issues such as:
   - Handling different OS environments (Ubuntu vs Debian)
   - Managing enrollment tokens and policies
   - Dealing with SSL/TLS settings (currently using `--insecure` for testing)

5. **Bash to Ansible Translation**:
   Once the bash script was working reliably in the Docker environment, we translated its logic into Ansible tasks. This involved:
   - Breaking down the script into discrete tasks
   - Utilizing Ansible modules where possible (e.g., `apt`, `uri`, `unarchive`)
   - Structuring the tasks into roles and OS-specific files

6. **Key Learnings**:
   - The importance of idempotency in the installation process
   - Handling of enrollment tokens and policy creation
   - OS-specific considerations for package management

### Example Docker Compose Configuration

Here's a snippet of the Docker Compose configuration we used for testing:

```yaml
services:
  agent-ubuntu:
    image: ubuntu:20.04
    volumes:
      - ./agent-setup.sh:/agent-setup.sh
    environment:
      - KIBANA_FLEET_HOST=https://kib01:5601
      - FLEET_HOST=https://fleet:8220
      - ELASTIC_PASSWORD=${ELASTIC_PASSWORD}
      - STACK_VERSION=${STACK_VERSION}
    command: bash -c "./agent-setup.sh && tail -f /dev/null"

  agent-debian:
    image: debian:11
    volumes:
      - ./agent-setup.sh:/agent-setup.sh
    environment:
      - KIBANA_FLEET_HOST=https://kib01:5601
      - FLEET_HOST=https://fleet:8220
      - ELASTIC_PASSWORD=${ELASTIC_PASSWORD}
      - STACK_VERSION=${STACK_VERSION}
    command: bash -c "./agent-setup.sh && tail -f /dev/null"
```

This Docker Compose setup allowed us to test the installation script on both Ubuntu and Debian environments simultaneously, providing quick feedback and allowing for rapid iteration of the installation process.

The Ansible playbooks and roles in this project are the result of refining and translating this Docker-based testing process into a more scalable and maintainable Ansible structure.

---

This addition to the handover document provides your peer with important context about how the Ansible playbooks were developed and tested. It shows the progression from Docker Compose testing to Ansible implementation, which will help them understand the rationale behind certain decisions in the Ansible code.