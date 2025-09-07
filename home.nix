{ config, pkgs, ... }:

{
  # Keep this in sync with your Home Manager release
  home.stateVersion = "24.05";

  # User and home directory (must be explicit when using flakes)
  home.username = "ruidih";
  home.homeDirectory = "/home/ruidih";

  programs.home-manager.enable = true;

  # Shell + prompt
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initExtra = "";
  };

  # (Optional) To make zsh the default shell, run: chsh -s $(which zsh)

  programs.starship.enable = true;

  # Per-project environments
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.git.enable = true;

  programs.gh = {
    enable = true;
    settings.git_protocol = "https";
    extensions = with pkgs; [
    ];
  };

  # WSL-friendly environment tweaks
  home.sessionVariables = {
    BROWSER = "wslview"; # open links in Windows default browser
  };

  # Minimal, everyday CLI set — add more as you learn
  home.packages = with pkgs; [
    curl wget unzip zip htop
    awscli2 # AWS CLI v2
    docker  # Docker CLI to talk to Docker Desktop from WSL
  ];
}
