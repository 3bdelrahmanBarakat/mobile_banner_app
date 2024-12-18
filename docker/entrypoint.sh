#!/bin/sh
set -e

# Run migrations and cache
php artisan migrate --force
php artisan config:cache
php artisan route:cache

# Start the application
exec "$@"
