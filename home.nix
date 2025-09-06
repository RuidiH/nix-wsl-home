{ config, pkgs, ... }:

{
  # Keep this in sync with your Home Manager release
  home.stateVersion = "24.05";

  # Portable mapping: infer user and home from environment
  home.username = builtins.getEnv "USER";
  home.homeDirectory = "/home/${builtins.getEnv "USER"}";

  programs.home-manager.enable = true;

  # Shell + prompt
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initExtra = ''
      # Prefer eza over ls
      alias ls='eza --icons=auto --group-directories-first'
      alias ll='eza -l --icons=auto --group-directories-first'
      alias la='eza -la --icons=auto --group-directories-first'

      # Better cat
      alias cat='bat --style=plain'

      # Jump directories quickly
      eval "$(zoxide init zsh)"

      # FZF sensible defaults
      export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob !.git/'
      export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    '';
  };

  programs.starship.enable = true;

  # Per-project environments
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.git.enable = true;
  programs.fzf.enable = true;
  programs.bat.enable = true;
  programs.eza.enable = true;
  programs.zoxide.enable = true;

  # WSL-friendly environment tweaks
  home.sessionVariables = {
    BROWSER = "wslview"; # open links in Windows default browser
  };

  # Minimal, everyday CLI set — add more as you learn
  home.packages = with pkgs; [
    ripgrep fd jq yq-go curl wget unzip zip htop
    gh # GitHub CLI (verified in your local profile)
    awscli2 # AWS CLI v2
    docker  # Docker CLI to talk to Docker Desktop from WSL
  ];
}
