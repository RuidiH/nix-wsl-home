{
  description = "InsurgentAI environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        runtimeLibs = with pkgs; [
          stdenv.cc.cc.lib
          # glibc
          zlib
        ];
        
        toolPkgs = with pkgs; [
            uv
            gcc 
            # python312
          ];
      in
      {
        devShells.default = pkgs.mkShell {
          packages = toolPkgs;

          # Expose runtime libs to the dynamic linker
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath runtimeLibs;

          # Claude code env
          AWS_REGION="us-west-2";
          CLAUDE_CODE_USE_BEDROCK=1;
          CLAUDE_CODE_MAX_OUTPUT_TOKENS=4096;
          MAX_THINKING_TOKENS=1024;
          ANTHROPIC_MODEL="us.anthropic.claude-opus-4-1-20250805-v1:0";

          # Python isolation for uv
          shellHook = ''
            unset PYTHONPATH PYTHONHOME
          '';

        };
      });
}