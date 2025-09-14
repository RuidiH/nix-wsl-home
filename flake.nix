{
  description = "Simple WSL + Home Manager setup (zsh, starship, basic CLI, gh)";

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
    # claude-code,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    # Single, portable Home Manager config applied as `.#wsl`
    homeConfigurations = {
      "wsl" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [./home.nix];
      };
    };
  };
}