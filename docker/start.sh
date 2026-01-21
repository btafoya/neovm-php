#!/bin/bash

#!/bin/bash

# Environment-based configuration selector for NixVM PHP App

# Default to development if not set
APP_ENV=${APP_ENV:-development}
DOMAIN=${DOMAIN:-localhost}
SSL_EMAIL=${SSL_EMAIL:-admin@localhost}

echo "🚀 Starting NixVM PHP Application"
echo "📍 Environment: $APP_ENV"
echo "🌐 Domain: $DOMAIN"

# Select PHP configuration based on environment
if [ "$APP_ENV" = "production" ]; then
    echo "🔒 Production mode: Using secure PHP configuration"
    cp /usr/local/etc/php/php.ini.production /usr/local/etc/php/php.ini
else
    echo "🔧 Development mode: Using development PHP configuration"
    cp /usr/local/etc/php/php.ini.development /usr/local/etc/php/php.ini 2>/dev/null || echo "Using default development config"
fi

# Select Caddy configuration based on environment
if [ "$APP_ENV" = "production" ]; then
    echo "🔒 Production mode: Using production Caddy configuration"
    cp /etc/caddy/Caddyfile.production /etc/caddy/Caddyfile
else
    echo "🔧 Development mode: Using development Caddy configuration"
    cp /etc/caddy/Caddyfile.development /etc/caddy/Caddyfile 2>/dev/null || echo "Using default development Caddy config"
fi

# Set Caddy environment variables for production
if [ "$APP_ENV" = "production" ]; then
    export DOMAIN="$DOMAIN"
    export SSL_EMAIL="$SSL_EMAIL"
fi

# Create necessary directories
mkdir -p /var/run/php-fpm /var/log/supervisor

# Start PHP-FPM and Caddy via supervisord
echo "📦 Starting services..."
exec supervisord -c /etc/supervisord.conf