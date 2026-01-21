#!/usr/bin/env bash
# NixVM Docker Hub Setup Script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 NixVM Docker Hub Setup${NC}"
echo ""

# Check if .env exists
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}📋 Creating .env file from template...${NC}"
    cp .env.example .env
    echo -e "${GREEN}✅ Created .env file${NC}"
    echo -e "${YELLOW}⚠️  Please edit .env with your Docker Hub username${NC}"
    echo ""
fi

# Check if Docker Hub username is set
if ! grep -q "^DOCKERHUB_USERNAME=" .env 2>/dev/null || grep -q "^DOCKERHUB_USERNAME=your_dockerhub_username" .env 2>/dev/null; then
    echo -e "${YELLOW}⚠️  Docker Hub username not set, using default: btafoya${NC}"
    echo "DOCKERHUB_USERNAME=btafoya" >> .env
fi

# Load environment variables
set -a
source .env
set +a

echo -e "${BLUE}🔍 Checking Docker installation...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed or not in PATH${NC}"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ docker-compose is not installed or not in PATH${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker and docker-compose are available${NC}"

echo ""
echo -e "${BLUE}🐳 Testing Docker Hub connectivity...${NC}"

# Test if we can pull a small test image
if docker pull hello-world &> /dev/null; then
    echo -e "${GREEN}✅ Docker Hub connectivity confirmed${NC}"
else
    echo -e "${RED}❌ Cannot connect to Docker Hub${NC}"
    echo "   Check your internet connection and Docker configuration"
    exit 1
fi

echo ""
echo -e "${BLUE}🔄 Pulling NixVM images from Docker Hub...${NC}"

# Pull images
services=("php-app" "mariadb" "caddy" "phpmyadmin")

for service in "${services[@]}"; do
    image="${DOCKERHUB_USERNAME}/nixvm:${service}-latest"
    echo -e "${YELLOW}📥 Pulling ${image}...${NC}"

    if docker pull "${image}" 2>/dev/null; then
        echo -e "${GREEN}✅ Successfully pulled ${image}${NC}"
    else
        echo -e "${RED}❌ Failed to pull ${image}${NC}"
        echo -e "${YELLOW}   This might be normal if you haven't published the images yet${NC}"
        echo -e "${YELLOW}   You can build locally with: docker-compose -f docker-compose.hub.yml build${NC}"
    fi
done

echo ""
echo -e "${BLUE}🎯 Setup complete!${NC}"
echo ""
echo -e "${GREEN}To start the environment:${NC}"
echo "  docker-compose -f docker-compose.hub.yml up -d"
echo ""
echo -e "${GREEN}To start with phpMyAdmin:${NC}"
echo "  docker-compose -f docker-compose.hub.yml --profile phpmyadmin up -d"
echo ""
echo -e "${GREEN}To access the application:${NC}"
echo "  • Main app: http://localhost"
echo "  • phpMyAdmin: http://localhost:8081"
echo "  • Standalone Caddy: http://localhost:8080"
echo ""
echo -e "${YELLOW}Note: If images failed to pull, they haven't been published yet.${NC}"
echo -e "${YELLOW}      The images will be published to: https://hub.docker.com/r/btafoya/nixvm${NC}"
echo -e "${YELLOW}      Push to main branch or create a tag to trigger automated publishing.${NC}"