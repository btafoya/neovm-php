let
  # Pin nixpkgs to ensure reproducibility
  nixpkgs = fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";
    sha256 = "1w5aq2s6x7dhqa2yy7z6m4z8x0wf8p8pb0qld0gjk3dzv8v7qrf2";
  };

  pkgs = import nixpkgs {};

  # PHP 8.3 with extensions
  php83 = pkgs.php83.buildEnv {
    extensions = ({ enabled, all }:
      enabled ++ [
        all.pdo_mysql
        all.mysqli
        all.mbstring
        all.curl
        all.gd
        all.zip
        all.intl
        all.opcache
        all.xdebug
        all.imap
        all.imagick
      ]);
    extraConfig = ''
      xdebug.mode = develop,debug
      xdebug.client_host = 127.0.0.1
      xdebug.client_port = 9003
      xdebug.start_with_request = yes
      memory_limit = 256M
      upload_max_filesize = 100M
      post_max_size = 100M
      max_execution_time = 300
    '';
  };

in
pkgs.mkShell {
  buildInputs = with pkgs; [
    # PHP and tools
    php83
    php83.packages.composer

    # Database
    mariadb
    mysql80

    # Web server
    caddy

    # Development tools
    git
    nodejs
    yarn
    docker-compose

    # Code quality
    php83.packages.php-cs-fixer
    php83.packages.phpstan

    # Utilities
    curl
    wget
    htop
  ];

  shellHook = ''
    echo "🚀 PHP 8.3 Development Environment (shell.nix)"
    echo "📦 PHP: $(php --version | head -n 1)"
    echo "🐘 Composer: $(composer --version)"
    echo "🐬 MariaDB: $(mariadb --version)"
    echo "🦙 Caddy: $(caddy version)"
    echo ""
    echo "📝 Commands:"
    echo "  nix-shell          - Enter this shell"
    echo "  docker-compose up  - Start services"
    echo "  caddy run          - Start web server"
    echo "  composer install   - Install dependencies"
    echo ""
  '';

  # Environment variables
  COMPOSER_ALLOW_SUPERUSER = "1";
  COMPOSER_MEMORY_LIMIT = "-1";
}