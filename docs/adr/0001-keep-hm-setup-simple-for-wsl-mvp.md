# 1. Keep HM Setup Simple for WSL (MVP)

- Status: Proposed
- Date: 2025-09-07

## Context
We are new to Nix and Home Manager. Earlier changes introduced extra portability niceties (flake apps, host modules, auto‑setting the login shell) that increased complexity and unfamiliar commands. The goal is a minimal, easy‑to‑operate setup while learning.

## Decision
- Maintain a single Home Manager target: `.#wsl` using a flat `home.nix`.
- Remove flake apps and host‑specific module split for now.
- Keep WSL ergonomics inline in `home.nix` (e.g., `BROWSER=wslview`).
- Use the straightforward command: `nix run home-manager/master -- switch --flake .#wsl`.
- Set zsh as default manually when needed: `chsh -s $(which zsh)` (VS Code Settings Sync can default terminal to zsh).

## Rationale
- Reduce cognitive load while learning Nix.
- Make day‑to‑day usage obvious and discoverable.
- Avoid premature abstraction (apps/hosts split) until there’s clear need.

## Consequences
- Slightly longer commands (no flake app shortcuts).
- Host‑specific variants and auto‑shell setting are deferred, to be reintroduced later when comfortable.
- Simpler mental model today; clear path to evolve (e.g., add host modules and apps later).

## Notes
- AGENTS.md contains a short “Project commands (simple)” section.
- README documents only the basic HM switch flow.

