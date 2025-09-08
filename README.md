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

Bootstrap script (new machine)
- Run: `bash scripts/bootstrap.sh`
  - Uses inline `NIX_CONFIG` to enable flakes/nix-command for the first switch.
  - Applies your `home.nix` (which persists the setting for future runs).
  - Afterwards, use the normal daily command above.
  - No git required: you can pass a remote flake.
    - Example: `bash scripts/bootstrap.sh --flake github:<owner>/<repo>#wsl`
    - Or set env: `REMOTE_FLAKE=github:<owner>/<repo>#wsl bash scripts/bootstrap.sh`
    - Nix fetches `github:` flakes via tarballs, so it doesn’t need a git binary.

No-git setup options
- Use a remote flake directly (recommended):
  - `env NIX_CONFIG="experimental-features = nix-command flakes" nix run home-manager/master -- switch --flake github:<owner>/<repo>#wsl`
- Or use ephemeral git via Nix (no apt, no Windows PATH):
  - `env NIX_CONFIG="experimental-features = nix-command flakes" nix shell nixpkgs#git -c git clone https://github.com/<owner>/<repo>.git`
  - Then run the usual switch inside the cloned repo.

PR workflow (GitHub)
- Create branch: `git checkout -b <branch>`
- Stage + commit: `git add -A && git commit -m "<message>"`
- Push branch: `git push -u origin <branch>`
- Open PR (CLI): `gh pr create --fill --title "<title>"`
- Review & merge: `gh pr merge --squash --delete-branch` (or use GitHub UI)
- Update local main: `git switch main && git pull`
- Cleanup local branch: `git branch -d <branch> && git fetch -p`
