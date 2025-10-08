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
  enableZshIntegration = true;
  settings = {
    aws.style = "bold #ffb86c";
    cmd_duration.style = "bold #f1fa8c";
    directory.style = "bold #50fa7b";
    hostname.style = "bold #ff5555";
    git_branch.style = "bold #ff79c6";
    git_status.style = "bold #ff5555";
    username = {
      format = "[$user]($style) on ";
      style_user = "bold #bd93f9";
    };
    character = {
      success_symbol = "[λ](bold #f8f8f2)";
      error_symbol = "[λ](bold #ff5555)";
    };
  };
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
