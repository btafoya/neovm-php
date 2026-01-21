{
  description = "PHP 8.3 Development Environment with MariaDB and Caddy";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # PHP 8.3 with common extensions
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

      in {
        packages.default = php83;

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # PHP and Composer
            php83
            php83.packages.composer

            # Database
            mariadb
            mysql80  # MySQL client tools

            # Web server
            caddy

            # Development tools
            git
            nodejs  # For frontend tooling if needed
            yarn
            docker-compose
            uv  # For MCP servers

            # Code quality tools
            php83.packages.php-cs-fixer
            php83.packages.phpstan

            # System utilities
            curl
            wget
            htop
            tree

            # CLI development tools
            zip
            unzip
            gnutar
            gzip
            gnumake
            gh
            gnused
            gawk
            ripgrep
            fd
            bat
            jq
          ];

          shellHook = ''
            echo "🚀 PHP 8.3 Development Environment"
            echo "📦 PHP version: $(php --version | head -n 1)"
            echo "🐘 Composer: $(composer --version)"
            echo "🐬 MariaDB: $(mariadb --version)"
            echo "🦙 Caddy: $(caddy version)"
            echo ""
            echo "📝 Useful commands:"
            echo "  nix develop          - Enter development shell"
            echo "  docker-compose up    - Start containerized services"
            echo "  caddy run            - Start Caddy server"
            echo "  composer install     - Install PHP dependencies"
            echo ""
          '';

          # Environment variables
          env = {
            PHP_VERSION = "8.3";
            COMPOSER_ALLOW_SUPERUSER = "1";
            COMPOSER_MEMORY_LIMIT = "-1";
          };
        };

        # Apps for easy access
        apps = {
          php = flake-utils.lib.mkApp {
            drv = php83;
            exePath = "/bin/php";
          };

          composer = flake-utils.lib.mkApp {
            drv = php83.packages.composer;
            exePath = "/bin/composer";
          };

          caddy = flake-utils.lib.mkApp {
            drv = pkgs.caddy;
            exePath = "/bin/caddy";
          };
        };
      });
}
