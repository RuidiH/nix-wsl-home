# How to work in this repo (Codex & humans)

## Read before acting
1) ./.docs/MEMORY.md
2) ./docs/adr/   # treat ADRs with Status: Accepted as rules
3) ./README.md

## Project commands (adjust per repo)
- Switch:    nix run home-manager/master -- switch --flake .#wsl
- Dry-run:   nix run home-manager/master -- -n switch --flake .#wsl
- Build-only:nix build .#homeConfigurations.wsl.activationPackage
- Format Nix:nix run nixpkgs#alejandra -- .
- ADR init:  nix run nixpkgs#adr-tools -- init docs/adr
- ADR new:   nix run nixpkgs#adr-tools -- new "<title>"
- ADR list:  nix run nixpkgs#adr-tools -- list
- ADR show:  nix run nixpkgs#adr-tools -- show <id>

## Memory & editing
- After meaningful work, append **one** 1–3 line checkpoint at the **top** of `.docs/MEMORY.md` (newest-first).
  - **Schema:** `- YYYY-MM-DD: <scope> — <1-line impact>. Next: <one next step>. Links: PR#…, ADR-…`
  - No logs, stack traces, configs, secrets, or multi-line code.
- Keep `.docs/MEMORY.md` **≤120 lines**. If exceeded, run:
  `scripts/compact_memory.py --max-lines 120`
- Preserve headings exactly:
  - `# Session Checkpoints (newest first)`
  - `# Constraints / Norms`

## ADR policy
- When a change sets or alters a long-lived policy/contract/tooling choice (e.g., `flake.nix`, `home/*.nix`, `terraform/*.tf`, cross-cutting infra):
  1) List ADRs and suggest top candidates to supersede by title similarity; **ask for confirmation**.
  2) Create: `adr new "<title>"` (or `adr new --supersede <id> "<title>"`).
  3) Draft **Context / Decision / Rationale / Consequences / Status** (≤1 page, Status: Proposed).
  4) Link the ADR in the PR “Rationale” and in the MEMORY checkpoint.

## Safety & ops
- Ask before enabling network access or making system-level changes.
- Build/test/lint us