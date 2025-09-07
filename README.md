WSL + Nix + Home Manager (Simple)
=================================

What this repo gives you
- A minimal, portable WSL user environment managed by Home Manager.
- Zsh + Starship, direnv + nix-direnv, Git, GitHub CLI (`gh`), and basic CLIs (curl, wget, unzip, zip, htop, awscli2, Docker CLI).

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

 

Optional tools you can add later
- eza: modern `ls` with icons.
  - Enable: add `programs.eza.enable = true;`
  - Optional aliases (if desired): `alias ls='eza ...'`, `ll`, `la`
- bat: `cat` with syntax highlighting.
  - Enable: add `programs.bat.enable = true;`
  - Optional alias: `alias cat='bat --style=plain'`
- fzf: fuzzy finder for files/anything.
  - Enable: add `programs.fzf.enable = true;`
  - Optional speed-up: set `FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob !.git/'` and `FZF_CTRL_T_COMMAND` in zsh init; requires `ripgrep`.
- zoxide: smarter `cd` by frecency.
  - Enable: add `programs.zoxide.enable = true;`
- ripgrep (`rg`): fast text search.
  - Install: add `ripgrep` to `home.packages`.
- fd: simple, fast alternative to `find`.
  - Install: add `fd` to `home.packages`.
- jq: JSON processor.
  - Install: add `jq` to `home.packages`.
- yq-go (`yq`): YAML processor (Go version).
  - Install: add `yq-go` to `home.packages`.

GitHub CLI via Home Manager
- Enable module: add a block like:
  - `programs.gh = { enable = true; settings.git_protocol = "https"; extensions = with pkgs; [ ]; };`
- Note: `git_protocol` accepts `https` or `ssh`. Use `https` with a personal access token via `gh auth login`.

Current status summary (from `home.nix`)
- Enabled modules: zsh, starship, direnv (with nix-direnv), git, gh (module present but needs syntax fixes).
- Installed packages: curl, wget, unzip, zip, htop, awscli2, Docker CLI.
- Not present by default: eza, bat, fzf, zoxide, ripgrep, fd, jq, yq-go.

Heads-up on `gh` config
- Ensure semicolons and nesting are correct:
  - Good:
    - `programs.gh = { enable = true; settings.git_protocol = "https"; extensions = with pkgs; [ ]; };`
  - Avoid:
    - Missing semicolons, or repeating `programs.gh.` inside the block.

Notes
- `gh` is included here and also detected in your local Nix profile; managing it via Home Manager keeps it reproducible.
- Prefer working under the Linux filesystem (not `/mnt/c`) for performance.
