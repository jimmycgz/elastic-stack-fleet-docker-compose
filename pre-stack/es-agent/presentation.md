---
marp: true
theme: default
paginate: true
---

# Elastic Stack Agent Deployment
## Development to Production Pipeline

---

# Agenda

1. Inner Loop vs Outer Loop Development
2. Dev Container Benefits
3. Ansible Design Patterns
4. ES-Agent Role Implementation
5. Demo

---

# Inner Loop vs Outer Loop

## Inner Loop
- Local development environment
- Rapid iterations
- Quick feedback
- Dev Container environment
- Local testing with Molecule

## Outer Loop
- CI/CD pipeline
- GitHub Actions
- Production deployment
- Integration testing
- Release management

---

# Benefits of Dev Container

## Consistency
- Same environment for all developers
- Matches production configuration
- Eliminates "works on my machine"

## Pre-configured Tools
- Ansible
- Docker
- Python dependencies
- VSCode extensions

## Quick Start
```bash
# Just two commands to start
git clone <repo>
code <repo>  # VSCode auto-configures everything
```

---

# Dev Container vs GitHub Actions

## Dev Container (Local)
- Rapid development
- Instant feedback
- Local debugging
- Resource efficient

## GitHub Actions (CI)
- Automated testing
- Integration checks
- Release validation
- Production deployment

---

# Ansible Design Patterns

## Role-Based Architecture
```
ansible/
├── roles/
│   └── es-agent/
├── molecule/
└── playbook.yml
```

## Centralized Testing
- Molecule for all roles
- Consistent test environment
- Reusable test scenarios

---

# ES-Agent Role Design

## Key Features
- Distribution-aware (Ubuntu/Debian)
- Idempotent operations
- Automated enrollment
- Existing installation detection

## Structure
```
es-agent/
├── tasks/
│   ├── main.yml
│   ├── agent-setup-common.yml
│   ├── agent-setup-ubuntu.yml
│   └── agent-setup-debian.yml
└── vars/
    └── main.yml
```

---

# Role Implementation Details

## Common Tasks
- Dependency management
- Token retrieval
- Policy creation

## Distribution-Specific
- Ubuntu: Native installer
- Debian: Manual installation
- Custom verification

---

# Testing Strategy

## Molecule Tests
```yaml
platforms:
  - name: ag-ubuntu
    image: ubuntu:20.04
  - name: ag-debian
    image: debian:11
```

## Test Scenarios
1. Fresh installation
2. Existing installation
3. Network connectivity
4. Token management

---

# Local Development Flow

1. Edit role in Dev Container
2. Run Molecule tests
3. Debug with step-by-step testing
4. Verify in Docker Compose
5. Commit changes

---

# Production Deployment Flow

1. Push to GitHub
2. GitHub Actions runs tests
3. Molecule tests in CI
4. Integration tests
5. Release tagging

---

# Demo

## Local Development
1. Dev Container setup
2. Role development
3. Molecule testing

## Deployment
1. Docker Compose
2. Agent enrollment
3. Fleet management

---

# Key Achievements

1. Consistent development environment
2. Automated testing
3. Distribution-aware deployment
4. Idempotent operations
5. Production-ready solution

---

# Questions?

Contact:
- Repository: [GitHub Link]
- Documentation: See README.md
- Issues: GitHub Issues
