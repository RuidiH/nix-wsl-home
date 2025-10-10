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
          ];
      in
      {
        devShells.default = pkgs.mkShell {
          packages = toolPkgs;

          # Expose runtime libs to the dynamic linker
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath runtimeLibs;


          # Python isolation for uv
          shellHook = ''
            # Claude code env
            export AWS_REGION="us-west-2"
            export CLAUDE_CODE_USE_BEDROCK=1
            export CLAUDE_CODE_MAX_OUTPUT_TOKENS=4096
            export MAX_THINKING_TOKENS=1024
            export AWS_PROFILE="insurgent"

            unset PYTHONPATH PYTHONHOME

            # uv 
            set -eu
            PROJECT_DIR="back-end"
            
            # allow uv to download python if cannot find one
            export UV_PYTHON_DOWNLOADS=1
           
            # create virtual environment once
            if [ ! -d "$PROJECT_DIR/.venv" ]; then
              uv venv --project "$PROJECT_DIR" --python 3.12 --seed
            fi
            
            # activate venv, prepends .../.venv/bin to path
            . "$PROJECT_DIR/.venv/bin/activate"

            # sync dependencies
            if [ -f "$PROJECT_DIR/uv.lock" ]; then
              # if locked, don't change version, use the exact lock
              uv sync --project "$PROJECT_DIR" --frozen 
            else 
              uv sync --project "$PROJECT_DIR"
            fi
          '';

        };
      });
}
