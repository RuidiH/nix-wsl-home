# Portable Development Environment

A minimal, portable development environment managed by Nix + Home Manager.

## What this gives you
- **Development tools**: Zsh + Starship, direnv + nix-direnv, Git, GitHub CLI, basic CLIs
- **Cross-platform**: Works on WSL Ubuntu, native Fedora, Arch Linux, and other Linux distributions
- **Pure evaluation**: Reproducible builds without runtime dependencies
- **Project environments**: Per-project dev shells via direnv flakes

## Quick Start

### 1. Install Nix
```bash
curl -L https://install.determinate.systems/nix | sh -s -- install
```

### 2. Bootstrap your environment
```bash
bash scripts/bootstrap.sh
```

The bootstrap script will:
- Detect your OS and username
- Find or guide you to create the right configuration
- Apply your development environment

### 3. Daily usage
```bash
# Update environment
home-manager switch --flake .#ruidih-fedora  # (your config name)

# Update dependencies
nix flake update
```

### 4. Optional: Set zsh as default shell
```bash
chsh -s $(which zsh)
```

## Configuration System

This project uses a **config accumulation pattern**:

```nix
# flake.nix homeConfigurations
"default" = makeHomeConfig { username = "user"; isWSL = false; };
"ruidih-fedora" = makeHomeConfig { username = "ruidih"; isWSL = false; };
"ruidih-ubuntu-wsl" = makeHomeConfig { username = "ruidih"; isWSL = true; };
# Configs accumulate as you add machines
```

**Adding a new machine:**
1. Run `bash scripts/bootstrap.sh`
2. If your config doesn't exist, add the suggested line to `flake.nix`
3. Commit the change and run bootstrap again

## Per-Project Development Environments

### Using Project Flakes
```bash
# In your project directory
ln -s $(git rev-parse --show-toplevel)/dev-env/PROJECT/.envrc .envrc
direnv allow
echo ".envrc" >> .git/info/exclude
echo ".direnv/" >> .git/info/exclude
```

### Available Templates
- **insurgentai**: Python with uv, AWS tools, Claude Code environment
- **isb**: Terraform/OpenTofu for AWS deployment
- **hummingbird**: Development environment template
- **localstack**: Local AWS testing environment

## Package Management

### Why nixpkgs-unstable?
- Latest development tools and compilers
- Immediate security updates
- Suitable for non-critical dev environments
- Still reproducible via flake.lock

### Updating
```bash
# Update all inputs
nix flake update

# Update specific input
nix flake lock --update-input nixpkgs

# View current pins
nix flake info

# Pin specific nixpkgs commit (if something breaks)
nix flake lock --update-input nixpkgs --override-input nixpkgs github:NixOS/nixpkgs/<commit-hash>
```

## Development Guide

### Project Structure
- `flake.nix`: Main configuration entry point
- `home.nix`: User environment packages and settings
- `dev-env/`: Project-specific development flakes
- `scripts/bootstrap.sh`: Environment detection and setup

### Commands
```bash
# Apply configuration
home-manager switch --flake .#<config-name>

# Dry-run switch
home-manager switch --flake .#<config-name> --dry-run

# Build activation package only
nix build .#homeConfigurations.<config-name>.activationPackage

# Format Nix code
nix run nixpkgs#alejandra -- .

# Lint shell scripts
nix run nixpkgs#shellcheck -- -S style scripts/bootstrap.sh
```