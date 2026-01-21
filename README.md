# NixVM PHP 8.3 Development Environment

A complete PHP 8.3 development environment with MariaDB and Caddy, built using Nix and Docker.

## 🚀 Quick Start

### Interactive Installation (Recommended)

```bash
# Run the interactive installer
./install.sh

# Follow the prompts to configure your environment
# The script will generate .env and docker-compose.hub.yml
```

### Manual Setup

#### Option 1: Docker Compose

```bash
# 1. Copy environment file
cp .env.example .env
# Edit .env with your Docker Hub username

# 2. Start all services
docker-compose -f docker-compose.hub.yml up -d

# View logs
docker-compose -f docker-compose.hub.yml logs -f

# Stop services
docker-compose -f docker-compose.hub.yml down
```

#### Option 2: Nix Development

```bash
# Enter development shell
nix develop

# Or use traditional nix-shell
nix-shell
```

## 📋 What's Included

- **PHP 8.3** with extensions: PDO, MySQLi, GD, ZIP, IMAP, Imagick, Mbstring, cURL, Intl, OPcache, Xdebug
- **MariaDB 10.11** database server
- **Caddy 2** web server with automatic HTTPS
- **phpMyAdmin** for database management
- **Xdebug** configured for debugging
- **Composer** for dependency management
- **Development tools** (PHPStan, PHP-CS-Fixer, PHPUnit)

**Note**: The `mcrypt` extension is not available in PHP 8.3 as it was removed from PHP core in PHP 7.2+. Consider using `openssl` or `sodium` extensions instead.

## 🛠️ Installation Script

The `install.sh` script provides a comprehensive interactive setup experience:

### Features
- **100% Interactive**: Prompts for all configuration options
- **Smart Defaults**: Pre-filled values from `.env.example`
- **Validation**: Input validation for domains, emails, ports, etc.
- **SSL Configuration**: Let's Encrypt, custom certs, or self-signed
- **Environment-Specific**: Different options for development/production
- **Progress Tracking**: Visual progress indicators
- **Error Handling**: Graceful failure recovery

### Usage
```bash
./install.sh
```

### What It Configures
- **Docker Hub credentials**
- **Application environment** (development/production)
- **Network ports** with proxy guidance
- **SSL certificates** (Let's Encrypt/custom/self-signed)
- **HTTP→HTTPS redirects**
- **Multi-domain SSL support**
- **Database settings**
- **PHP configuration**
- **Composer settings**

### Generated Files
- **`.env`** - Complete environment configuration
- **`docker/caddy/Caddyfile`** - Web server configuration
- **Updated `docker-compose.hub.yml`** - Ready-to-use Docker setup

## 🐳 Docker Hub Images (NixOS-based)

**All images are built on NixOS for maximum reproducibility and consistency with the NixVM philosophy.**

### Available Images

| Service | Latest Tag | Version Tags | Description |
|---------|------------|--------------|-------------|
| **PHP App + Caddy** | `ghcr.io/btafoya/nixvm:php-app-latest` | `ghcr.io/btafoya/nixvm:php-app-v1.0.0` | Self-contained PHP app with Caddy routing |
| **MariaDB** | `ghcr.io/btafoya/nixvm:mariadb-latest` | `ghcr.io/btafoya/nixvm:mariadb-v1.0.0` | Database server with NixVM config |
| **Caddy** | `ghcr.io/btafoya/nixvm:caddy-latest` | `ghcr.io/btafoya/nixvm:caddy-v1.0.0` | Standalone web server |
| **phpMyAdmin** | `ghcr.io/btafoya/nixvm:phpmyadmin-latest` | `ghcr.io/btafoya/nixvm:phpmyadmin-v1.0.0` | Database management interface |

### Quick Start with Docker Hub Images

```bash
# 1. Copy environment file
cp .env.example .env
# Edit .env with your Docker Hub username

# 2. Start the complete environment
docker-compose -f docker-compose.hub.yml up -d

# 3. Access your application
# - Main app: http://localhost
# - phpMyAdmin: http://localhost:8081 (use profile: --profile phpmyadmin)
# - Standalone Caddy: http://localhost:8080 (use profile: --profile standalone-caddy)
```

### Pull Individual Images

```bash
# Pull NixVM images from GitHub Container Registry
docker pull ghcr.io/btafoya/nixvm:php-app-latest
docker pull ghcr.io/btafoya/nixvm:mariadb-latest
docker pull ghcr.io/btafoya/nixvm:caddy-latest
docker pull ghcr.io/btafoya/nixvm:phpmyadmin-latest
```

### Run Individual Services

```bash
# PHP Application with built-in Caddy
docker run -p 80:80 -p 443:443 ghcr.io/btafoya/nixvm:php-app-latest

# Database only
docker run -p 3306:3306 -e MYSQL_ROOT_PASSWORD=secret ghcr.io/btafoya/nixvm:mariadb-latest

# phpMyAdmin (link to database)
docker run -p 8080:80 \
  -e PMA_HOST=host.docker.internal \
  ghcr.io/btafoya/nixvm:phpmyadmin-latest
```

## 🔄 NixOS-Based Architecture

**Why NixOS for Docker Images?**

NixVM uses NixOS-based Docker images to provide:

- **100% Reproducibility**: Same environment locally and in containers
- **Declarative Configuration**: Infrastructure as code with Nix
- **Version Pinning**: Exact package versions across all environments
- **Consistency**: Local `nix develop` matches container environment
- **Security**: Minimal attack surface with declarative builds

### Development vs Production Parity

```bash
# Local development (Nix)
nix develop                    # Uses flake.nix
composer install              # Same as container

# Container deployment
docker run yourusername/nixvm:php-app-latest  # Uses same flake.nix
```

### Automated Publishing

Images are automatically built and published to `ghcr.io/btafoya/nixvm` via GitHub Actions:

- **Push to `main`**: Publishes `latest` tags
- **Git Tags (`v1.0.0`)**: Publishes versioned tags
- **Pull Requests**: Test builds without publishing
- **Security Scanning**: Automated vulnerability checks

## 🌐 Access Points

- **Main Application**: http://localhost
- **Alternative Domain**: http://dev.nixvm.localhost
- **phpMyAdmin**: http://localhost:8080
- **Database**: localhost:3306

## 🗄️ Database Credentials

```env
DB_HOST=localhost
DB_PORT=3306
DB_NAME=nixvm_dev
DB_USER=nixvm_user
DB_PASSWORD=nixvm_pass
DB_ROOT_PASSWORD=rootpassword
```

## 🛠️ Development Commands

```bash
# Install PHP dependencies
composer install

# Run tests
composer test

# Code analysis
composer analyze

# Code formatting
composer fix

# Development server (alternative to Caddy)
composer dev:serve
```

## 🛠️ Available CLI Tools

The development environment includes a comprehensive set of CLI tools for development:

### **Version Control & GitHub**
```bash
git          # Git version control
gh           # GitHub CLI for pull requests, issues, releases
```

### **File & Archive Management**
```bash
zip          # Create ZIP archives
unzip        # Extract ZIP archives
tar          # Create/extract TAR archives
gzip         # Compress/decompress with gzip
```

### **Text Processing & Search**
```bash
sed          # Stream editor for text manipulation
awk          # Pattern scanning and processing language
grep         # Search text using regular expressions
ripgrep      # Modern, fast grep replacement (rg command)
```

### **File System Utilities**
```bash
find         # Search for files in directory trees
fd           # Modern, fast find replacement (fdfind command)
tree         # Display directory tree structure
bat          # Modern cat with syntax highlighting
```

### **Data Processing**
```bash
jq           # Command-line JSON processor
yq           # Command-line YAML processor
make         # GNU Make for build automation
```

### **System Monitoring**
```bash
htop         # Interactive process viewer
curl         # Transfer data from servers
wget         # Download files from web
```

### **Examples**
```bash
# Search for PHP files containing "TODO"
grep -r "TODO" --include="*.php" .

# Or use ripgrep for faster searching
rg "TODO" -t php

# Find all PHP files modified in last day
find . -name "*.php" -mtime -1

# Or use fd for modern file finding
fd -e php --changed-within 1day

# Pretty print JSON files
jq . config.json

# Extract archives
tar -xzf archive.tar.gz
unzip archive.zip

# Create GitHub pull request
gh pr create --title "My changes" --body "Description"

# Monitor system resources
htop
```

## 📁 Project Structure

```
├── flake.nix              # Nix flake definition
├── shell.nix              # Traditional nix-shell
├── docker-compose.yml     # Docker services
├── composer.json          # PHP dependencies
├── public/                # Web-accessible files
│   └── index.php         # Main application
├── docker/               # Docker configurations
│   ├── caddy/           # Caddy web server config
│   ├── php/             # PHP-FPM config
│   └── mariadb/         # MariaDB init scripts
└── .mpc.json            # MCP server configuration
```

## 🔧 Configuration Files

### PHP Configuration
- `docker/php/php.ini` - PHP settings
- `docker/php/www.conf` - PHP-FPM pool configuration

### Caddy Configuration
- `docker/caddy/Caddyfile` - Web server configuration

### Database
- `docker/mariadb/init.sql` - Database initialization

## 🐛 Debugging

Xdebug is configured and ready:
- **IDE Port**: 9003
- **Mode**: develop,debug
- **Start with request**: enabled

## 📊 Monitoring

```bash
# View service status
docker-compose ps

# View logs
docker-compose logs [service_name]

# Access database directly
docker-compose exec db mariadb -u nixvm_user -p nixvm_pass nixvm_dev
```

## 🔒 Security Notes

### Development Environment
The default setup is configured for development with relaxed security settings:
- Database passwords are visible in configuration files
- HTTPS uses self-signed certificates for localhost
- Detailed error reporting is enabled
- CORS is configured for development
- Debug tools (Xdebug) are active

### Production Deployment
When using Docker Hub images for production:

**✅ Secure Configuration Required:**
- Use environment variables for all secrets (never commit to code)
- Configure proper SSL certificates (Let's Encrypt, custom certs)
- Set `APP_ENV=production` to disable debug features
- Use Docker secrets or external secret management
- Configure proper firewall and network security
- Regular security updates via automated builds

**🔧 Production Environment Variables:**
```bash
# Required for production
APP_ENV=production
MYSQL_ROOT_PASSWORD_FILE=/run/secrets/mysql_root_password
MYSQL_PASSWORD_FILE=/run/secrets/mysql_password

# SSL Configuration (for Caddy)
DOMAIN=yourdomain.com
SSL_EMAIL=admin@yourdomain.com
```

**APP_ENV Functionality:**
- **`APP_ENV=development`**: Debug enabled, errors shown, development tools visible
- **`APP_ENV=production`**: Debug disabled, errors hidden, security features enabled, production SSL

**🚀 Production Docker Compose:**
```yaml
services:
  app:
    image: ghcr.io/btafoya/nixvm:php-app-v1.0.0  # Use versioned tags
    environment:
      - APP_ENV=production
    secrets:
      - mysql_password
    deploy:
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M
```

**⚠️ Important:** Always review and harden security settings before production deployment. The Docker Hub images provide a solid foundation but require proper security configuration for production use.

## 🤝 Contributing

This environment is designed to be easily extensible. Add new services to `docker-compose.yml` or modify the Nix flake for additional tools.

## 📚 Resources

- [PHP 8.3 Documentation](https://www.php.net/docs.php)
- [Caddy Documentation](https://caddyserver.com/docs/)
- [MariaDB Documentation](https://mariadb.com/kb/en/documentation/)
- [Nix Documentation](https://nixos.org/learn.html)</content>
<parameter name="filePath">README.md