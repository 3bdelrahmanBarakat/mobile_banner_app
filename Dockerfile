# Base PHP-FPM Image
FROM php:8.2-fpm as base

# Install required system dependencies
RUN apt-get update && apt-get install -y \
    libzip-dev \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    unzip \
    git \
    curl \
    nginx \
    && docker-php-ext-install zip pdo pdo_mysql mbstring

# Set working directory
WORKDIR /var/www/html

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy Laravel application source code
COPY . .

# Install PHP dependencies
RUN composer install --optimize-autoloader --no-dev

# Laravel permissions and directories
RUN mkdir -p storage/logs bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache \
    && chown -R www-data:www-data /var/www/html

# Multi-stage build: Node.js for frontend assets
FROM node:18 as node_build

WORKDIR /app

COPY . .
COPY --from=base /var/www/html/vendor /app/vendor

# Install frontend dependencies and build assets
RUN if [ -f "vite.config.js" ]; then \
        npm install && npm run build; \
    elif [ -f "package-lock.json" ]; then \
        npm install && npm run production; \
    else \
        echo "No frontend build steps found."; \
    fi

# Final Image with NGINX and PHP-FPM
FROM base

# Copy built static assets
COPY --from=node_build /app/public /var/www/html/public

# Copy NGINX configuration
COPY ./docker/nginx.conf /etc/nginx/conf.d/default.conf

# Copy entrypoint script
COPY ./docker/entrypoint.sh /entrypoint
RUN chmod +x /entrypoint

# Expose port
EXPOSE 8080

# Start NGINX and PHP-FPM
ENTRYPOINT ["/entrypoint"]
