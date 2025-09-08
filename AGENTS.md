# How to work in this repo (Codex & humans)

## Read before acting
1) ./.docs/MEMORY.md
2) ./docs/adr/          # treat ADRs with Status: Accepted as rules
3) ./README.md

## Project commands (this repo)
- Dev env (apply HM): `nix run home-manager/master -- switch --flake .#wsl`
- Dry-run switch: `nix run home-manager/master -- -n switch --flake .#wsl`
- Build activation only: `nix build .#homeConfigurations.wsl.activationPackage`
- Format Nix: `nix run nixpkgs#alejandra -- .`
- Lint bash: `nix run nixpkgs#shellcheck -- -S style scripts/bootstrap.sh`
- ADR tools (optional): `adr init docs/adr`, `adr new "<title>"`, `adr list`, `adr show <id>`

## Memory (hot context)
- After meaningful work, append **one** 1–3 line checkpoint at the **top** of `.docs/MEMORY.md` (newest-first).
  - **Schema:** `- YYYY-MM-DD: <scope> — <1-line impact>. Next: <one step>. Links: ADR-…`
- Keep `.docs/MEMORY.md` **≤120 lines**; if exceeded, run:
  `scripts/compact_memory.py --max-lines 120`
- Preserve headings exactly:
  - `# Session Checkpoints (newest first)` and `# Constraints / Norms`
  - Don’t read archives by default.

## ADR policy (durable “why”)
- When a change sets/changes a long-lived policy (e.g., `flake.nix`, `home/*.nix`, `terraform/*.tf`, cross-cutting infra):
  1) List ADRs, suggest top candidates to supersede by title; **ask for confirmation**.
  2) Create ADR (`adr new …` or hand-rolled) or `--supersede <id>` when applicable.
  3) Draft **Context / Decision / Rationale / Consequences** (≤1 page). Link ADR in the MEMORY checkpoint.

## Learning mode
- **Trigger:** messages starting with `learn:` / `teach:` / `explain …` / `quiz me`.
- **Teach style:** one Socratic question → ≤5 bullets + tiny example (≤10 lines) → one micro-exercise (no full solution unless asked).
- **Checkpoint:** append at top of `.docs/LEARNING.md`:
  `- YYYY-MM-DD: <topic> — <1-line takeaway>. Q: <…> → A: <…>. Exercise: <done/next>. Links: ADR-…`
- **Caps:** keep `LEARNING.md` **≤200 lines**; if exceeded:
  `scripts/compact_memory.py --file .docs/LEARNING.md --archive .docs/LEARNING-archive.md --max-lines 200`
- **Glossary:** keep `.docs/GLOSSARY.md` to one-line defs; edit in place (no compaction).

## Safety & ops
- Ask before enabling network/system-level changes; run project Build/Test/Lint before proposing larger diffs.
- When unsure: ask one clarifying question, then propose the smallest safe step.
