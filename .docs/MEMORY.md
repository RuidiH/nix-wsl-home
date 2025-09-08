# Session Checkpoints (newest first)

- 2025-09-08: WSL UX — Install wslu for wslview and accept ADR-0001. Next: Optionally format Nix and build. Links: ADR-0001
- 2025-09-08: Bootstrap — Added --set-default-shell to set Nix zsh via chsh with /etc/shells handling. Next: User reruns bootstrap with flag. Links: 
- 2025-09-08: Bootstrap — Removed --set-default-shell flag; keep manual chsh instruction for simplicity. Next: Use chsh manually if desired. Links: 
 
- 2025-09-08: HM assert fix — Set nix.package = pkgs.nix so nix.settings can generate nix.conf. Next: User reruns bootstrap. Links: 
- 2025-09-08: Bootstrap script — Source Nix profiles and PATH fallback to detect nix in non-login shells. Next: User to retry script without sudo. Links: 
- 2025-09-08: Bootstrap script — Fallback HM ref + repo-root detection. Next: Verify with a remote flake. Links: 
- 2025-09-07: Bootstrap UX — Bootstrap supports remote flake (no git), README docs added. Next: None. Links: 
- 2025-09-07: Bootstrap script — Added scripts/bootstrap.sh and README usage. Next: None. Links: 
- 2025-09-07: Docs — Added README bootstrap vs daily use and nix.conf intro. Next: None. Links: 
- 2025-09-07: Simplified Nix setup to a single .#wsl target; removed flake apps/hosts split; manual chsh if needed; VS Code sync handles zsh.
- 2025-09-07: Updated AGENTS.md with simple commands and clarified usage; README back to basic HM switch.
- 2025-09-07: Initialized repo memory system (AGENTS + MEMORY + ADR scaffold).

# Constraints / Norms
- Keep this section short and project-specific (e.g., toolchain versions, shells).
- File is **newest-first**; aim for ≤120 lines for reliable ingestion.
