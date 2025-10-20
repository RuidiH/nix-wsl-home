{
  description = "stable concept map from Piyush";

  inputs = {
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
      flake-utils.url = "github:numtide/flake-utils";
    };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        python = pkgs.python313.withPackages (ps: with ps; [
          # From pyproject.toml
          openai
          pydantic
          networkx
          numpy
          scikit-learn
          tiktoken
          matplotlib
          streamlit
          pypdf
          rank-bm25
          pyvis
        ]);
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [python];
          shellHook = ''
            export AWS_REGION="us-west-2"
            export CLAUDE_CODE_USE_BEDROCK=1
            export CLAUDE_CODE_MAX_OUTPUT_TOKENS=4096
            export MAX_THINKING_TOKENS=1024
            export AWS_PROFILE="insurgent"
          '';
        };
      });

}
