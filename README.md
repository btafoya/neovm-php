# NixVM PHP 8.3 Development Environment

[![CI/CD](https://github.com/btafoya/neovm-php/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/btafoya/neovm-php/actions/workflows/docker-publish.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Docker Images](https://img.shields.io/badge/Docker-GHCR-blue.svg)](https://github.com/btafoya/neovm-php/pkgs/container/neovm-php)
[![PHP Version](https://img.shields.io/badge/PHP-8.4-blue.svg)](https://www.php.net/)
[![PHP Version](https://img.shields.io/badge/PHP-8.3-blue.svg)](https://www.php.net/)
[![PHP Version](https://img.shields.io/badge/PHP-8.2-blue.svg)](https://www.php.net/)
[![Nix](https://img.shields.io/badge/Nix-Enabled-5277C3.svg)](https://nixos.org/)

[![GitHub stars](https://img.shields.io/github/stars/btafoya/neovm-php.svg)](https://github.com/btafoya/neovm-php/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/btafoya/neovm-php.svg)](https://github.com/btafoya/neovm-php/network)
[![GitHub issues](https://img.shields.io/github/issues/btafoya/neovm-php.svg)](https://github.com/btafoya/neovm-php/issues)

<p align="center">
  <img src="https://img.shields.io/badge/PHP-8.4-777BB4?style=for-the-badge&logo=php&logoColor=white" alt="PHP 8.4"/>
  <img src="https://img.shields.io/badge/PHP-8.3-777BB4?style=for-the-badge&logo=php&logoColor=white" alt="PHP 8.3"/>
  <img src="https://img.shields.io/badge/PHP-8.2-777BB4?style=for-the-badge&logo=php&logoColor=white" alt="PHP 8.2"/>
  <img src="https://img.shields.io/badge/MariaDB-10.11-003545?style=for-the-badge&logo=mariadb&logoColor=white" alt="MariaDB 10.11"/>
  <img src="https://img.shields.io/badge/Caddy-2.0-1F88C7?style=for-the-badge&logo=caddy&logoColor=white" alt="Caddy 2.0"/>
  <img src="https://img.shields.io/badge/NixOS-Enabled-5277C3?style=for-the-badge&logo=nixos&logoColor=white" alt="NixOS"/>
  <img src="https://img.shields.io/badge/Docker-Enabled-2496ED?style=for-the-badge&logo=docker&logoColor=white" alt="Docker"/>
</p>

A complete PHP production and development environment with MariaDB and Caddy, built using Nix for reproducible builds and Docker for containerization.

## 📦 Container Images

[![Container Registry](https://img.shields.io/badge/Container-GHCR-2496ED.svg)](https://github.com/btafoya/neovm-php/pkgs/container/neovm-php)
[![CI Status](https://img.shields.io/github/actions/workflow/status/btafoya/neovm-php/docker-publish.yml)](https://github.com/btafoya/neovm-php/actions/workflows/docker-publish.yml)

### Available Images
- `ghcr.io/btafoya/neovm-php:php-app-latest` - PHP + Caddy application server
- `ghcr.io/btafoya/neovm-php:mariadb-latest` - MariaDB 10.11 database
- `ghcr.io/btafoya/neovm-php:caddy-latest` - Standalone Caddy web server
- `ghcr.io/btafoya/neovm-php:phpmyadmin-latest` - phpMyAdmin database manager

## 🛠️ Tech Stack & Features

[![Nix Flake](https://img.shields.io/badge/Nix-Flake-5277C3.svg)](https://nixos.org/)
[![GitHub Actions](https://img.shields.io/badge/CI-CD-GitHub%20Actions-2088FF.svg)](https://github.com/features/actions)
[![GitHub Container Registry](https://img.shields.io/badge/Registry-GHCR-2496ED.svg)](https://ghcr.io)
[![Interactive Install](https://img.shields.io/badge/Install-Interactive-FF6B35.svg)](./install.sh)

### Key Features
- 🔒 **Reproducible Builds** - Nix ensures identical environments
- 🐳 **Container Ready** - Pre-built Docker images on GHCR
- ⚡ **Fast Setup** - Interactive installer configures everything
- 🔧 **Development Focused** - Xdebug, error reporting, hot reload
- 🔄 **Production Ready** - Environment-specific configurations
- 📊 **Health Monitoring** - Built-in health checks and logging

## 🤝 Contributing & Community

[![Contributors](https://img.shields.io/github/contributors/btafoya/neovm-php.svg)](https://github.com/btafoya/neovm-php/graphs/contributors)
[![GitHub last commit](https://img.shields.io/github/last-commit/btafoya/neovm-php.svg)](https://github.com/btafoya/neovm-php/commits/main)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/btafoya/neovm-php/blob/main/CONTRIBUTING.md)

### How to Contribute
- 🐛 **Report Issues** - Found a bug? [Open an issue](https://github.com/btafoya/neovm-php/issues)
- 💡 **Suggest Features** - Have an idea? [Start a discussion](https://github.com/btafoya/neovm-php/discussions)
- 🔧 **Contribute Code** - See our [contributing guide](./CONTRIBUTING.md)
- 📖 **Improve Docs** - Help make documentation better

## 🚀 Quick Start

### One-Line Installation (No Git Clone Required)

The easiest way to get started is to run the installer directly from GitHub:

```bash
# Download and run installer interactively (installs to current directory)
curl -sSL https://raw.githubusercontent.com/btafoya/neovm-php/main/install.sh | bash

# Install to a specific directory
curl -sSL https://raw.githubusercontent.com/btafoya/neovm-php/main/install.sh | bash -s -- --dir /path/to/project

# For forks, specify REPO_URL
REPO_URL=https://raw.githubusercontent.com/YOURUSER/yourrepo/branch \
  curl -sSL https://raw.githubusercontent.com/YOURUSER/yourrepo/branch/install.sh | bash
```

The installer will:
1. Download required configuration files from GitHub
2. Prompt you for configuration options interactively
3. Generate `.env`, `Caddyfile`, and Docker configs
4. Start your development environment

### Interactive Installation (From Repository)

```bash
# Option 1: Run from cloned repository
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

- **PHP 8.4, 8.3, 8.2** with extensions: PDO, MySQLi, GD, ZIP, IMAP, Imagick, Mbstring, cURL, Intl, OPcache, Xdebug
- **MariaDB 10.11** database server
- **Caddy 2** web server with automatic HTTPS
- **phpMyAdmin** for database management
- **Xdebug** configured for debugging
- **Composer** for dependency management
- **Development tools** (PHPStan, PHP-CS-Fixer, PHPUnit)

**Note**: The `mcrypt` extension is not available in PHP 8 as it was removed from PHP core in PHP 7.2+. Consider using `openssl` or `sodium` extensions instead.

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
| **PHP App + Caddy** | `ghcr.io/btafoya/neovm-php:php-app-latest` | `ghcr.io/btafoya/neovm-php:php-app-v1.0.0` | Self-contained PHP app with Caddy routing |
| **MariaDB** | `ghcr.io/btafoya/neovm-php:mariadb-latest` | `ghcr.io/btafoya/neovm-php:mariadb-v1.0.0` | Database server with NixVM config |
| **Caddy** | `ghcr.io/btafoya/neovm-php:caddy-latest` | `ghcr.io/btafoya/neovm-php:caddy-v1.0.0` | Standalone web server |
| **phpMyAdmin** | `ghcr.io/btafoya/neovm-php:phpmyadmin-latest` | `ghcr.io/btafoya/neovm-php:phpmyadmin-v1.0.0` | Database management interface |

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
docker pull ghcr.io/btafoya/neovm-php:php-app-latest
docker pull ghcr.io/btafoya/neovm-php:mariadb-latest
docker pull ghcr.io/btafoya/neovm-php:caddy-latest
docker pull ghcr.io/btafoya/neovm-php:phpmyadmin-latest
```

### Run Individual Services

```bash
# PHP Application with built-in Caddy
docker run -p 80:80 -p 443:443 ghcr.io/btafoya/neovm-php:php-app-latest

# Database only
docker run -p 3306:3306 -e MYSQL_ROOT_PASSWORD=secret ghcr.io/btafoya/neovm-php:mariadb-latest

# phpMyAdmin (link to database)
docker run -p 8080:80 \
  -e PMA_HOST=host.docker.internal \
  ghcr.io/btafoya/neovm-php:phpmyadmin-latest
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

Images are automatically built and published to `ghcr.io/btafoya/neovm-php` via GitHub Actions:

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
    image: ghcr.io/btafoya/neovm-php:php-app-v1.0.0  # Use versioned tags
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

- [PHP Documentation](https://www.php.net/docs.php)
- [Caddy Documentation](https://caddyserver.com/docs/)
- [MariaDB Documentation](https://mariadb.com/kb/en/documentation/)
- [Nix Documentation](https://nixos.org/learn.html)

---

## 🙏 Acknowledgments

Built with ❤️ using cutting-edge open source technologies.

[![Powered by Nix](https://img.shields.io/badge/Powered%20by-Nix-5277C3.svg)](https://nixos.org/)
[![Made with PHP](https://img.shields.io/badge/Made%20with-PHP-777BB4.svg)](https://php.net/)
[![Containerized with Docker](https://img.shields.io/badge/Containerized%20with-Docker-2496ED.svg)](https://docker.com/)

### Technologies Used
<p align="center">
  <a href="https://nixos.org/"><img src="https://img.shields.io/badge/NixOS-5277C3?style=flat-square&logo=nixos&logoColor=white" alt="NixOS"/></a>
  <a href="https://www.php.net/"><img src="https://img.shields.io/badge/PHP-777BB4?style=flat-square&logo=php&logoColor=white" alt="PHP"/></a>
  <a href="https://mariadb.com/"><img src="https://img.shields.io/badge/MariaDB-003545?style=flat-square&logo=mariadb&logoColor=white" alt="MariaDB"/></a>
  <a href="https://caddyserver.com/"><img src="https://img.shields.io/badge/Caddy-1F88C7?style=flat-square&logo=caddy&logoColor=white" alt="Caddy"/></a>
  <a href="https://www.docker.com/"><img src="https://img.shields.io/badge/Docker-2496ED?style=flat-square&logo=docker&logoColor=white" alt="Docker"/></a>
  <a href="https://github.com/features/actions"><img src="https://img.shields.io/badge/GitHub_Actions-2088FF?style=flat-square&logo=github-actions&logoColor=white" alt="GitHub Actions"/></a>
</p>

### Repository Links
<p align="center">
  <a href="https://github.com/btafoya/neovm-php"><img src="https://img.shields.io/badge/GitHub-Repository-181717?style=flat-square&logo=github&logoColor=white" alt="GitHub Repository"/></a>
  <a href="https://github.com/btafoya/neovm-php/issues"><img src="https://img.shields.io/badge/Issues-Report_Bug-red?style=flat-square&logo=github&logoColor=white" alt="Report Issues"/></a>
  <a href="https://github.com/btafoya/neovm-php/discussions"><img src="https://img.shields.io/badge/Discussions-Q&A-blue?style=flat-square&logo=github&logoColor=white" alt="Discussions"/></a>
  <a href="https://github.com/btafoya/neovm-php/pkgs/container/neovm-php"><img src="https://img.shields.io/badge/Container_Registry-GHCR-2496ED?style=flat-square&logo=github&logoColor=white" alt="Container Registry"/></a>
</p>

---

<div align="center">

**🚀 Happy coding with NixVM! 🚀**

*Built for developers, by developers*

</div></content>
<parameter name="filePath">README.md