WSL + Nix + Home Manager
=========================

What this repo gives you
- Reproducible WSL user environment managed by Home Manager
- Zsh + starship, direnv + nix-direnv
- Core dev tools: go, python + uv (no global pip), awscli2, docker CLI, terraform, gh, postgresql client, node+corepack
- Useful CLI set: ripgrep, fd, jq/yq, bat, eza, zoxide, fzf, htop/btop, lazygit, neovim, tmux

High-level model
- Dev tools live in WSL and are installed via Nix (Linux binaries).
- Windows stays for GUI apps (VS Code, browser) and Docker Desktop (optional but easiest).
- Config and data are portable: SSH keys, Git config, AWS creds, kubeconfig, etc.
- Prefer WSL Linux filesystem for code (not /mnt/c) for performance.

How flakes + Home Manager work
- flake.nix pins inputs (nixpkgs, home-manager) and defines outputs.
- homeConfigurations.<user@host> declares a full user environment (packages, shells, dotfiles).
- home-manager applies the config with `switch` to build + activate your profile.
- You commit this repo; on another machine, you run the same `switch` to sync.

Bootstrap (on this WSL Ubuntu)
1) Ensure Nix is installed (daemon installer recommended).
   curl -L https://install.determinate.systems/nix | sh -s -- install

2a) Quick portable test on any WSL user:
   nix run home-manager/master -- switch --flake .#portable-wsl

2b) Or apply the pinned host config for this machine:
   nix run home-manager/master -- switch --flake .#ruidih@Reed-Desk

3) Make zsh your default shell (optional):
   chsh -s $(which zsh)

4) Windows PATH hygiene (recommended):
   Edit /etc/wsl.conf and set:
     [interop]
     appendWindowsPath=false
   Then from Windows run: wsl --shutdown

Terminal polish
- Install a Nerd Font on Windows (e.g., JetBrainsMono Nerd Font) and set it in Windows Terminal for your Ubuntu profile.
- Starship prompt is enabled and minimal; tweak modules in programs.starship.settings.
- Aliases: ls -> eza, cat -> bat, FZF wired to ripgrep.

Add another machine later
- Option A (quick): keep using `portable-wsl` on any WSL user.
- Option B (pinned): create hosts/<host>.nix with that machine's username/home, then add a new entry under `homeConfigurations` in flake.nix.

Create a Git repo
- Rename this folder to a better repo name (examples below), then:
  git init
  git add .
  git commit -m "init: WSL + Nix Home Manager"
  git branch -M main
  git remote add origin <your-repo-url>
  git push -u origin main

Name ideas
- nix-wsl-home (clear and simple)
- nix-wsl-dev (focus on dev tooling)
- workbench-nix (broader, still concise)
- foundry-nix (short, memorable)

Project-level environments (recommended)
- Use direnv + nix-direnv with `use flake` in your project to get clean per-repo deps.
- Or use uv for Python projects: uv venv; uv pip install -r requirements.txt (no global pip).
