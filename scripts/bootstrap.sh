#!/usr/bin/env bash
set -euo pipefail

echo "==> Nix WSL/Home Manager bootstrap (flakes + nix-command)"

# Determine flake reference: local repo by default, fallback to env/arg
FLAKE_REF=""

# Resolve script directory to detect repo root if not run from repo root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Prefer CWD if it's the repo root, else try the parent of script dir
if [ -f "flake.nix" ]; then
  FLAKE_REF=".#wsl"
elif [ -f "${REPO_DIR}/flake.nix" ]; then
  FLAKE_REF="${REPO_DIR}#wsl"
fi

while [ $# -gt 0 ]; do
  case "$1" in
    --flake)
      FLAKE_REF="$2"; shift 2 ;;
    -f)
      FLAKE_REF="$2"; shift 2 ;;
    *)
      echo "Unknown arg: $1" >&2; exit 2 ;;
  esac
done

if [ -z "${FLAKE_REF}" ]; then
  if [ -n "${REMOTE_FLAKE:-}" ]; then
    FLAKE_REF="$REMOTE_FLAKE"
  else
    echo "Hint: Run inside the repo (flake.nix present) or pass --flake <ref> (e.g., github:<owner>/<repo>#wsl)." >&2
    echo "You can also set REMOTE_FLAKE env var." >&2
    exit 2
  fi
fi

# Ensure `nix` is available in non-login shells (WSL/new terminals)
if ! command -v nix >/dev/null 2>&1; then
  # Try common profile hooks installed by Nix
  for f in \
    /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh \
    /etc/profile.d/nix-daemon.sh \
    /etc/profile.d/nix.sh \
    "$HOME/.nix-profile/etc/profile.d/nix.sh"; do
    if [ -r "$f" ]; then
      # shellcheck disable=SC1090
      . "$f"
    fi
  done
fi

# Fallback: prepend default nix profile bin if present
if ! command -v nix >/dev/null 2>&1; then
  if [ -x /nix/var/nix/profiles/default/bin/nix ]; then
    PATH="/nix/var/nix/profiles/default/bin:$PATH"
  fi
fi

if ! command -v nix >/dev/null 2>&1; then
  echo "Error: nix not found in PATH."
  echo "Hints: avoid 'sudo', open a new login shell, or source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" >&2
  exit 1
fi

echo "-- Nix version: $(nix --version || true)"

echo "-- One-time switch with inline experimental features"
echo "   Using flake: ${FLAKE_REF}"

# Resolve Home Manager flake reference robustly (avoid relying on registry)
HM_REF="home-manager/master"
if ! env NIX_CONFIG="experimental-features = nix-command flakes" nix flake metadata "${HM_REF}" >/dev/null 2>&1; then
  HM_REF="github:nix-community/home-manager/master"
fi

echo "   Home Manager ref: ${HM_REF}"
echo "   Running: env NIX_CONFIG=\"experimental-features = nix-command flakes\" nix run ${HM_REF} -- switch --flake ${FLAKE_REF}"

env NIX_CONFIG="experimental-features = nix-command flakes" \
  nix run "${HM_REF}" -- switch --flake "${FLAKE_REF}"

printf "\n==> Verifying experimental features are now persisted by Home Manager\n"
nix show-config | sed -n 's/^experimental-features = /experimental-features: /p' || true

printf "\nAll set. For daily updates, use:\n"
echo "  nix run home-manager/master -- switch --flake ${FLAKE_REF}"
printf "\nOptional: Make zsh your default shell (manual):\n"
echo "  chsh -s \"$(command -v zsh)\""
echo "Then restart WSL from Windows:  wsl --shutdown"
