# Docker Setup Guide

This guide explains how to set up a PHP project with Nginx using Docker Compose.

## Prerequisites

- Docker and Docker Compose installed on your system
- Basic understanding of Docker concepts
- Project source code

## Setup Instructions

### 1. Project Structure

First, copy your source code into the `/projects` directory:
```bash
cp -r /path/to/your/source/code /projects/
```

### 2. Configuration and Deployment

Run the following commands to configure and deploy your application:

```bash
# Stop any running containers
docker compose down

# Generate Nginx configuration
./create-nginx-conf.sh <project_name> <port> <php_version>

# Start containers in detached mode
docker compose up -d
```

#### Parameters Explanation:
- `<project_name>`: Name of your project directory (e.g., 'erp')
- `<port>`: Port number for the web server (e.g., '8080')
- `<php_version>`: PHP version to use (e.g., '7.4')

#### Example:
```bash
./create-nginx-conf.sh erp 8080 7.4
```

This command will:
1. Create Nginx configuration for project 'erp'
2. Configure the server to listen on port 8080
3. Use PHP version 7.4

## Directory Structure

```
/
├── projects/
│   └── your_project_name/
├── create-nginx-conf.sh
├── docker-compose.yml
└── README.md
```

## Verification

After running the commands:
1. Check if containers are running:
   ```bash
   docker compose ps
   ```

2. Access your application:
   ```
   http://localhost:<specified_port>
   ```

## Troubleshooting

If you encounter issues:

1. Check container logs:
   ```bash
   docker compose logs
   ```

2. Verify Nginx configuration:
   ```bash
   docker compose exec nginx nginx -t
   ```

3. Ensure ports are not already in use:
   ```bash
   netstat -tulpn | grep <port_number>
   ```

## Additional Notes

- Make sure your project has appropriate permissions
- The PHP version specified must be supported by the Docker image
- Port conflicts will prevent successful deployment

## Support

For additional support or to report issues, please contact the system administrator or create an issue in the project repository.