{ config, pkgs, ... }:

{
  # WSL-friendly environment tweaks
  home.sessionVariables = {
    BROWSER = "wslview"; # open links in Windows default browser
  };

  # Helpful notes (not enforced here):
  # To avoid accidentally using Windows binaries inside WSL, consider:
  #   /etc/wsl.conf ->
  #     [interop]
  #     appendWindowsPath=false
  # Then run `wsl --shutdown` from Windows and reopen.
}

