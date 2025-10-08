{ config, pkgs, isWSL ? false, ... }:
{
  nix = {
    package = pkgs.nix;
    settings.experimental-features = ["nix-command" "flakes"];
  };

  # Keep this in sync with your Home Manager release
  home.stateVersion = "24.05";

  # User and home directory set by flake.nix configuration 

  programs.home-manager.enable = true;

  # Shell + prompt
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    # point zsh to docker user socket
    initContent = ''
      export DOCKER_HOST=unix:///run/user/$UID/docker.sock
    '';
    shellAliases = {
      terraform = "tofu";  # interactive convenience
      tf = "tofu";
    };
  };

  # (Optional) To make zsh the default shell, run: chsh -s $(which zsh)

programs.starship = {
  enable = true;

  settings =
    let
      presetFile = pkgs.fetchurl {
        url = "https://starship.rs/presets/toml/tokyo-night.toml";
        sha256 = "sha256-eSIlVW89801BlI5d1VpAd2l2AX5trG43o1s62931uzE=";
      };
      preset = builtins.fromTOML (builtins.readFile presetFile);

      # Replace the hard-coded icon box with a styled $os box.
      # IMPORTANT: the "[ ... ](style)" wrapper paints the background,
      # so the bar looks continuous again.
      formatWithOs =
        builtins.replaceStrings
          ["[  ]"]                # what the preset ships
          ["[ $os ](bg:#24283b fg:#7aa2f7)"]  # same bracketed box but driven by $os
          preset.format;

      override = {
        format = formatWithOs;

        os = {
          disabled = false;
          # Only the symbol inside the box; the box colors come from the wrapper above.
          format = "$symbol";
          symbols = {
            Arch  = "";   # the Arch glyph
            Macos = "";   # optional: force Arch glyph on macOS too
          };
        };
      };
    in
      pkgs.lib.recursiveUpdate preset override;
};

  # Per-project environments
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.git = {
    enable = true;
    userName = "RuidiH";
    userEmail = "764342051@qq.com";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      rebase.autoStash = true;
      fetch.prune = true;
      push.autoSetupRemote = true;
      color.ui = "auto";
      core.editor = "code --wait";
    };
  };

  # WSL-specific environment tweaks (conditional)
  home.sessionVariables = if isWSL then {
    BROWSER = "wslview"; # open links in Windows default browser
  } else {};

  # Base packages for everyone
  home.packages = with pkgs; [
    curl
    wget
    unzip
    zip
    htop
    awscli2 # AWS CLI v2
    docker # Docker CLI
    claude-code
    docker-compose
    opentofu
  ] ++ pkgs.lib.optionals isWSL [
    wslu # Only on WSL for wslview command
  ];
}
