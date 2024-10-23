# Molecule Testing Guide

This directory contains Molecule tests for the Elastic Agent Ansible role. The tests verify the role's functionality across different distributions.

## Directory Structure

```
molecule/
├── README.md
└── es-agent/                # Test scenario for es-agent role
    ├── molecule.yml         # Main configuration file
    ├── converge.yml         # Playbook to test the role
    ├── prepare.yml          # Pre-test setup
    └── verify.yml           # Post-test verification
```

## Test Configuration

The `molecule.yml` file configures:
- Docker as the test driver
- Ubuntu and Debian test containers
- Network configuration to connect to Elastic Stack
- Environment variables for Elastic Stack connection

## Running Tests

### Full Test Suite

```bash
molecule test -s es-agent
```

### Step-by-Step Testing

If the full test fails, you can run steps individually:

```bash
molecule create     # Only create the instance
molecule converge   # Only run ansible playbook
molecule login      # SSH into the instance
```

## Debugging Tips

1. Increase verbosity with `-v` flags:
```bash
# Increasing levels of verbosity
molecule -v test
molecule -vv test
molecule -vvv test
```

2. Check instance state:
```bash
molecule list
```

3. Debug without destroying:
```bash
molecule create     # Create instances
molecule converge   # Run playbook
molecule login      # Access instance
```

4. Log into specific instance:
```bash
molecule login --host instance-name
```

5. Keep temporary files:
```bash
molecule --debug test
```

6. Show steps without executing:
```bash
molecule check
```

7. Add debugging tasks:
```yaml
- name: Debug variables
  debug:
    var: some_variable
    verbosity: 2
```

8. Check logs:
```bash
ls -la .molecule/
cat .molecule/*/ansible.log
```

## Common Issues

1. Kibana Connection:
   - If the task "Fail if Kibana is not reachable" fails:
     - Verify Elastic Stack is running
     - Check network configuration in molecule.yml
     - Ensure correct hostnames in extra_hosts

2. Agent Installation:
   - For Ubuntu container issues:
     - Check agent version compatibility
     - Verify installation paths
   - For Debian container issues:
     - Ensure all dependencies are installed
     - Check process management

## Test Scenarios

The tests verify:
1. Agent installation on fresh systems
2. Proper handling of existing installations
3. Correct enrollment with Fleet server
4. Distribution-specific installation methods

## Environment Variables

Required variables for testing:
- ELASTIC_PASSWORD
- KIBANA_PASSWORD
- STACK_VERSION

These can be set in your environment or passed during test execution.
