FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    ghostscript \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libwebp-dev \
    libzip-dev

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# Cấu hình PHP cho upload file
RUN echo "file_uploads = On\n" \
    "memory_limit = 256M\n" \
    "upload_max_filesize = 100M\n" \
    "post_max_size = 100M\n" \
    "max_execution_time = 600\n" \
    "max_input_time = 600\n" \
    > /usr/local/etc/php/conf.d/uploads.ini

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