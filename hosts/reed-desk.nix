{ config, pkgs, hostname, isWSL, ... }:

{
  # Bind this Home Manager config to your WSL user and home dir
  home.username = "ruidih";
  home.homeDirectory = "/home/ruidih";

  # Optional: make zsh your login shell (you may still need `chsh -s`) 
  programs.zsh.loginShell = true;
}

