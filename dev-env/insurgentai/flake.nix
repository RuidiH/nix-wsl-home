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
            pass
            jq
            gnupg
            aws-vault
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

          # ========= Config you can tweak =========
          TEMPLATE_ENV="${TEMPLATE_ENV:-./back-end/src/services/.envs/.env.secrets.TEMPLATE}"
          OUTPUT_ENV="${OUTPUT_ENV:-./back-end/src/services/.envs/.env.secrets}"

          # aws-vault backend + base profile (the one you did `aws-vault add <name>` for)
          export AWS_VAULT_BACKEND="${AWS_VAULT_BACKEND:-pass}"
          AWS_BASE_PROFILE="${AWS_BASE_PROFILE:-insurgent}"   # <- string, not exported
          AWS_SESSION_DURATION="${AWS_SESSION_DURATION:-12h}"

          # Default region
          export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-us-west-2}"
          export AWS_REGION="$AWS_DEFAULT_REGION"

          # App-facing profile that uses credential_process in ~/.aws/config
          # Keep this as the global default so CLI/SDKs work automatically.
          export AWS_PROFILE="${AWS_PROFILE:-insurgent-app}"

          # ========= Sanity checks =========
          if [ ! -f "$TEMPLATE_ENV" ]; then
            echo "[aws] Template $TEMPLATE_ENV not found. Create it first." >&2
            return 1
          fi

          # Avoid stale static creds sneaking in
          unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_SECURITY_TOKEN

          # ========= Mint short-lived creds (MFA if cache is cold) =========
          JSON="$(aws-vault exec "$AWS_BASE_PROFILE" --duration="$AWS_SESSION_DURATION" --json)"

          AKID="$(echo "$JSON" | jq -r .AccessKeyId)"
          SAK="$(echo "$JSON" | jq -r .SecretAccessKey)"
          STS="$(echo "$JSON" | jq -r .SessionToken)"
          EXP="$(echo "$JSON" | jq -r .Expiration)"

          if [ -z "$AKID" ] || [ -z "$SAK" ] || [ -z "$STS" ]; then
            echo "[aws] Failed to obtain temporary credentials." >&2
            return 1
          fi

          # ========= Build .env from template (replace only AWS lines) =========
          TMP="$OUTPUT_ENV.tmp"
          esc() { printf '%s' "$1" | sed -e 's/[\\/&]/\\&/g'; }

          sed \
            -e "s/^AWS_ACCESS_KEY_ID *= *\".*\"/AWS_ACCESS_KEY_ID=\"$(esc "$AKID")\"/" \
            -e "s/^AWS_SECRET_ACCESS_KEY *= *\".*\"/AWS_SECRET_ACCESS_KEY=\"$(esc "$SAK")\"/" \
            "$TEMPLATE_ENV" > "$TMP"

          # Append token & region (template doesn't have them)
          {
            echo ""
            echo "# --- appended by devShell on $(date -Iseconds) ---"
            echo "AWS_SESSION_TOKEN=\"$STS\""
            echo "AWS_REGION=\"$AWS_REGION\""
            echo "AWS_DEFAULT_REGION=\"$AWS_REGION\""
            echo "# Expires: $EXP"
          } >> "$TMP"

          mv "$TMP" "$OUTPUT_ENV"
          echo "[aws] Wrote short-lived AWS creds to $OUTPUT_ENV (expires: $EXP)"

          # ========= Claude / Bedrock env (no profile collisions) =========
          # Make Claude Code (and any child process) see Bedrock creds
          export AWS_ACCESS_KEY_ID="$AKID"
          export AWS_SECRET_ACCESS_KEY="$SAK"
          export AWS_SESSION_TOKEN="$STS"
          export AWS_STS_REGIONAL_ENDPOINTS=regional 

          # Keep these feature flags, but DO NOT overwrite AWS_PROFILE here.
          export CLAUDE_CODE_USE_BEDROCK=1
          export CLAUDE_CODE_MAX_OUTPUT_TOKENS=4096
          export MAX_THINKING_TOKENS=1024

          # Helper to run any command with a fresh STS session (if you prefer)
          run-aws() {
            aws-vault exec "$AWS_BASE_PROFILE" --duration="$AWS_SESSION_DURATION" -- "$@"
          }
          # Example: run-aws uvicorn app.main:app --reload

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
