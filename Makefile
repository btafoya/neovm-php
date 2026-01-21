# NixVM Development Environment Makefile

.PHONY: help nix-dev nix-build test lint format docker-build docker-push docker-pull docker-up docker-down clean

# Default target
help: ## Show this help message
	@echo "🚀 NixVM Development Environment"
	@echo ""
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Nix development targets
nix-dev: ## Enter Nix development shell
	nix develop

nix-build: ## Build PHP package with Nix
	nix build .#packages.x86_64-linux.php83

nix-test: ## Run Nix flake checks
	nix flake check

# Code quality targets
test: ## Run PHP tests
	nix develop --command "composer test"

lint: ## Run PHPStan analysis
	nix develop --command "composer analyze"

format: ## Format PHP code
	nix develop --command "composer fix"

check-format: ## Check PHP code formatting
	nix develop --command "composer check"

# Docker targets
docker-setup: ## Setup Docker Hub environment
	./setup-docker-hub.sh

docker-build: ## Build all Docker images locally
	docker-compose -f docker-compose.hub.yml build

docker-pull: ## Pull all images from Docker Hub
	docker-compose -f docker-compose.hub.yml pull

docker-up: ## Start all services from Docker Hub images
	docker-compose -f docker-compose.hub.yml up -d

docker-up-db: ## Start only database service
	docker-compose -f docker-compose.hub.yml up -d db

docker-up-app: ## Start only application service
	docker-compose -f docker-compose.hub.yml up -d app

docker-up-all: ## Start all services including optional ones
	docker-compose -f docker-compose.hub.yml --profile phpmyadmin --profile standalone-caddy up -d

docker-down: ## Stop all services
	docker-compose -f docker-compose.hub.yml down

docker-logs: ## Show logs from all services
	docker-compose -f docker-compose.hub.yml logs -f

docker-clean: ## Remove all containers and volumes
	docker-compose -f docker-compose.hub.yml down -v --remove-orphans

# Development workflow
dev-setup: ## Complete development setup
	nix develop --command "composer install"
	@echo "🎉 Development environment ready!"
	@echo "Run 'make docker-up' to start services"

dev-full: ## Full development environment (Nix + Docker)
	nix develop --command "composer install"
	docker-compose -f docker-compose.hub.yml up -d
	@echo "🎉 Full environment running!"
	@echo "• Application: http://localhost"
	@echo "• phpMyAdmin: http://localhost:8081"

# Publishing targets (for maintainers)
publish-patch: ## Create patch version tag (e.g., v1.0.1)
	@echo "Current version:" && git describe --tags --abbrev=0
	@read -p "New patch version (e.g., 1.0.1): " version && \
	git tag "v$$version" && \
	git push origin "v$$version"

publish-minor: ## Create minor version tag (e.g., v1.1.0)
	@echo "Current version:" && git describe --tags --abbrev=0
	@read -p "New minor version (e.g., 1.1.0): " version && \
	git tag "v$$version" && \
	git push origin "v$$version"

publish-major: ## Create major version tag (e.g., v2.0.0)
	@echo "Current version:" && git describe --tags --abbrev=0
	@read -p "New major version (e.g., 2.0.0): " version && \
	git tag "v$$version" && \
	git push origin "v$$version"

# Cleanup targets
clean: ## Clean up build artifacts
	rm -rf vendor/ node_modules/ result/
	docker system prune -f

clean-all: ## Deep clean (including volumes)
	rm -rf vendor/ node_modules/ result/
	docker-compose -f docker-compose.hub.yml down -v --remove-orphans
	docker system prune -a -f --volumes

# Info targets
info: ## Show environment information
	@echo "🐳 Docker status:"
	@docker-compose -f docker-compose.hub.yml ps
	@echo ""
	@echo "📦 Nix environment:"
	@nix --version
	@echo "Flake status:" && nix flake metadata . | cat

# Test APP_ENV functionality
test-app-env: ## Test APP_ENV development vs production modes
	./test-app-env.sh

# CI/CD simulation
ci-test: nix-test docker-build test-app-env ## Run CI-like checks locally
	@echo "✅ All checks passed!"

# Quick start targets
start: docker-up ## Quick start (alias for docker-up)
stop: docker-down ## Quick stop (alias for docker-down)
restart: docker-down docker-up ## Restart all services