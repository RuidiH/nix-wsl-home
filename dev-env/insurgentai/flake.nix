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
            jq
            redisinsight
          ];
      in
      {
        devShells.default = pkgs.mkShell {
          packages = toolPkgs;

          # Expose runtime libs to the dynamic linker
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath runtimeLibs;


          # Python isolation for uv
          shellHook = ''
          # --- BEGIN shellHook ---
          set -euo pipefail

          # ========= AWS Configuration =========
          # Set region for local shell (Docker containers read from .env.aws)
          export AWS_DEFAULT_REGION=''${AWS_DEFAULT_REGION:-us-west-2}
          export AWS_REGION="$AWS_DEFAULT_REGION"
          export AWS_PROFILE=insurgent

          # ========= Claude Code feature flags =========
          export CLAUDE_CODE_USE_BEDROCK=1
          export CLAUDE_CODE_MAX_OUTPUT_TOKENS=4096
          export MAX_THINKING_TOKENS=1024

          # ========= Git over 443 for restricted networks =========
          export GIT_SSH_COMMAND='ssh -o Hostname=ssh.github.com -o Port=443 -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new'

          # ========= Python (uv) bootstrap =========
          unset PYTHONPATH PYTHONHOME
          PROJECT_DIR="back-end"

          # Let uv download Python if missing
          export UV_PYTHON_DOWNLOADS=1

          # Create venv if missing
          if [ ! -d "$PROJECT_DIR/.venv" ]; then
            uv venv --project "$PROJECT_DIR" --python 3.12 --seed
          fi

          # Activate venv
          . "$PROJECT_DIR/.venv/bin/activate"

          # Sync deps (locked if uv.lock exists)
          if [ -f "$PROJECT_DIR/uv.lock" ]; then
            uv sync --project "$PROJECT_DIR" --frozen --all-groups --all-extras
          else
            uv sync --project "$PROJECT_DIR" --all-groups --all-extras
          fi

          # Optional: warm AWS credential_process cache so first CLI call is snappy
          aws sts get-caller-identity >/dev/null 2>&1 || true
          # --- END shellHook ---
          '';

        };
      });
}
