FROM php:7.4-fpm-alpine

# Install system dependencies, PHP extensions and setup user
RUN apk add --no-cache \
    git \
    curl \
    libpng-dev \
    oniguruma-dev \
    libxml2-dev \
    zip \
    unzip \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd \
    && addgroup -g 1000 www \
    && adduser -u 1000 -G www -h /home/www -s /bin/sh -D www

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory  
WORKDIR /var/www/projects

# Copy existing application directory permissions
COPY --chown=www:www . /var/www/projects

# Change current user to www
USER www