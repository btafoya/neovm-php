# AGENTS.md - Development Environment Guidelines

This document provides guidelines for agentic coding assistants working on the NixVM project, which builds development environments using Docker and the Nix Model Context Protocol (MCP).

## Project Overview

NixVM creates reproducible development environments by integrating Nix package management with Docker containers and MCP servers for AI-assisted development workflows.

## Build/Lint/Test Commands

### Development Environment Setup

```bash
# Start development environment with Nix flake
nix develop

# Enter Nix shell with project dependencies
nix-shell

# Build the project (when flake.nix is added)
nix build

# Run in Docker container
docker build -t nixvm .
docker run -it nixvm

# Run with Docker Compose (when docker-compose.yml is added)
docker-compose up -d
docker-compose down

# Convert docker-compose to Nix (using compose2nix)
compose2nix docker-compose.yml > docker-compose.nix
```

### Testing Commands

```bash
# Run all tests
npm test  # If using Node.js
pytest   # If using Python
cargo test  # If using Rust

# Run single test file
npm test -- path/to/test.js
pytest path/to/test.py
cargo test test_name

# Run tests in Docker
docker run --rm nixvm npm test
docker run --rm nixvm pytest

# Integration tests
docker-compose -f docker-compose.test.yml up --abort-on-container-exit
```

### Linting and Code Quality

```bash
# Nix linting
nixpkgs-fmt .
nix-linter .

# General linting (when tools are configured)
eslint . --ext .js,.ts
ruff check .  # Python
clippy  # Rust

# Format code
prettier --write .
black .  # Python
cargo fmt  # Rust

# Type checking
tsc --noEmit  # TypeScript
mypy .  # Python
cargo check  # Rust
```

## Code Style Guidelines

### Nix Code Style

- Use `nixpkgs-fmt` for consistent formatting
- Follow the Nixpkgs manual conventions
- Use descriptive variable names in camelCase
- Prefer `callPackage` for package definitions
- Include comments for complex derivations

```nix
# Good: Clear, well-documented package definition
{ stdenv, fetchFromGitHub, python3 }:

stdenv.mkDerivation rec {
  pname = "my-package";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "myorg";
    repo = pname;
    rev = "v${version}";
    sha256 = "0000000000000000000000000000000000000000000000000000";
  };

  buildInputs = [ python3 ];

  meta = with stdenv.lib; {
    description = "My awesome package";
    license = licenses.mit;
    maintainers = [ maintainers.myuser ];
  };
}
```

### Shell Scripts

- Use `#!/usr/bin/env bash` shebang
- Set `set -euo pipefail` for error handling
- Use descriptive variable names in UPPER_CASE
- Include usage documentation
- Follow POSIX shell standards

```bash
#!/usr/bin/env bash
set -euo pipefail

# Usage: ./script.sh [OPTIONS]
#
# Description of what this script does

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

main() {
  local arg="$1"

  echo "Processing: ${arg}"
  validate_input "${arg}"
  process_data "${arg}"
}

validate_input() {
  local input="$1"
  if [[ -z "${input}" ]]; then
    echo "Error: Input cannot be empty" >&2
    exit 1
  fi
}
```

### PHP (if used)

- Use PHP 8.3 with modern features (typed properties, attributes, etc.)
- Include type declarations for function parameters and return values
- Use strict typing (`declare(strict_types=1);`)
- Follow PSR-12 coding standards
- Use Composer for dependency management
- Include extensions: PDO, MySQLi, GD, ZIP, IMAP, Imagick, Mbstring, cURL, Intl, OPcache, Xdebug
- Note: mcrypt extension is not available in PHP 8.3 (removed in PHP 7.2+)

```typescript
interface Config {
  mcpServers: Record<string, MCPServerConfig>;
}

interface MCPServerConfig {
  command: string;
  args: string[];
  env?: Record<string, string>;
}

/**
 * Validates MCP server configuration
 */
function validateConfig(config: Config): boolean {
  if (!config.mcpServers || typeof config.mcpServers !== 'object') {
    throw new Error('Invalid MCP servers configuration');
  }

  for (const [name, server] of Object.entries(config.mcpServers)) {
    if (!server.command) {
      throw new Error(`Server ${name} missing command`);
    }
  }

  return true;
}
```

### Python (if used)

- Follow PEP 8 style guide
- Use type hints for function parameters and return values
- Use descriptive variable names in snake_case
- Include docstrings for modules and functions

```python
from typing import Dict, Optional
import json

def load_mcp_config(config_path: str) -> Dict[str, dict]:
    """
    Load MCP server configuration from JSON file.

    Args:
        config_path: Path to the configuration file

    Returns:
        Dictionary containing MCP server configurations

    Raises:
        FileNotFoundError: If config file doesn't exist
        json.JSONDecodeError: If config file is invalid JSON
    """
    try:
        with open(config_path, 'r') as f:
            config = json.load(f)

        validate_config(config)
        return config
    except FileNotFoundError:
        raise FileNotFoundError(f"Configuration file not found: {config_path}")

def validate_config(config: Dict[str, dict]) -> None:
    """Validate MCP configuration structure."""
    if 'mcpServers' not in config:
        raise ValueError("Configuration must contain 'mcpServers' key")

    for name, server in config['mcpServers'].items():
        if 'command' not in server:
            raise ValueError(f"Server '{name}' missing 'command' field")
```

### Rust (if used)

- Follow rustfmt defaults
- Use descriptive variable names in snake_case
- Include documentation comments for public items
- Use Result types for error handling

```rust
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::fs;
use std::path::Path;

/// MCP server configuration
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Config {
    pub mcp_servers: HashMap<String, MCPServer>,
}

/// Individual MCP server configuration
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MCPServer {
    pub command: String,
    pub args: Vec<String>,
    #[serde(default)]
    pub env: HashMap<String, String>,
}

impl Config {
    /// Load configuration from a JSON file
    pub fn from_file<P: AsRef<Path>>(path: P) -> Result<Self, ConfigError> {
        let contents = fs::read_to_string(path)
            .map_err(|e| ConfigError::Io(e))?;

        let config: Config = serde_json::from_str(&contents)
            .map_err(|e| ConfigError::Parse(e))?;

        config.validate()?;
        Ok(config)
    }

    /// Validate configuration
    pub fn validate(&self) -> Result<(), ConfigError> {
        for (name, server) in &self.mcp_servers {
            if server.command.is_empty() {
                return Err(ConfigError::Invalid(format!(
                    "Server '{}' has empty command",
                    name
                )));
            }
        }
        Ok(())
    }
}

#[derive(Debug, thiserror::Error)]
pub enum ConfigError {
    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),
    #[error("Parse error: {0}")]
    Parse(#[from] serde_json::Error),
    #[error("Invalid configuration: {0}")]
    Invalid(String),
}
```

## Import and Dependency Management

### Nix Dependencies

- Pin nixpkgs to specific commits for reproducibility
- Use overlays for custom packages
- Prefer nixpkgs packages over custom derivations when possible
- Document dependency purposes in comments

```nix
{ pkgs ? import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/22.11.tar.gz";
    sha256 = "1w5aq2s6x7dhqa2yy7z6m4z8x0wf8p8pb0qld0gjk3dzv8v7qrf2";
  }) {}
}:

# Overlay for custom packages
let
  myOverlay = self: super: {
    myCustomPackage = super.callPackage ./packages/my-custom-package.nix {};
  };

  pkgsWithOverlay = import pkgs.path { overlays = [ myOverlay ]; };
in
pkgsWithOverlay.mkShell {
  buildInputs = with pkgsWithOverlay; [
    # Development tools
    git
    docker-compose

    # Language runtimes
    nodejs
    python3

    # MCP server dependencies
    uv  # For running MCP servers via uvx
  ];
}
```

### Container Dependencies

- Use multi-stage Docker builds for smaller images
- Pin base image versions
- Include only necessary dependencies
- Document layer purposes

```dockerfile
# Build stage
FROM nixos/nix:latest AS builder

# Copy source and build
WORKDIR /app
COPY . .
RUN nix build

# Runtime stage
FROM alpine:latest
RUN apk add --no-cache ca-certificates

# Copy built artifacts
COPY --from=builder /app/result /app

# Runtime configuration
EXPOSE 3000
CMD ["/app/bin/server"]
```

## Error Handling and Logging

- Use appropriate error types for each language
- Include contextual error messages
- Log errors with sufficient detail for debugging
- Handle both expected and unexpected errors gracefully

```bash
# Error handling in shell scripts
error_exit() {
  echo "Error: $1" >&2
  exit 1
}

# Check if command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Validate Nix installation
if ! command_exists nix; then
  error_exit "Nix is not installed. Please install Nix first."
fi
```

## File Organization

- Keep configuration files in project root
- Use consistent naming conventions
- Separate concerns into different directories
- Include README files for complex directories

```
├── flake.nix              # Nix flake definition
├── docker-compose.yml     # Docker services
├── .mpc.json             # MCP server configuration
├── src/                  # Source code
│   ├── nix/             # Nix configurations
│   ├── scripts/         # Shell scripts
│   └── docker/          # Docker-related files
├── tests/               # Test files
├── docs/                # Documentation
└── AGENTS.md            # This file
```

## Commit Message Conventions

Follow conventional commit format:

```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat`: New features
- `fix`: Bug fixes
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Test additions/modifications
- `chore`: Maintenance tasks

Examples:
```
feat(mcp): add support for nix-darwin servers
fix(docker): resolve container networking issues
docs: update installation instructions
```

## Security Considerations

- Never commit secrets or API keys
- Use environment variables for sensitive configuration
- Validate all user inputs
- Keep dependencies updated
- Run security scans before deployment

## Performance Guidelines

- Use appropriate caching strategies
- Minimize Docker image layers
- Optimize Nix derivations for rebuild performance
- Profile code for bottlenecks
- Use efficient algorithms and data structures

---

*This document should be updated as the project evolves and new patterns emerge.*</content>
<parameter name="filePath">AGENTS.md