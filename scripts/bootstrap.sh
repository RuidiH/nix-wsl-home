#!/usr/bin/env bash
set -euo pipefail

echo "==> Nix WSL/Home Manager bootstrap (flakes + nix-command)"

# Determine flake reference: local repo by default, fallback to env/arg
FLAKE_REF=""
if [ -f "flake.nix" ]; then
  FLAKE_REF=".#wsl"
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

if ! command -v nix >/dev/null 2>&1; then
  echo "Error: nix not found. Install Nix first (see README Quick start)." >&2
  exit 1
fi

echo "-- Nix version: $(nix --version || true)"

echo "-- One-time switch with inline experimental features"
echo "   Using flake: ${FLAKE_REF}"
echo "   Running: env NIX_CONFIG=\"experimental-features = nix-command flakes\" nix run home-manager/master -- switch --flake ${FLAKE_REF}"

env NIX_CONFIG="experimental-features = nix-command flakes" \
  nix run home-manager/master -- switch --flake "${FLAKE_REF}"

echo "\n==> Verifying experimental features are now persisted by Home Manager"
nix show-config | sed -n 's/^experimental-features = /experimental-features: /p' || true

echo "\nAll set. For daily updates, use:"
echo "  nix run home-manager/master -- switch --flake ${FLAKE_REF}"
