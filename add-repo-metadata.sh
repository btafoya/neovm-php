#!/bin/bash
# Script to add repository description and tags using GitHub CLI

set -e

echo "🚀 Adding repository description and tags to NixVM..."

# Check if gh is available
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed."
    echo "Install it from: https://cli.github.com/"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "❌ Not authenticated with GitHub CLI."
    echo "Run: gh auth login"
    exit 1
fi

echo "📝 Setting repository description..."
gh repo edit --description 'PHP 8.3 development environment with MariaDB and Caddy using Nix for reproducible builds'

echo "🏷️  Adding repository topics..."
gh repo edit \
    --add-topic php \
    --add-topic nix \
    --add-topic docker \
    --add-topic development-environment \
    --add-topic mariadb \
    --add-topic caddy \
    --add-topic phpfpm \
    --add-topic nixos \
    --add-topic container \
    --add-topic github-actions \
    --add-topic ci-cd

echo "✅ Repository description and tags added successfully!"
echo ""
echo "📊 Repository info:"
gh repo view --json description,topics