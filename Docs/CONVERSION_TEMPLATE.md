# Docker Compose to Molecule Pre-Stack Conversion Template

## Initial Requirements Gathering

When requesting help to convert a Docker Compose stack to Molecule pre-stack, include:

1. Current Setup Details:
   - Location and structure of Docker Compose files
   - All dependent configuration files (.env, scripts, etc.)
   - Any custom scripts or initialization processes
   - Volume mounts and their purposes
   - Network configuration requirements

2. Security Requirements:
   - Certificate handling needs
   - Environment variable management
   - Sensitive data handling
   - Required permissions and ownership

3. Service Dependencies:
   - Startup sequence requirements
   - Health check conditions
   - Inter-service communication needs
   - Required wait conditions

4. Testing Focus:
   - Main role/component being tested
   - Required pre-stack services
   - Test scenarios to support
   - Verification requirements

## Example Prompt Template

```markdown
I need help converting a Docker Compose stack to Molecule scenario code. Here's the context:

1. Current Setup:
   - Docker Compose file location: [path]
   - Key configuration files:
     * Environment: [list files]
     * Scripts: [list files]
     * Certificates: [handling method]
   - Critical volume mounts:
     * [mount:purpose pairs]
   - Network requirements:
     * [list requirements]

2. Security Requirements:
   - Certificate management:
     * Generation method
     * Distribution to services
     * Runtime handling
   - Sensitive data:
     * Environment variables
     * Secrets management
     * File permissions

3. Service Dependencies:
   - Required services: [list]
   - Startup sequence: [order]
   - Health checks: [conditions]
   - Wait conditions: [specifications]

4. Testing Requirements:
   - Target role: [role name]
   - Test platforms: [list]
   - Test scenarios: [list]
   - Verification needs: [list]

5. Technical Constraints:
   - Working directory structure
   - File path requirements
   - Permission requirements
   - Network isolation needs

Please provide:
1. Complete molecule directory structure
2. Configuration for prepare/dependency steps
3. Service initialization handling
4. Certificate and security management
5. Network and volume handling
6. Error handling and debugging support
```

## Molecule-Specific Considerations

1. Network Configuration:
   - Use network_mode instead of networks section
   - Cannot define top-level networks
   - All containers must use same network mode
   - Consider service discovery implications

2. Volume Management:
   - Use relative paths from scenario directory
   - Avoid MOLECULE_EPHEMERAL_DIRECTORY
   - Use tmpfs for runtime-only storage
   - Handle shared volume permissions carefully

3. Container Configuration:
   - Pre-build image limitations
   - Command vs entrypoint considerations
   - User and permission handling
   - Working directory implications

4. Test Sequence:
   - Proper prepare phase usage
   - Dependency management
   - Cleanup handling
   - Verification timing

5. Resource Management:
   - Ephemeral directory limitations
   - Shared resource handling
   - Cleanup requirements
   - State persistence needs

## Best Practices

1. File Organization:
   - Use relative paths in molecule.yml
   - Keep sensitive files outside repository
   - Provide example files for templates
   - Clear separation of pre-stack and role files

2. Certificate Handling:
   - Use tmpfs for runtime certificate storage
   - Clear cleanup between test runs
   - Proper permission management
   - Secure distribution method

3. Environment Variables:
   - Centralize in .env file
   - Provide .env.example
   - Quote values with spaces
   - Clear documentation of requirements

4. Error Handling:
   - Comprehensive script error checking
   - Clear error messages
   - Proper exit codes
   - Detailed logging

5. Service Management:
   - Clear startup sequence
   - Proper health checks
   - Adequate wait conditions
   - Clean shutdown process

6. Testing Considerations:
   - Isolation of concerns
   - Clear pre-requisites
   - Proper cleanup
   - Comprehensive verification

## Common Issues to Address

1. Path Management:
   - Use relative paths
   - Handle working directory constraints
   - Consider path length limitations
   - Manage shared resources

2. Resource Conflicts:
   - Handle certificate directory conflicts
   - Manage port allocations
   - Control resource cleanup
   - Handle concurrent access

3. Timing Issues:
   - Service startup order
   - Health check timing
   - Certificate generation sequence
   - Resource availability

4. Permission Problems:
   - Container user permissions
   - Volume mount permissions
   - Certificate file permissions
   - Runtime directory access

## Documentation Requirements

1. Setup Instructions:
   - Prerequisites
   - Environment preparation
   - Test execution
   - Troubleshooting guide

2. Configuration Details:
   - Environment variables
   - File locations
   - Permission requirements
   - Network setup

3. Testing Workflow:
   - Test sequence
   - Verification steps
   - Cleanup procedures
   - Debug processes

4. Maintenance Notes:
   - Update procedures
   - Security considerations
   - Best practices
   - Known limitations

## Conversion Workflow

1. Analysis Phase:
   - Review Docker Compose structure
   - Identify critical components
   - Map dependencies
   - List constraints

2. Planning Phase:
   - Design directory structure
   - Plan resource management
   - Define test sequence
   - Outline error handling

3. Implementation Phase:
   - Create molecule.yml
   - Implement prepare.yml
   - Configure services
   - Set up verification

4. Testing Phase:
   - Verify service startup
   - Test dependencies
   - Check error handling
   - Validate cleanup

5. Documentation Phase:
   - Document setup
   - List requirements
   - Provide examples
   - Include troubleshooting
