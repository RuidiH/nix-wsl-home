{
  description = "WSL Ubuntu + Nix + Home Manager for dev (zsh, starship, go, python+uv, aws, docker)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Unstable for a few newer tools like `uv`.
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, home-manager, nixpkgs-unstable, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
      unstable = import nixpkgs-unstable { inherit system; config.allowUnfree = true; };
    in {
      # Home Manager user environment for this WSL host
      homeConfigurations = {
        # Adjust to match your WSL username/host if needed
        "ruidih@Reed-Desk" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./modules/home/common.nix
            ./modules/home/wsl.nix
            ./hosts/reed-desk.nix
          ];
          extraSpecialArgs = {
            hostname = "Reed-Desk";
            isWSL = true;
            inherit unstable;
          };
        };

        # Portable target: uses the current $USER and home path.
        # Handy to test on another WSL machine without adding a host file first.
        "portable-wsl" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./modules/home/common.nix
            ./modules/home/wsl.nix
            ./hosts/portable.nix
          ];
          extraSpecialArgs = {
            hostname = "portable";
            isWSL = true;
            inherit unstable;
          };
        };
      };

      # Optional example devshell you can use with `nix develop` at repo root.
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          git jq yq-go ripgrep fd which coreutils
          go gopls golangci-lint delve
          awscli2 docker
          python312
          unstable.uv
        ];
      };
    };
}
