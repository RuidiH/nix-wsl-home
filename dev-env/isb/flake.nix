{
  description = "Minimal dev environment for Innovation Sandbox on AWS deployment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nodejs_22                # Required: Node 22
            nodePackages.aws-cdk     # Required: AWS CDK for deployment
          ];

          shellHook = ''
            echo "Node $(node --version) | npm $(npm --version) | CDK $(cdk --version 2>/dev/null || echo 'loading...')"
          '';
        };
      });
}