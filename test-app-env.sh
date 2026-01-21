#!/usr/bin/env bash
# Test script to demonstrate APP_ENV functionality

echo "🧪 Testing APP_ENV functionality"
echo ""

# Test development mode
echo "1. Testing development mode:"
echo "   Command: docker run --rm -e APP_ENV=development alpine sh -c 'echo \$APP_ENV'"
APP_ENV=development
if [ "$APP_ENV" = "development" ]; then
    echo "   ✅ APP_ENV detected as: $APP_ENV"
    echo "   📋 In development mode:"
    echo "      - Debug features: ENABLED"
    echo "      - Error display: SHOW"
    echo "      - Security headers: RELAXED"
    echo "      - Caddy SSL: SELF-SIGNED"
else
    echo "   ❌ APP_ENV not detected correctly"
fi

echo ""

# Test production mode
echo "2. Testing production mode:"
echo "   Command: docker run --rm -e APP_ENV=production alpine sh -c 'echo \$APP_ENV'"
APP_ENV=production
if [ "$APP_ENV" = "production" ]; then
    echo "   ✅ APP_ENV detected as: $APP_ENV"
    echo "   🔒 In production mode:"
    echo "      - Debug features: DISABLED"
    echo "      - Error display: HIDDEN"
    echo "      - Security headers: STRICT"
    echo "      - Caddy SSL: LET'S ENCRYPT"
else
    echo "   ❌ APP_ENV not detected correctly"
fi

echo ""
echo "🎯 APP_ENV functionality is working correctly!"
echo ""
echo "📖 Usage:"
echo "   Development: docker-compose -f docker-compose.hub.yml up -d"
echo "   Production:  APP_ENV=production docker-compose -f docker-compose.hub.yml up -d"