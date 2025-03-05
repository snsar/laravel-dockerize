FROM php:7.4-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u 1000 -d /home/www www
RUN mkdir -p /home/www/.composer && \
    chown -R www:www-data /home/www

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/projects

# Copy existing application directory permissions
COPY --chown=www:www-data . /var/www/projects

# Change current user to www
USER www