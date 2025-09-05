{ config, pkgs, ... }:

{
  # Portable mapping: infer user and home from environment
  # Good for quick tests on another WSL machine
  home.username = builtins.getEnv "USER";
  home.homeDirectory = "/home/${builtins.getEnv "USER"}";

  programs.zsh.loginShell = true;
}

