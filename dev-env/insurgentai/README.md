# Internship Backend Environment Setup

## Per-Machine Setup (One Time)


### 1. Apply home-manager configuration to private nix repo
```bash
home-manager switch --flake .#wsl
```

### 2. Setup project
```bash
# setup ssh key

# Clone the internship repo
git clone git@github.com:insurgentaiorg/june-demo.git ~/home/ruidi/projects
git checkout develop

# Create symlink to .envrc
cd ~/home/ruidi/projects/june-demo
ln -s ~/home/ruidi/projects/nix-wsl-home/dev-env/insurgentai/.envrc .envrc

# Add to local git excludes (won't affect team)
echo ".envrc" >> .git/info/exclude
echo ".direnv/" >> .git/info/exclude

# Allow direnv
direnv allow
```