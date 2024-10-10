# Elastic Agent Setup: Ubuntu vs Debian User Manual

## Introduction

This manual outlines the differences in setting up the Elastic Agent on Ubuntu and Debian systems within a Docker environment. While both are Debian-based distributions, there are some key differences in how the Elastic Agent is bootstrapped and configured.

## Ubuntu Setup

### Process Overview

1. Download the `.tar.gz` file
2. Extract the contents
3. Run the installation command

### Step-by-Step Guide

1. Download the Elastic Agent:
   ```bash
   curl -L -O https://artifacts.elastic.co/downloads/beats/elastic-agent/elastic-agent-${STACK_VERSION}-linux-x86_64.tar.gz
   ```

2. Extract the archive:
   ```bash
   tar xzvf elastic-agent-${STACK_VERSION}-linux-x86_64.tar.gz
   ```

3. Install the Elastic Agent:
   ```bash
   cd elastic-agent-${STACK_VERSION}-linux-x86_64
   ./elastic-agent install \
       --url="${FLEET_HOST}" \
       --enrollment-token="${ENROLLMENT_TOKEN}" \
       --insecure \
       --non-interactive \
       --force
   ```

### Key Points

- Ubuntu typically has all necessary dependencies pre-installed.
- The installation process is straightforward and uses the `install` command provided by the Elastic Agent.

## Debian Setup

### Process Overview

1. Download the `.tar.gz` file
2. Extract the contents
3. Move files to appropriate locations
4. Manually create and configure the systemd service
5. Enroll the agent
6. Start the agent manually

### Step-by-Step Guide

1. Download and extract the Elastic Agent (same as Ubuntu).

2. Move files to the appropriate locations:
   ```bash
   mkdir -p /usr/share/elastic-agent
   cp -r elastic-agent-${STACK_VERSION}-linux-x86_64/* /usr/share/elastic-agent/
   ```

3. Create a systemd service file (optional in containerized environments):
   ```bash
   cat << EOF > /etc/systemd/system/elastic-agent.service
   [Unit]
   Description=Elastic Agent
   After=network.target

   [Service]
   ExecStart=/usr/share/elastic-agent/elastic-agent run
   Restart=always
   User=root

   [Install]
   WantedBy=multi-user.target
   EOF
   ```

4. Enroll the agent:
   ```bash
   cd /usr/share/elastic-agent
   ./elastic-agent enroll --url="${FLEET_HOST}" --enrollment-token="${ENROLLMENT_TOKEN}" --insecure --force
   ```

5. Start the agent (choose one method):
   - For systemd (if set up):
     ```bash
     systemctl start elastic-agent
     ```
   - Manually:
     ```bash
     ./elastic-agent run &
     ```

### Key Points

- Debian might lack some dependencies that Ubuntu includes by default.
- The installation process is more manual, giving you greater control over file placement and service configuration.
- This method avoids potential issues with the `install` command, which might not work correctly in all Debian environments.

## Why the Different Approaches?

1. **System Differences**: While Ubuntu and Debian share many similarities, Ubuntu often includes more pre-installed packages and has different default configurations.

2. **Compatibility**: The manual approach for Debian ensures greater compatibility across different Debian versions and environments.

3. **Containerization**: In containerized environments, the manual Debian approach allows for easier customization and potentially smaller image sizes by installing only what's necessary.

4. **Control**: The Debian method provides more explicit control over the installation process, which can be beneficial in certain enterprise or security-conscious environments.

5. **Troubleshooting**: If issues arise, the manual Debian method makes it easier to identify and resolve problems step-by-step.

## Conclusion

While the Ubuntu method is more straightforward, the Debian approach offers greater flexibility and control. In containerized environments, the Debian method can be preferable for both Ubuntu and Debian base images due to its explicit nature and compatibility with minimal container setups.

Choose the method that best fits your system environment, security requirements, and comfort level with manual configuration.