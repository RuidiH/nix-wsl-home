
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
            localstack
            awscli-local
          ];

          # Claude code env
          AWS_REGION="us-west-2";
          CLAUDE_CODE_USE_BEDROCK=1;
          CLAUDE_CODE_MAX_OUTPUT_TOKENS=4096;
          MAX_THINKING_TOKENS=1024;
          ANTHROPIC_MODEL="us.anthropic.claude-opus-4-1-20250805-v1:0";
        };
      });
}