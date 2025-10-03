{
  description = "Portable development environment with Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    # Helper function to create home configurations
    makeHomeConfig = { username, isWSL ? false }:
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home.nix
          {
            # Pass configuration as module arguments
            home.username = username;
            home.homeDirectory = "/home/${username}";
            _module.args = { inherit isWSL; };
          }
        ];
      };
  in {
    # Accumulated machine-specific configurations
    homeConfigurations = {
      # Default fallback configuration
      "default" = makeHomeConfig { username = "user"; isWSL = false; };

      # Current machine configuration
      "ruidih-fedora" = makeHomeConfig { username = "ruidih"; isWSL = false; };
    };
  };
}