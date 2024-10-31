# Converting Docker Compose ELK Stack to Molecule Testing

## Core Principles

1. **Configuration Equivalence**
   - Maintain exact service configurations between Docker Compose and Molecule
   - Preserve all environment variables and their relationships
   - Keep certificate handling and security measures intact
   - Respect service-specific initialization patterns

2. **Service Organization**
   - Split services between platform setup and test targets
   - Platform services (Elasticsearch, Kibana, Fleet) in molecule.yml
   - Test target (es-agent) in converge.yml
   - Each service follows its own initialization pattern:
     ```yaml
     # Elasticsearch/Kibana pattern
     entrypoint: []
     command: bash -c '...'

     # Fleet Server pattern
     command: elastic-agent container
     # No entrypoint override needed
     ```

3. **File Handling Rules**
   - ALWAYS read entire file first before making changes
   - Make targeted changes while keeping ALL other sections
   - Use platform-specific syntax (e.g., Molecule uses 'env' while Docker Compose uses 'environment')
   - Never provide partial content that would delete existing services

## Directory Structure

```
molecule/
└── es-agent/
    ├── molecule.yml          # Main configuration file
    ├── prepare.yml          # ELK stack preparation
    ├── converge.yml         # es-agent deployment
    └── verify.yml           # Agent registration verification
```

## Implementation Guide

### 1. Platform Services (molecule.yml)

Key considerations:
- Define services in correct startup order
- Use proper health checks for service readiness
- Maintain certificate volume mounts
- Use Molecule-specific syntax for environment variables
- Follow service-specific initialization patterns

```yaml
platforms:
  # Certificate setup container
  - name: elastic-setup
    entrypoint: []
    command: |
      bash -c '...'

  # Elasticsearch container
  - name: elasticsearch
    entrypoint: []
    command: |
      bash -c '...'

  # Kibana container
  - name: kibana
    entrypoint: []
    command: |
      bash -c '...'

  # Fleet Server container
  - name: fleet-server
    command: elastic-agent container
    env:
      FLEET_SERVER_ENABLE: "1"
      # Other fleet-specific vars
```

### 2. Service Dependencies

Focus areas:
- Proper startup sequence
- Service-specific health checks
- Correct initialization patterns
- Environment variable handling

```yaml
depends_on:
  elastic-setup:
    condition: service_completed_successfully
  elasticsearch:
    condition: service_healthy
  kibana:
    condition: service_healthy
```

## Best Practices

1. **Service Configuration**
   - Use correct initialization pattern per service
   - Maintain proper dependencies
   - Follow service-specific health checks
   - Use appropriate environment variables

2. **Certificate Handling**
   - Mount certificates as read-only
   - Use consistent paths across services
   - Verify certificate generation before proceeding

3. **Environment Variables**
   - Use Molecule's 'env' key for container environment variables
   - Provide defaults for optional variables
   - Maintain variable relationships between services

## Common Issues and Solutions

1. **Service Initialization**
   - Follow service-specific patterns
   - Use proper startup commands
   - Respect initialization order
   - Check service logs for issues

2. **Environment Variables**
   - Use platform-specific syntax
   - Maintain variable consistency
   - Provide appropriate defaults

Remember: Always maintain complete configurations and respect service-specific initialization patterns when converting between Docker Compose and Molecule.
