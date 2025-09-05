{ config, pkgs, unstable, ... }:

{
  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  # Shell + prompt
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    # Small quality-of-life defaults
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
    # Handy plugins
    plugins = [
      { name = "zsh-autosuggestions"; src = pkgs.zsh-autosuggestions; }
      { name = "zsh-syntax-highlighting"; src = pkgs.zsh-syntax-highlighting; }
    ];
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      command_timeout = 1200;
      format = "$all";
      # Keep the prompt clean but informative
      scan_timeout = 30;
      directory.truncation_length = 3;
      git_branch.symbol = " ";
      git_status.disabled = false;
      nodejs.disabled = true; # enable later if you add Node
      python = { disabled = false; pyenv_version_name = false; }; 
      golang = { disabled = false; }; 
      docker_context.disabled = false;
    };
  };

  # Direnv + nix-direnv for per-project environments
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.git = {
    enable = true;
    delta.enable = true;
    extraConfig = {
      core.autocrlf = "input";
      pull.rebase = true;
      init.defaultBranch = "main";
    };
  };

  programs.fzf.enable = true;
  programs.bat.enable = true;
  programs.eza.enable = true;
  programs.zoxide.enable = true;

  # Core CLI toolchain and dev tools
  home.packages = with pkgs; [
    # Essentials
    ripgrep fd jq yq-go curl wget tree htop btop unzip zip which

    # Dev: Go stack
    go gopls golangci-lint delve

    # Dev: Python + uv for environments (no global pip)
    python312
    unstable.uv

    # Cloud + containers
    awscli2
    docker

    # Infra/Cloud extras
    terraform
    gh

    # Databases (client)
    postgresql

    # JavaScript/Node tooling
    nodejs_20
    corepack

    # Nice-to-haves
    neovim tmux lazygit
  ];
}
