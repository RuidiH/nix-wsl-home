
{
  description = "LocalStack Env";

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
          ];

          shellHook = ''
            unset PYTHONPATH PYTHONHOME

            # claude code
            AWS_REGION="us-west-2";
            CLAUDE_CODE_USE_BEDROCK=1;
            CLAUDE_CODE_MAX_OUTPUT_TOKENS=4096;
            MAX_THINKING_TOKENS=1024;
          '';
        };
      });
}