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

          # Claude code env
          shellHook = ''
            unset PYTHONPATH PYTHONHOME
            export AWS_REGION="us-west-2"
            export CLAUDE_CODE_USE_BEDROCK=1
            export CLAUDE_CODE_MAX_OUTPUT_TOKENS=4096
            export MAX_THINKING_TOKENS=1024
            export AWS_PROFILE="insurgent"
          ''
        };
      });
}
