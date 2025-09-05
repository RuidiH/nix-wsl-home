Plan: WSL + Nix Home Manager

Purpose
- Keep dev tools reproducible and in sync across WSL machines using Nix + Home Manager.
- Develop entirely inside WSL2; keep Windows for GUI apps (VS Code, browser) and Docker Desktop.

Decisions
- Stack: Ubuntu on WSL2 + Nix + Home Manager (flakes).
- Shell: zsh + starship; extras: direnv + nix-direnv, fzf, eza, bat, zoxide.
- Python: no global pip; use Nix-provided python + uv for per-project envs.
- Containers: Docker Desktop with WSL integration; use docker CLI in WSL.
- PATH hygiene: Prefer Nix binaries; recommend /etc/wsl.conf with appendWindowsPath=false.

Current State (2025-09-05)
- Flake with Home Manager:
  - homeConfigurations: ruidih@Reed-Desk (pinned) and portable-wsl (auto-USER).
  - Modules: modules/home/common.nix (packages, shell) and modules/home/wsl.nix (env tweaks).
  - Host binds: hosts/reed-desk.nix and hosts/portable.nix.
- Packages included: go, gopls, golangci-lint, delve, python312, uv, awscli2, docker (CLI), terraform, gh, postgresql (psql), nodejs_20, corepack, plus common CLI tools (ripgrep, fd, jq/yq, fzf, eza, bat, zoxide, htop/btop, lazygit, neovim, tmux, etc.).

Bootstrap Cheatsheet
- Install Nix (daemon):
  curl -L https://install.determinate.systems/nix | sh -s -- install
- Apply portable config on any WSL user:
  nix run home-manager/master -- switch --flake .#portable-wsl
- Or apply the pinned host config:
  nix run home-manager/master -- switch --flake .#ruidih@Reed-Desk
- Optional: make zsh default shell:
  chsh -s $(which zsh)
- Recommended WSL PATH hygiene (Windows side, then reopen WSL):
  /etc/wsl.conf →
    [interop]
    appendWindowsPath=false
  Then run: wsl --shutdown

Windows Cleanup (safe if you stick to WSL dev)
- Remove: Git for Windows, PuTTY, Graphviz, ffmpeg, Tesseract, Perforce, GStreamer, Node+NVM, Python (3.11/3.13), Go, Terraform, Minikube, Java+Maven, LocalStack.
- Keep: Docker Desktop (for WSL integration), VS Code, Windows Terminal, GPU drivers.

How to Extend
- Add a new host: create hosts/<host>.nix with username/home; add a new homeConfigurations entry in flake.nix.
- Add tools: extend home.packages in modules/home/common.nix; then re-run switch.
- Project devshells: add devShells to flake and use direnv (`use flake`) in project roots.
- Secrets: consider sops + age (optionally sops-nix) when you want to template secrets into config.

Test Checklist
- PATH: `command -v python go node aws docker` → should resolve in ~/.nix-profile or /nix/store.
- Go: `go version && go env GOPATH`
- Python: `python -V && uv --version && uv venv && uv pip install ruff`
- AWS: `aws --version` and SSO/auth flow if used.
- Docker: `docker version` and `docker run hello-world` (uses Docker Desktop).
- Node: `node -v && corepack enable` (if using pnpm/yarn).

Changelog
- 2025-09-05: Initial scaffold (flake, HM modules, host), added terraform, gh, postgresql client, node+corepack, README and portable target.

Open Questions / Next
- Do we need Kubernetes tools (kubectl, helm, k9s)?
- Use opentofu instead of terraform?
- Add gh auth bootstrap or AWS SSO helpers?
- Introduce sops-nix for secrets?
- Add per-project devshell examples (Go/Python/Rust)?

