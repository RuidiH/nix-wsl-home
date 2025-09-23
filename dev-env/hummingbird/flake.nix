
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
        lsEndpoint = "http://localhost:4566";

        # real 'terraform' binary that delegates to tofu (works in scripts/Makefiles)
        terraformShim = pkgs.writeShellScriptBin "terraform" ''
          exec ${pkgs.opentofu}/bin/tofu "$@"
        '';

        # awslocal = thin wrapper around aws with LocalStack endpoint
        awslocal = pkgs.writeShellScriptBin "awslocal" ''
          exec ${pkgs.awscli2}/bin/aws --endpoint-url="''${AWS_ENDPOINT_URL:-http://localhost:4566}" "$@"
        '';

      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nodejs_22                # Required: Node 22
            gnumake
            awslocal
            terraformShim
            terraform-local
          ];

          shellHook = ''
            # Claude / AWS env
            export AWS_REGION="us-west-2"
            export CLAUDE_CODE_USE_BEDROCK=1
            export CLAUDE_CODE_MAX_OUTPUT_TOKENS=4096
            export MAX_THINKING_TOKENS=1024
          '';

        };
      });
}