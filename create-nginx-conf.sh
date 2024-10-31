#!/bin/bash

# Directory for nginx configurations
NGINX_CONF_DIR="nginx/conf.d"

# Create nginx config directory if not exists
mkdir -p $NGINX_CONF_DIR

# Function to validate port number
validate_port() {
    local port=$1
    if ! [[ "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
        echo "Error: Invalid port number. Port must be between 1 and 65535."
        exit 1
    fi
}

# Function to validate PHP version
validate_php_version() {
    local version=$1
    if ! [[ "$version" =~ ^[0-9]+\.[0-9]+$ ]]; then
        echo "Error: Invalid PHP version format. Use format like '8.2'"
        exit 1
    fi
}

# Function to update docker-compose ports
update_docker_compose() {
    local project_name=$1
    local port=$2
    local php_version=$3
    local temp_file=$(mktemp)
    local php_container="php${php_version/./}"

    # Read the current docker-compose.yml
    if [ ! -f "docker-compose.yml" ]; then
        echo "Error: docker-compose.yml not found"
        exit 1
    fi

    # Create updated docker-compose.yml content
    awk -v port="$port" -v project="$project_name" -v php="$php_version" '
    {
        # Print the current line
        print $0
        
        # If we find the ports: line under nginx service
        if ($0 ~ /^\s*ports:/ && prev ~ /container_name: nginx-proxy/) {
            # Add the new port mapping if it doesnt exist
            if (system("grep -q \"" port ":" port "\" docker-compose.yml") != 0) {
                printf "      - \"%s:%s\"  # %s - PHP %s\n", port, port, project, php
            }
        }
    }
    { prev = $0 }
    ' docker-compose.yml > "$temp_file"

    # Replace the original file
    mv "$temp_file" docker-compose.yml
}

# Function to add new project configuration
add_project() {
    local project_name=$1
    local port=$2
    local php_version=$3
    local php_container="php${php_version/./}"
    local conf_file="$NGINX_CONF_DIR/${project_name}.conf"

    # Validate inputs
    validate_port "$port"
    validate_php_version "$php_version"

    # Create new nginx configuration file for the project
    cat > "$conf_file" <<EOF
server {
    listen $port;
    server_name localhost;
    root /var/www/projects/$project_name/public;
    index index.php index.html;

    charset utf-8;
    client_max_body_size 100M;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass $php_container:9000;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_index index.php;
        fastcgi_buffers 16 16k;
        fastcgi_buffer_size 32k;
        fastcgi_read_timeout 600;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }

    # Performance and security headers
    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Content-Type-Options "nosniff";
    add_header Referrer-Policy "strict-origin-when-cross-origin";
    add_header Content-Security-Policy "default-src 'self' 'unsafe-inline' 'unsafe-eval' data: *.googleapis.com *.gstatic.com; img-src 'self' data: https:; font-src 'self' data: https:;";

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied expired no-cache no-store private auth;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml application/javascript;
    gzip_disable "MSIE [1-6]\.";
}
EOF

    echo "Created nginx configuration for $project_name (PHP $php_version) on port $port"
    echo "Configuration file: $conf_file"

    # Update docker-compose.yml
    update_docker_compose "$project_name" "$port" "$php_version"
    echo "Updated docker-compose.yml with port $port"
}

# Check arguments
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 project_name port php_version"
    echo "Example: $0 myproject 8001 8.2"
    exit 1
fi

add_project "$1" "$2" "$3"

echo "Setup complete! Don't forget to:"
echo "1. Restart your Docker containers with: docker-compose down && docker-compose up -d"
echo "2. Access your project at http://localhost:$2"