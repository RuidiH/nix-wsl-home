WSL + Nix + Home Manager (Simple)
=================================

What this repo gives you
- A minimal, portable WSL user environment managed by Home Manager.
- Zsh + Starship, direnv + nix-direnv, a few everyday CLIs (ripgrep, fd, jq, eza, bat, fzf, zoxide) and GitHub CLI (`gh`).

How it’s structured (simple on purpose)
- `flake.nix`: pins `nixpkgs` and Home Manager and exposes a single `homeConfigurations.wsl` target.
- `home.nix`: your entire Home Manager config in one place. Easy to read and extend.

Quick start (on WSL Ubuntu)
1) Install Nix (daemon installer recommended):
   curl -L https://install.determinate.systems/nix | sh -s -- install

2) Apply this config to your user:
   nix run home-manager/master -- switch --flake .#wsl

3) Optional: make zsh your default shell:
   chsh -s $(which zsh)

4) Recommended WSL PATH hygiene:
   Edit /etc/wsl.conf and set:
     [interop]
     appendWindowsPath=false
   Then from Windows run: wsl --shutdown

Customize
- Add or remove packages in `home.nix` under `home.packages` (e.g., add `docker`, `awscli2`, `nodejs_20`).
- Adjust zsh aliases and Starship by editing the relevant sections in `home.nix`.
- Learn incrementally: keep this simple base, layer more tools as you go.

Notes
- `gh` is included here and also detected in your local Nix profile; managing it via Home Manager keeps it reproducible.
- Prefer working under the Linux filesystem (not `/mnt/c`) for performance.

