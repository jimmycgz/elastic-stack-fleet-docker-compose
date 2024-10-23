# Elastic Stack with Fleet Server

This directory contains the Docker Compose configuration for running Elastic Stack (Elasticsearch, Kibana, and Fleet Server) locally.

## Setup

1. Copy the example environment file:
```bash
cp .env.example .env
```

2. Edit the `.env` file and set secure passwords:
   - `ELASTIC_PASSWORD`: Password for the 'elastic' superuser
   - `KIBANA_PASSWORD`: Password for the 'kibana_system' user
   - Adjust other settings as needed (ports, memory limits, etc.)

3. Start the stack:
```bash
docker compose up -d
```

## Configuration Files

- `.env.example`: Template for environment variables with example values
- `.env`: Your actual environment configuration (do not commit to repository)
- `docker-compose.yml`: Docker Compose configuration
- `kibana.yml`: Kibana configuration

## Environment Variables

See `.env.example` for a complete list of available variables and their descriptions.

Important variables to configure:
- `ELASTIC_PASSWORD`: Set a secure password (min 6 characters)
- `KIBANA_PASSWORD`: Set a secure password (min 6 characters)
- `MEM_LIMIT`: Adjust based on your system's available memory
- `STACK_VERSION`: Elastic Stack version to use

## Security Notes

1. Never commit `.env` file with actual passwords to version control
2. Use strong passwords in production environments
3. Consider using secrets management in production

## Services

- Elasticsearch: `https://localhost:9200`
- Kibana: `https://localhost:5601`
- Fleet Server: `https://localhost:8220`

## Additional Documentation

- [Agent Installation Manual](Agent-install-manual.md)
- [ELK Cloud Setup](ELK-Cloud.md)
- [Pre-configuration Guide](Pre-config.md)
