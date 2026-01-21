#!/bin/bash

# NixVM Interactive Install Script
# Comprehensive setup for PHP + MariaDB + Caddy development environment
#
# Usage:
#   ./install.sh                     # Run in current directory
#   ./install.sh --dir /path/to/dir  # Install to specific directory
#
# One-line installation (no git clone required):
#   curl -sSL https://raw.githubusercontent.com/btafoya/neovm-php/main/install.sh | bash
#   curl -sSL https://raw.githubusercontent.com/btafoya/neovm-php/main/install.sh | bash -s -- --dir /path/to/project
#
# For forks:
#   REPO_URL=https://raw.githubusercontent.com/YOURUSER/yourrepo/branch curl -sSL https://raw.githubusercontent.com/YOURUSER/yourrepo/branch/install.sh | bash

set -euo pipefail

# Configuration variables
SCRIPT_VERSION="1.1.0"
REQUIRED_TOOLS=("curl" "git")
OPTIONAL_TOOLS=("docker" "docker-compose")

# Default values from .env.example
DEFAULT_DOCKERHUB_USERNAME="btafoya"
DEFAULT_PORT="8080"
DEFAULT_PHP_VERSION="8.4"
DEFAULT_APP_ENV="development"
DEFAULT_MYSQL_ROOT_PASSWORD="rootpassword"
DEFAULT_MYSQL_DATABASE="nixvm_dev"
DEFAULT_MYSQL_USER="nixvm_user"
DEFAULT_MYSQL_PASSWORD="nixvm_pass"
DEFAULT_PHP_MEMORY_LIMIT="256M"
DEFAULT_PHP_UPLOAD_MAX_FILESIZE="100M"
DEFAULT_PHP_POST_MAX_SIZE="100M"
DEFAULT_COMPOSER_ALLOW_SUPERUSER="1"
DEFAULT_COMPOSER_MEMORY_LIMIT="-1"

# Installation directory
INSTALL_DIR=""
ORIGINAL_DIR="$(pwd)"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Repository configuration for file downloads
REPO_URL="${REPO_URL:-https://raw.githubusercontent.com/btafoya/neovm-php/main}"

# Files to download from repository
REPO_FILES=(
    ".env.example"
    "docker-compose.hub.yml"
    "docker/caddy/Caddyfile"
    "docker/php/www.conf"
    "docker/mariadb/init.sql"
)

# Progress tracking
CURRENT_STEP=0
TOTAL_STEPS=16
IS_STANDALONE=false

# Utility functions
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dir)
                INSTALL_DIR="$2"
                if [ -z "$INSTALL_DIR" ]; then
                    print_error "Error: --dir requires a path argument"
                    exit 1
                fi
                shift 2
                ;;
            --help|-h)
                echo "NixVM Interactive Installer v${SCRIPT_VERSION}"
                echo ""
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --dir PATH    Install to specified directory (creates if needed)"
                echo "  --help, -h    Show this help message"
                echo ""
                echo "One-line installation:"
                echo "  curl -sSL https://raw.githubusercontent.com/btafoya/neovm-php/main/install.sh | bash"
                echo "  curl -sSL https://raw.githubusercontent.com/btafoya/neovm-php/main/install.sh | bash -s -- --dir /path/to/project"
                echo ""
                echo "For forks:"
                echo "  REPO_URL=https://raw.githubusercontent.com/YOURUSER/yourrepo/branch \\"
                echo "    curl -sSL https://raw.githubusercontent.com/YOURUSER/yourrepo/branch/install.sh | bash"
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
}

download_file() {
    local remote_path="$1"
    local local_path="$2"
    local max_retries=3
    local retry=1
    local download_url="${REPO_URL}/${remote_path}"

    while [ $retry -le $max_retries ]; do
        if curl -fsSL --connect-timeout 30 --max-time 120 "$download_url" -o "$local_path" 2>/dev/null; then
            return 0
        fi
        print_warning "Download attempt $retry/$max_retries failed: $remote_path"
        retry=$((retry + 1))
        if [ $retry -le $max_retries ]; then
            sleep 2
        fi
    done

    print_error "Failed to download: $remote_path after $max_retries attempts"
    return 1
}

download_all_files() {
    print_step "📥 Downloading NixVM configuration files from GitHub..."

    for file in "${REPO_FILES[@]}"; do
        local local_file="${INSTALL_DIR:-.}/${file}"
        local local_dir
        local_dir=$(dirname "$local_file")

        if [ ! -f "$local_file" ]; then
            mkdir -p "$local_dir"
            if download_file "$file" "$local_file"; then
                print_success "Downloaded: $file"
            else
                print_error "Failed to download: $file"
                return 1
            fi
        else
            print_info "Using existing: $file"
        fi
    done

    print_success "All configuration files downloaded successfully"
    return 0
}

check_and_download_files() {
    if [ ! -f ".env.example" ] && [ ! -f "docker-compose.hub.yml" ]; then
        IS_STANDALONE=true
        echo ""
        print_info "Running from standalone installer - required files will be downloaded from GitHub"
        echo ""

        if ! download_all_files; then
            print_error "Failed to download required files. Please check your network connection."
            print_info "You can also clone the repository manually:"
            echo "  git clone https://github.com/btafoya/nixvm.git"
            exit 1
        fi
        echo ""
    else
        IS_STANDALONE=false
    fi
}

change_to_install_dir() {
    if [ -n "$INSTALL_DIR" ]; then
        if [ ! -d "$INSTALL_DIR" ]; then
            print_step "📁 Creating installation directory: $INSTALL_DIR"
            mkdir -p "$INSTALL_DIR"
        fi

        if [ "$(pwd)" != "$INSTALL_DIR" ]; then
            print_info "Changing to installation directory: $INSTALL_DIR"
            cd "$INSTALL_DIR"
        fi
    fi
}

show_progress() {
    local current=$1
    local message=$2
    printf "\r[%-${PROGRESS_WIDTH:-50}s] %d/%d %s" \
        "$(printf '%.0s=' $(seq 1 $((current * PROGRESS_WIDTH / TOTAL_STEPS))))" \
        "$current" "$TOTAL_STEPS" "$message"
}

print_header() {
    local php_version="${PHP_VERSION:-8.4}"
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                 🚀 NixVM Interactive Installer              ║${NC}"
    echo -e "${BLUE}║              PHP ${php_version} + MariaDB + Caddy Setup                ║${NC}"
    echo -e "${BLUE}║                      Version $SCRIPT_VERSION                     ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_step() {
    echo -e "${CYAN}➤ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${PURPLE}ℹ️  $1${NC}"
}

# Validation functions
validate_domain() {
    local domain="$1"
    if [[ $domain =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]] || [ "$domain" = "localhost" ]; then
        return 0
    else
        return 1
    fi
}

validate_email() {
    local email="$1"
    if [[ $email =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        return 0
    else
        return 1
    fi
}

validate_memory() {
    local memory="$1"
    if [[ $memory =~ ^[0-9]+[MG]$ ]]; then
        return 0
    else
        return 1
    fi
}

validate_port() {
    local port="$1"
    if ! [[ "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
        return 1
    fi
    return 0
}

# System checks
check_requirements() {
    print_step "Checking system requirements..."

    local missing_required=()
    local missing_optional=()

    # Check required tools
    for tool in "${REQUIRED_TOOLS[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            missing_required+=("$tool")
        fi
    done

    # Check optional tools
    for tool in "${OPTIONAL_TOOLS[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            missing_optional+=("$tool")
        fi
    done

    # Report missing tools
    if [ ${#missing_required[@]} -gt 0 ]; then
        print_error "Missing required tools: ${missing_required[*]}"
        print_info "Please install the missing tools and try again."
        exit 1
    fi

    if [ ${#missing_optional[@]} -gt 0 ]; then
        print_warning "Missing optional tools: ${missing_optional[*]}"
        print_info "Some features may not be available without these tools."
        echo ""
    fi

    # Check Nix installation
    if ! command -v nix &> /dev/null; then
        print_error "Nix is not installed!"
        print_info "Please install Nix first: https://nixos.org/download/"
        exit 1
    fi

    print_success "System requirements check passed"
}

# Interactive configuration functions
select_installation_mode() {
    ((CURRENT_STEP++))
    show_progress $CURRENT_STEP "Selecting installation mode"

    echo ""
    print_step "Choose Installation Mode"
    echo ""
    echo "1) 🚀 Quick Start (Recommended)"
    echo "   - Guided setup with sensible defaults"
    echo "   - All components with user choices"
    echo ""
    echo "2) 🐳 Docker-Only Setup"
    echo "   - Container deployment only"
    echo "   - Skip Nix environment setup"
    echo ""
    echo "3) 🔧 Advanced Configuration"
    echo "   - Full control over all settings"
    echo "   - Expert mode with all options"
    echo ""

    while true; do
        read -p "Enter your choice (1-3): " choice
        case $choice in
            1)
                INSTALL_MODE="quick_start"
                print_success "Selected: Quick Start mode"
                break
                ;;
            2)
                INSTALL_MODE="docker_only"
                print_success "Selected: Docker-Only mode"
                break
                ;;
            3)
                INSTALL_MODE="advanced"
                print_success "Selected: Advanced mode"
                break
                ;;
            *)
                print_error "Invalid choice. Please enter 1, 2, or 3."
                ;;
        esac
    done
}

configure_docker_hub() {
    ((CURRENT_STEP++))
    show_progress $CURRENT_STEP "Configuring GitHub Container Registry"

    print_step "🐳 GitHub Container Registry Configuration"

    # For GHCR, we use the GitHub username from the repository
    DOCKERHUB_USERNAME="btafoya"

    print_info "Using GitHub Container Registry: ghcr.io/$DOCKERHUB_USERNAME/nixvm"
    print_success "Registry configured for: $DOCKERHUB_USERNAME"
}

configure_app_environment() {
    ((CURRENT_STEP++))
    show_progress $CURRENT_STEP "Configuring application environment"

    print_step "🌍 Application Environment"

    echo "Select your application environment:"
    echo "1) Development (debug enabled, self-signed SSL)"
    echo "2) Production (secure, Let's Encrypt SSL available)"
    echo ""

    while true; do
        read -p "Choose environment [1]: " choice
        case ${choice:-1} in
            1)
                APP_ENV="development"
                print_success "Selected: Development environment"
                break
                ;;
            2)
                APP_ENV="production"
                print_success "Selected: Production environment"
                break
                ;;
            *)
                print_error "Invalid choice. Please enter 1 or 2."
                ;;
        esac
    done
}

configure_port_settings() {
    ((CURRENT_STEP++))
    show_progress $CURRENT_STEP "Configuring port settings"

    print_step "🔌 Port Configuration"

    echo "Choose the port NixVM will listen on."
    echo "Common options:"
    echo "  • 80   - Standard HTTP (requires root on Linux)"
    echo "  • 8080 - Common for development/proxies"
    echo "  • 3000 - Alternative development port"
    echo "  • 8443 - HTTPS alternative"
    echo ""

    # Smart default based on SSL and environment
    if [ "$ENABLE_LETS_ENCRYPT" = true ]; then
        DEFAULT_PORT="443"
    elif [ "$APP_ENV" = "production" ]; then
        DEFAULT_PORT="80"
    else
        DEFAULT_PORT="8080"
    fi

    while true; do
        read -p "Port number [$DEFAULT_PORT]: " input
        PORT=${input:-$DEFAULT_PORT}

        if ! validate_port "$PORT"; then
            print_error "Invalid port number. Must be between 1-65535."
            continue
        fi

        # Check for privileged ports
        if [ "$PORT" -lt 1024 ]; then
            print_warning "Port $PORT is privileged (< 1024)."
            echo "You may need root/administrator privileges to bind to this port."
            read -p "Continue with port $PORT? [y/N]: " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                continue
            fi
        fi

        # Check for common service ports
        local restricted_ports=(22 25 53 110 143 993 995 3306 5432)
        local is_restricted=false
        for restricted_port in "${restricted_ports[@]}"; do
            if [ "$PORT" -eq "$restricted_port" ]; then
                is_restricted=true
                break
            fi
        done

        if [ "$is_restricted" = true ]; then
            print_warning "Port $PORT is commonly used by system services."
            echo "This may cause conflicts."
            read -p "Use port $PORT anyway? [y/N]: " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                continue
            fi
        fi

        print_success "Using port: $PORT"
        break
    done
}

configure_ssl_options() {
    ((CURRENT_STEP++))
    show_progress $CURRENT_STEP "Configuring SSL options"

    print_step "🔒 SSL Configuration"

    if [ "$APP_ENV" = "production" ]; then
        echo "Production mode detected - SSL recommended for security."
        echo ""
        echo "SSL Options:"
        echo "1) Let's Encrypt (free SSL certificates)"
        echo "2) Custom certificates (provide your own)"
        echo "3) Self-signed certificates"
        echo "4) No SSL (HTTP only - not recommended)"
        echo ""

        while true; do
            read -p "Choose SSL option [1]: " choice
            case ${choice:-1} in
                1)
                    ENABLE_LETS_ENCRYPT=true
                    configure_ssl_details
                    break
                    ;;
                2)
                    ENABLE_LETS_ENCRYPT=false
                    ENABLE_CUSTOM_CERTS=true
                    configure_custom_certificates
                    break
                    ;;
                3)
                    ENABLE_LETS_ENCRYPT=false
                    ENABLE_CUSTOM_CERTS=false
                    print_warning "Using self-signed certificates"
                    break
                    ;;
                4)
                    ENABLE_LETS_ENCRYPT=false
                    ENABLE_CUSTOM_CERTS=false
                    print_warning "No SSL - application will use HTTP only"
                    break
                    ;;
                *)
                    print_error "Invalid choice. Please enter 1-4."
                    ;;
            esac
        done
    else
        echo "Development mode - using self-signed certificates (normal for development)"
        ENABLE_LETS_ENCRYPT=false
        ENABLE_CUSTOM_CERTS=false
    fi
}

configure_ssl_details() {
    print_step "📋 Let's Encrypt SSL Details"

    # Domain validation
    while true; do
        read -p "Domain name: " input
        if validate_domain "$input"; then
            DOMAIN="$input"
            break
        else
            print_error "Invalid domain format. Please try again."
        fi
    done

    # Email validation
    while true; do
        read -p "Email for SSL certificates: " input
        if validate_email "$input"; then
            SSL_EMAIL="$input"
            break
        else
            print_error "Invalid email format. Please try again."
        fi
    done

    # Multi-domain support
    configure_multi_domain_ssl

    print_success "SSL configured for $DOMAIN with notifications to $SSL_EMAIL"
}

configure_multi_domain_ssl() {
    echo ""
    echo "🌐 Multi-Domain SSL Certificate"
    echo "Let's Encrypt supports multiple domains on one certificate."
    echo ""

    read -p "Add additional domains? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Enter additional domains (one per line, empty line to finish):"
        ADDITIONAL_DOMAINS=()

        while true; do
            read -p "Domain: " additional_domain
            if [ -z "$additional_domain" ]; then
                break
            fi

            if validate_domain "$additional_domain"; then
                ADDITIONAL_DOMAINS+=("$additional_domain")
                print_success "Added: $additional_domain"
            else
                print_error "Invalid domain format, try again"
            fi
        done
    fi
}

configure_custom_certificates() {
    print_step "📁 Custom Certificate Configuration"

    # SSL Certificate path
    while true; do
        read -p "SSL Certificate file path: " input
        if [ -f "$input" ]; then
            SSL_CERT_PATH="$input"
            break
        else
            print_error "Certificate file not found: $input"
            read -p "Create file now? [y/N]: " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                print_info "Please create your certificate file and try again."
                read -p "Press Enter to continue... "
            fi
        fi
    done

    # Private key path
    while true; do
        read -p "Private key file path: " input
        if [ -f "$input" ]; then
            SSL_KEY_PATH="$input"
            break
        else
            print_error "Key file not found: $input"
            read -p "Create file now? [y/N]: " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                print_info "Please create your private key file and try again."
                read -p "Press Enter to continue... "
            fi
        fi
    done

    print_success "Custom certificates configured"
}

configure_ssl_redirect() {
    if [ "$ENABLE_LETS_ENCRYPT" = true ] || [ "$ENABLE_CUSTOM_CERTS" = true ]; then
        echo ""
        print_step "🔄 HTTP to HTTPS Redirect"

        echo "Automatically redirect all HTTP traffic to HTTPS for security."
        echo "This prevents mixed content issues and ensures encrypted connections."
        echo ""

        read -p "Enable automatic HTTP→HTTPS redirect? [Y/n]: " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            ENABLE_REDIRECT=true

            # Configure redirect port
            if [ "$PORT" = "443" ]; then
                REDIRECT_PORT="80"
            else
                read -p "HTTP redirect port [80]: " input
                REDIRECT_PORT=${input:-80}
            fi

            print_success "HTTP→HTTPS redirect enabled (port $REDIRECT_PORT → $PORT)"
        else
            ENABLE_REDIRECT=false
            print_warning "HTTP→HTTPS redirect disabled"
        fi
    fi
}

configure_development_ssl() {
    if [ "$APP_ENV" = "development" ]; then
        echo ""
        print_step "🔒 Development SSL Options"

        echo "Current: Self-signed certificates (browser warnings are normal)"
        echo "Alternative: Proper development certificates with mkcert"
        echo ""

        read -p "Set up proper dev certificates? [y/N]: " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            ENABLE_DEV_CERTS=true
            setup_dev_certificates
        else
            ENABLE_DEV_CERTS=false
        fi
    fi
}

setup_dev_certificates() {
    print_step "🛠️ Development Certificate Setup"

    echo "Options for proper development certificates:"
    echo ""
    echo "1) mkcert (recommended) - Creates trusted local certificates"
    echo "2) Custom CA - Create your own certificate authority"
    echo ""

    read -p "Choose option [1]: " choice
    case ${choice:-1} in
        1) setup_mkcert ;;
        2) setup_custom_ca ;;
    esac
}

setup_mkcert() {
    echo "🐳 mkcert Setup:"
    echo ""
    echo "mkcert creates locally-trusted development certificates."
    echo ""

    # Check if mkcert is available in Nix
    if nix eval nixpkgs#mkcert --json >/dev/null 2>&1; then
        echo "✅ mkcert available in Nixpkgs"
        read -p "Auto-install mkcert in Nix environment? [Y/n]: " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            INSTALL_MKCERT=true
            print_success "mkcert will be added to your development environment"
        fi
    else
        print_warning "mkcert not in current Nixpkgs"
        print_info "Manual installation: https://github.com/FiloSottile/mkcert"
    fi

    echo ""
    echo "📋 To use mkcert certificates in Docker:"
    echo "1. Install mkcert: nix-env -iA nixpkgs.mkcert (if available)"
    echo "2. Create certs: mkcert -install && mkcert localhost"
    echo "3. Mount in docker-compose.yml"
    echo ""
    read -p "ℹ️ Press Enter when ready to continue... "
}

setup_custom_ca() {
    print_info "Custom CA setup requires manual configuration."
    print_info "Please refer to SSL documentation for your platform."
    read -p "ℹ️ Press Enter to continue... "
}

configure_proxy_guidance() {
    if [ "$PORT" != "80" ] && [ "$PORT" != "443" ]; then
        echo ""
        print_step "🌐 Proxy Server Integration"

        echo "Since you're using port $PORT, you may want to set up a reverse proxy."
        echo ""

        # Nginx configuration
        echo "📄 Nginx Virtual Host (add to /etc/nginx/sites-available/nixvm):"
        echo "   server {"
        echo "       listen 80;"
        echo "       server_name yourdomain.com;"
        echo ""
        echo "       location / {"
        echo "           proxy_pass http://localhost:$PORT;"
        echo "           proxy_set_header Host \$host;"
        echo "           proxy_set_header X-Real-IP \$remote_addr;"
        echo "           proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;"
        echo "           proxy_set_header X-Forwarded-Proto \$scheme;"
        echo "       }"
        echo "   }"
        echo ""

        # Apache configuration
        echo "📄 Apache Virtual Host (add to /etc/apache2/sites-available/nixvm.conf):"
        echo "   <VirtualHost *:80>"
        echo "       ServerName yourdomain.com"
        echo "       ProxyPass / http://localhost:$PORT/"
        echo "       ProxyPassReverse / http://localhost:$PORT/"
        echo "   </VirtualHost>"
        echo ""

        # Caddy configuration
        echo "📄 Caddy (add to Caddyfile):"
        echo "   yourdomain.com {"
        echo "       reverse_proxy localhost:$PORT"
        echo "   }"
        echo ""

        read -p "ℹ️ Press Enter when ready to continue... "
    fi
}

configure_ssl_persistence() {
    if [ "$ENABLE_LETS_ENCRYPT" = true ]; then
        echo ""
        print_step "💾 SSL Certificate Storage"

        echo "Let's Encrypt certificates will be stored in Docker volumes:"
        echo "  • /data/caddy - Certificate data"
        echo "  • /config/caddy - Caddy configuration"
        echo ""

        print_warning "Important: Backup these volumes regularly!"
        echo "   docker run --rm -v nixvm_caddy_data:/data \\"
        echo "     alpine tar czf backup.tar.gz -C /data ."
        echo ""

        echo "🔄 Certificate auto-renewal is handled by Caddy."
        echo "   No manual certificate management required."
        echo ""

        read -p "ℹ️ Press Enter to continue... "
    fi
}

configure_ssl_renewal_info() {
    if [ "$ENABLE_LETS_ENCRYPT" = true ]; then
        echo ""
        print_step "🔄 SSL Certificate Renewal"

        echo "• Let's Encrypt certificates auto-renew every 90 days"
        echo "• Caddy handles renewal automatically in the background"
        echo "• No manual intervention required"
        echo "• Renewal notifications sent to: $SSL_EMAIL"
        echo ""

        read -p "ℹ️ Press Enter to continue... "
    fi
}

configure_database() {
    ((CURRENT_STEP++))
    show_progress $CURRENT_STEP "Configuring database"

    print_step "🐬 Database Configuration"

    read -p "Root password [rootpassword]: " input
    MYSQL_ROOT_PASSWORD=${input:-rootpassword}

    read -p "Database name [nixvm_dev]: " input
    MYSQL_DATABASE=${input:-nixvm_dev}

    read -p "Username [nixvm_user]: " input
    MYSQL_USER=${input:-nixvm_user}

    read -p "Password [nixvm_pass]: " input
    MYSQL_PASSWORD=${input:-nixvm_pass}

    print_success "Database configuration complete"
}

configure_php_version() {
    ((CURRENT_STEP++))
    show_progress $CURRENT_STEP "Configuring PHP version"

    print_step "🐘 PHP Version Selection"

    echo "Select PHP version to install:"
    echo "1) PHP 8.4 (Latest stable - Recommended)"
    echo "2) PHP 8.3 (Stable)"
    echo "3) PHP 8.2 (Stable)"
    echo ""

    while true; do
        read -p "Choose PHP version [1]: " choice
        case ${choice:-1} in
            1)
                PHP_VERSION="8.4"
                PHP_PACKAGE="php84"
                print_success "Selected: PHP 8.4"
                break
                ;;
            2)
                PHP_VERSION="8.3"
                PHP_PACKAGE="php83"
                print_success "Selected: PHP 8.3"
                break
                ;;
            3)
                PHP_VERSION="8.2"
                PHP_PACKAGE="php82"
                print_success "Selected: PHP 8.2"
                break
                ;;
            *)
                print_error "Invalid choice. Please enter 1, 2, or 3."
                ;;
        esac
    done

    update_php_version_in_files
}

update_php_version_in_files() {
    print_step "Updating PHP version in configuration files"

    local old_php_package="php83"

    if [ -f "Dockerfile.php-app" ]; then
        sed -i "s/-iA ${old_php_package}/-iA ${PHP_PACKAGE}/g" "Dockerfile.php-app"
        print_success "Updated Dockerfile.php-app (${old_php_package} → ${PHP_PACKAGE})"
    else
        print_warning "Dockerfile.php-app not found, skipping update"
    fi

    if [ -f "flake.nix" ]; then
        sed -i "s/${old_php_package}/${PHP_PACKAGE}/g" "flake.nix"
        sed -i "s/PHP 8.3/PHP ${PHP_VERSION}/g" "flake.nix"
        print_success "Updated flake.nix (PHP 8.3 → PHP ${PHP_VERSION})"
    else
        print_warning "flake.nix not found, skipping update"
    fi

    print_info "Note: Run 'nix flake update' to update flake.lock with new dependencies"
}

configure_php() {
    ((CURRENT_STEP++))
    show_progress $CURRENT_STEP "Configuring PHP"

    print_step "🐘 PHP Configuration"

    read -p "Memory limit [256M]: " input
    PHP_MEMORY_LIMIT=${input:-256M}

    if ! validate_memory "$PHP_MEMORY_LIMIT"; then
        print_error "Invalid memory format. Using default: 256M"
        PHP_MEMORY_LIMIT="256M"
    fi

    read -p "Upload max filesize [100M]: " input
    PHP_UPLOAD_MAX_FILESIZE=${input:-100M}

    read -p "Post max size [100M]: " input
    PHP_POST_MAX_SIZE=${input:-100M}

    print_success "PHP configuration complete"
}

configure_composer() {
    ((CURRENT_STEP++))
    show_progress $CURRENT_STEP "Configuring Composer"

    print_step "📦 Composer Configuration"

    read -p "Allow superuser [1]: " input
    COMPOSER_ALLOW_SUPERUSER=${input:-1}

    read -p "Memory limit [-1]: " input
    COMPOSER_MEMORY_LIMIT=${input:-"-1"}

    print_success "Composer configuration complete"
}

show_configuration_summary() {
    ((CURRENT_STEP++))
    show_progress $CURRENT_STEP "Generating configuration summary"

    echo ""
    print_step "📋 Configuration Summary"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    printf "🐳 Docker Hub:     %s\n" "$DOCKERHUB_USERNAME"
    printf "🌍 Environment:    %s\n" "$APP_ENV"
    printf "🔌 Port:          %s\n" "$PORT"
    printf "🔒 SSL:           %s\n" "$(
        if [ "$ENABLE_LETS_ENCRYPT" = true ]; then
            echo "Let's Encrypt ($DOMAIN)"
        elif [ "$ENABLE_CUSTOM_CERTS" = true ]; then
            echo "Custom certificates"
        else
            echo "Self-signed"
        fi
    )"

    if [ "$ENABLE_LETS_ENCRYPT" = true ]; then
        printf "📧 SSL Email:      %s\n" "$SSL_EMAIL"
        printf "🔄 Auto-renewal:   Every 90 days\n"
        printf "💾 Cert storage:   Docker volumes\n"
        if [ ${#ADDITIONAL_DOMAINS[@]} -gt 0 ]; then
            printf "🌐 Extra domains:  %s\n" "${ADDITIONAL_DOMAINS[*]}"
        fi
    fi

    if [ "$ENABLE_REDIRECT" = true ]; then
        printf "🔄 HTTP redirect:  Port %s → %s\n" "$REDIRECT_PORT" "$PORT"
    fi

    if [ "$PORT" != "80" ] && [ "$PORT" != "443" ]; then
        printf "🌐 Proxy needed:   Yes (port %s)\n" "$PORT"
    fi

    printf "🐬 Database:       %s\n" "$MYSQL_DATABASE"
    printf "👤 DB User:        %s\n" "$MYSQL_USER"
    printf "🐘 PHP Version:    %s\n" "$PHP_VERSION"
    printf "🐘 PHP Memory:     %s\n" "$PHP_MEMORY_LIMIT"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    read -p "✅ Proceed with this configuration? [Y/n]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        print_info "Restarting configuration..."
        main_configuration
        return 1
    fi

    return 0
}

generate_env_file() {
    ((CURRENT_STEP++))
    show_progress $CURRENT_STEP "Generating configuration files"

    print_step "📝 Generating .env file"

    cat > .env << EOF
# NixVM Environment Configuration
# Generated by interactive installer on $(date)

# Docker Hub Configuration
DOCKERHUB_USERNAME=$DOCKERHUB_USERNAME

# Application Environment
APP_ENV=$APP_ENV

# Network Configuration
PORT=$PORT
$(if [ "$ENABLE_REDIRECT" = true ]; then echo "REDIRECT_PORT=$REDIRECT_PORT"; fi)

# SSL Configuration
ENABLE_LETS_ENCRYPT=$ENABLE_LETS_ENCRYPT
$(if [ "$ENABLE_LETS_ENCRYPT" = true ]; then
    echo "DOMAIN=$DOMAIN"
    echo "SSL_EMAIL=$SSL_EMAIL"
    if [ ${#ADDITIONAL_DOMAINS[@]} -gt 0 ]; then
        echo "ADDITIONAL_DOMAINS=${ADDITIONAL_DOMAINS[*]}"
    fi
fi)

$(if [ "$ENABLE_CUSTOM_CERTS" = true ]; then
    echo "SSL_CERT_PATH=$SSL_CERT_PATH"
    echo "SSL_KEY_PATH=$SSL_KEY_PATH"
fi)

# Development SSL
ENABLE_DEV_CERTS=$ENABLE_DEV_CERTS
$(if [ "$INSTALL_MKCERT" = true ]; then echo "INSTALL_MKCERT=true"; fi)

# Database Configuration
MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD
MYSQL_DATABASE=$MYSQL_DATABASE
MYSQL_USER=$MYSQL_USER
MYSQL_PASSWORD=$MYSQL_PASSWORD

# PHP Configuration
PHP_VERSION=$PHP_VERSION
PHP_MEMORY_LIMIT=$PHP_MEMORY_LIMIT
PHP_UPLOAD_MAX_FILESIZE=$PHP_UPLOAD_MAX_FILESIZE
PHP_POST_MAX_SIZE=$PHP_POST_MAX_SIZE

# Composer Configuration
COMPOSER_ALLOW_SUPERUSER=$COMPOSER_ALLOW_SUPERUSER
COMPOSER_MEMORY_LIMIT=$COMPOSER_MEMORY_LIMIT

# Installation Metadata
INSTALLED_BY=nixvm-installer
INSTALLED_ON=$(date)
INSTALL_MODE=$INSTALL_MODE
EOF

    print_success "Generated .env file with your custom configuration"
}

generate_php_configs() {
    ((CURRENT_STEP++))
    show_progress $CURRENT_STEP "Generating PHP configuration files"

    print_step "🐘 Generating PHP configuration files"

    # Generate development PHP config
    generate_php_config "docker/php/php.ini.development" "development"

    # Generate production PHP config
    generate_php_config "docker/php/php.ini.production" "production"
}

generate_php_config() {
    local config_file="$1"
    local environment="$2"

    # Base PHP configuration with dynamic values
    cat > "$config_file" << EOF
[PHP]

; using ; about php.ini   ;
; using ;

engine = On
short_open_tag = Off
precision = 14
output_buffering = 4096
zlib.output_compression = Off
implicit_flush = Off
unserialize_callback_func =
serialize_precision = -1
disable_functions =
disable_classes =
zend.enable_gc = On
zend.exception_ignore_args = Off
zend.exception_string_param_max_len = 0
expose_php = $(if [ "$environment" = "production" ]; then echo "Off"; else echo "On"; fi)

; using ; Resource Limits ;
; using ;

max_execution_time = $(if [ "$environment" = "production" ]; then echo "60"; else echo "300"; fi)
max_input_time = 60
memory_limit = $PHP_MEMORY_LIMIT

; using ; Error handling and logging ;
; using ;

error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT
display_errors = $(if [ "$environment" = "production" ]; then echo "Off"; else echo "On"; fi)
display_startup_errors = $(if [ "$environment" = "production" ]; then echo "Off"; else echo "On"; fi)
log_errors = On
log_errors_max_len = 1024
ignore_repeated_errors = Off
ignore_repeated_source = Off
report_memleaks = $(if [ "$environment" = "production" ]; then echo "Off"; else echo "On"; fi)
track_errors = $(if [ "$environment" = "production" ]; then echo "Off"; else echo "On"; fi)
html_errors = $(if [ "$environment" = "production" ]; then echo "Off"; else echo "On"; fi)

; using ; Data Handling ;
; using ;

arg_separator.output = "& using ;"
arg_separator.input = ";&"
variables_order = "EGPCS"
request_order = "GP"
register_argc_argv = Off
auto_globals_jit = On
post_max_size = $PHP_POST_MAX_SIZE
auto_prepend_file =
auto_append_file =
default_mimetype = "text/html"
default_charset = "UTF-8"
internal_encoding =
input_encoding =
output_encoding =

; using ; Paths and Directories ;
; using ;

doc_root =
user_dir =
enable_dl = Off
cgi.fix_pathinfo=1
file_uploads = On
upload_max_filesize = $PHP_UPLOAD_MAX_FILESIZE
max_file_uploads = 20
allow_url_fopen = $(if [ "$environment" = "production" ]; then echo "Off"; else echo "On"; fi)
allow_url_include = Off
default_socket_timeout = 60

; using ; File Uploads ;
; using ;

upload_tmp_dir =

; using ; Fopen wrappers ;
; using ;

extension=gd
extension=mbstring
extension=mysql
extension=pdo_mysql
extension=zip
extension=imap
extension=imagick

; using ; Module Settings ;
; using ;

[CLI Server]
cli_server.color = On

[Date]
date.timezone = UTC

[Session]
session.save_handler = files
session.save_path = "/tmp/sessions"
session.use_strict_mode = 1
session.use_cookies = 1
session.cookie_secure = $(if [ "$environment" = "production" ]; then echo "1"; else echo "0"; fi)
session.cookie_httponly = 1
session.cookie_samesite = $(if [ "$environment" = "production" ]; then echo '"Strict"'; else echo ""; fi)
session.gc_maxlifetime = $(if [ "$environment" = "production" ]; then echo "7200"; else echo "1440"; fi)
session.gc_probability = 1
session.gc_divisor = 100

[Assertion]
zend.assertions = -1

[Tidy]
tidy.clean_output = Off

[soap]
soap.wsdl_cache_enabled=1
soap.wsdl_cache_dir="/tmp"
soap.wsdl_cache_ttl=86400
soap.wsdl_cache_limit = 5

[opcache]
opcache.enable=$(if [ "$environment" = "production" ]; then echo "1"; else echo "1"; fi)
opcache.memory_consumption=$(if [ "$environment" = "production" ]; then echo "64"; else echo "256"; fi)
opcache.max_accelerated_files=7963
opcache.revalidate_freq=$(if [ "$environment" = "production" ]; then echo "0"; else echo "0"; fi)
$(if [ "$environment" = "production" ]; then
    echo "opcache.validate_timestamps=0"
    echo "opcache.save_comments=0"
fi)
EOF

    print_success "Generated $environment PHP configuration at $config_file"
}

generate_caddyfile() {
    ((CURRENT_STEP++))
    show_progress $CURRENT_STEP "Generating Caddy configuration"

    print_step "📄 Generating Caddyfile"

    local caddyfile_path="docker/caddy/Caddyfile"

    cat > "$caddyfile_path" << EOF
# Auto-generated Caddyfile for NixVM
# Generated on $(date) by installer

EOF

    if [ "$ENABLE_LETS_ENCRYPT" = true ]; then
        cat >> "$caddyfile_path" << EOF
# Production with Let's Encrypt SSL
$DOMAIN$(if [ ${#ADDITIONAL_DOMAINS[@]} -gt 0 ]; then
    for domain in "${ADDITIONAL_DOMAINS[@]}"; do
        echo " $domain"
    done
fi) {
    tls $SSL_EMAIL

    root * /var/www/html
    php_fastcgi php:9000
    file_server

    # Security headers for production
    header {
        X-Frame-Options "SAMEORIGIN"
        X-XSS-Protection "1; mode=block"
        X-Content-Type-Options "nosniff"
        Referrer-Policy "strict-origin-when-cross-origin"
        Permissions-Policy "geolocation=(), microphone=(), camera=()"
    }

    # PHP file handling
    @php {
        path *.php
    }
    php_fastcgi @php php:9000

    # Static files with aggressive caching
    @static {
        file {
            try_files {path} {path}/ /index.php?{query}
        }
        path *.css *.js *.png *.jpg *.jpeg *.gif *.ico *.svg *.woff *.woff2 *.webp
    }
    header @static Cache-Control max-age=31536000
    header @static X-Content-Type-Options nosniff

    # API routes with compression
    handle /api/* {
        php_fastcgi php:9000
        encode gzip
    }

    # Security headers for API
    header /api/* {
        Cache-Control no-cache
        X-Content-Type-Options nosniff
    }

    # Health check endpoint
    handle /health {
        respond "OK" 200
    }

    # Log requests (production format)
    log {
        output file /var/log/caddy/access.log {
            roll_size 10mb
            roll_keep 30
        }
        format json
    }

    # Rate limiting for production
    rate_limit {
        zone static {
            key {remote_host}
            window 1m
            events 100
        }
    }
}
EOF

        # HTTP redirect if enabled
        if [ "$ENABLE_REDIRECT" = true ]; then
            cat >> "$caddyfile_path" << EOF

# HTTP redirect to HTTPS
:$REDIRECT_PORT {
    redir https://{host}$request_uri permanent
}
EOF
        fi

    elif [ "$ENABLE_CUSTOM_CERTS" = true ]; then
        cat >> "$caddyfile_path" << EOF
# Custom SSL certificates
:$PORT {
    tls $SSL_CERT_PATH $SSL_KEY_PATH

    root * /var/www/html
    php_fastcgi php:9000
    file_server

    # PHP file handling
    @php {
        path *.php
    }
    php_fastcgi @php php:9000

    # Static files
    @static {
        file {
            try_files {path} {path}/ /index.php?{query}
        }
        path *.css *.js *.png *.jpg *.jpeg *.gif *.ico *.svg
    }
    header @static Cache-Control max-age=31536000

    # Log requests
    log {
        output file /var/log/caddy/access.log
        format json
    }
}
EOF
    else
        cat >> "$caddyfile_path" << EOF
# Development with self-signed SSL
:$PORT {
    root * /var/www/html
    php_fastcgi php:9000
    file_server

    $(if [ "$APP_ENV" = "development" ]; then
        echo "# Development headers"
        echo "header X-Debug-Info \"NixVM PHP ${PHP_VERSION} Development\""
        echo ""
        echo "# CORS for development"
        echo "@cors_preflight {"
        echo "    method OPTIONS"
        echo "}"
        echo "respond @cors_preflight 204 {"
        echo "    header Access-Control-Allow-Origin *"
        echo "}"
    fi)

    # PHP file handling
    @php {
        path *.php
    }
    php_fastcgi @php php:9000

    # Static files with caching
    @static {
        file {
            try_files {path} {path}/ /index.php?{query}
        }
        path *.css *.js *.png *.jpg *.jpeg *.gif *.ico *.svg *.woff *.woff2
    }
    header @static Cache-Control max-age=31536000

    # API routes (if any)
    handle /api/* {
        php_fastcgi php:9000
        encode gzip
    }

    # Log requests
    log {
        output file /var/log/caddy/access.log {
            roll_size 10mb
            roll_keep 5
        }
        format json
    }
}
EOF
    fi

    print_success "Generated Caddyfile for $APP_ENV environment"
}

update_docker_compose() {
    ((CURRENT_STEP++))
    show_progress $CURRENT_STEP "Updating Docker Compose configuration"

    print_step "🐳 Updating Docker Compose"

    # Update docker-compose.hub.yml with the new environment variables
    local compose_file="docker-compose.hub.yml"

    # Create a backup
    cp "$compose_file" "${compose_file}.backup"

    # Update the app service environment variables
    sed -i "s/\${DOCKERHUB_USERNAME}/$DOCKERHUB_USERNAME/g" "$compose_file"

    print_success "Updated Docker Compose configuration"
}

run_post_install_tests() {
    ((CURRENT_STEP++))
    show_progress $CURRENT_STEP "Running post-installation tests"

    print_step "🧪 Running Post-Installation Tests"

    local tests_passed=0
    local total_tests=3

    # Test .env file creation
    if [ -f ".env" ]; then
        print_success "✅ .env file created"
        ((tests_passed++))
    else
        print_error "❌ .env file not found"
    fi

    # Test Nix flake
    if nix flake check >/dev/null 2>&1; then
        print_success "✅ Nix flake validation passed"
        ((tests_passed++))
    else
        print_warning "⚠️  Nix flake validation failed (may be due to missing tools)"
    fi

    # Test Docker (if available)
    if command -v docker &> /dev/null; then
        ((total_tests++))
        if docker --version >/dev/null 2>&1; then
            print_success "✅ Docker is available"
            ((tests_passed++))
        else
            print_error "❌ Docker test failed"
        fi
    fi

    echo ""
    print_info "Test Results: $tests_passed/$total_tests passed"

    if [ $tests_passed -eq $total_tests ]; then
        print_success "🎉 All tests passed!"
    fi
}

show_completion_message() {
    echo ""
    print_header

    print_success "🎉 Installation Complete!"
    echo ""
    echo "🚀 Your NixVM development environment is ready!"
    echo ""
    echo "📖 Quick Start Guide:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "1. Start the environment:"
    echo "   docker-compose -f docker-compose.hub.yml up -d"
    echo ""
    echo "2. Access your application:"
    echo "   • Main app: http://localhost:$PORT"
    if [ "$ENABLE_LETS_ENCRYPT" = true ]; then
        echo "   • HTTPS: https://$DOMAIN"
    fi
    echo ""
    echo "3. Database access:"
    echo "   • phpMyAdmin: http://localhost:8081"
    echo "   • Direct: localhost:3306"
    echo ""
    echo "🔧 Useful Commands:"
    echo "   • View logs: docker-compose -f docker-compose.hub.yml logs -f"
    echo "   • Stop: docker-compose -f docker-compose.hub.yml down"
    echo "   • Nix dev: nix develop"
    echo ""
    echo "📚 Documentation:"
    echo "   • README.md - Complete usage guide"
    echo "   • .env - Your configuration"
    echo "   • docker-compose.hub.yml - Docker setup"
    echo ""
    if [ "$ENABLE_LETS_ENCRYPT" = true ]; then
        echo "🔒 SSL Notes:"
        echo "   • Certificates auto-renew every 90 days"
        echo "   • Backup volumes: nixvm_caddy_data, nixvm_caddy_config"
        echo ""
    fi

    echo "💡 Next Steps:"
    echo "   1. Run 'composer install' in nix develop"
    echo "   2. Start coding your PHP application"
    echo "   3. Push to main branch to publish Docker images"
    echo ""
    print_success "Happy coding with NixVM! 🚀"
}

# Main installation flow
main() {
    parse_arguments "$@"

    change_to_install_dir

    check_and_download_files

    PROGRESS_WIDTH=50
    DOCKERHUB_USERNAME="$DEFAULT_DOCKERHUB_USERNAME"

    # Welcome
    print_header

    # Pre-flight checks
    check_requirements
    echo ""

    # Interactive configuration
    main_configuration

    # Configuration generation
    generate_env_file
    generate_php_configs
    generate_caddyfile
    update_docker_compose

    # Post-install tests
    run_post_install_tests

    # Completion
    show_completion_message
}

main_configuration() {
    select_installation_mode
    configure_docker_hub
    configure_app_environment
    configure_port_settings
    configure_ssl_options
    configure_ssl_redirect
    configure_development_ssl
    configure_ssl_persistence
    configure_ssl_renewal_info
    configure_proxy_guidance
    configure_database
    configure_php_version
    configure_php
    configure_composer

    if ! show_configuration_summary; then
        return 1
    fi
}

# Run main function
main "$@"
