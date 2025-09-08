# Learning Checkpoints (newest first)

- 2025-09-08: PATH/bootstrap — Non-login shells may miss `nix`. Q: How to make `nix` visible? → A: Source the daemon profile script. Exercise: `. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh && which nix`. Links: 
- 2025-09-08: Nix settings assertion — `nix.settings` requires `nix.package`. Q: How to fix? → A: Set `nix.package = pkgs.nix;`. Exercise: Confirm with `nix show-config | rg experimental-features`. Links: 
- 2025-09-08: Home Manager role — HM builds/activates user env and manages generations and dotfiles. Q: Why use HM? → A: Declarative config + rollbacks. Exercise: After switch, list `home-manager generations`. Links: 
- 2025-09-08: Remote flakes — Nix can fetch `github:<owner>/<repo>#wsl` without Git. Q: Where is it stored? → A: In `/nix/store/<hash>-source`. Exercise: Run `nix flake metadata github:<owner>/<repo>`. Links: 
- 2025-09-08: Flake attributes — `.#wsl` selects `homeConfigurations.wsl` from this flake. Q: Is `.#wsl` a file? → A: No, it’s an attribute reference into flake outputs. Exercise: Run `nix flake show .` and locate `wsl`. Links: 
