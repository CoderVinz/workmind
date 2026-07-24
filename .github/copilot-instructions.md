# tablinum — Copilot instructions

This repo is **both an Obsidian vault and a multi-agent plugin** (Claude Code, opencode, Gemini CLI) implementing the LLM Wiki pattern — a persistent, compounding knowledge base. Most files are machinery (skills, commands, scripts, templates); `wiki/` holds the knowledge content.

For the full picture read `AGENTS.md` and `CLAUDE.md`. This file is the short version for code suggestions.

## Layout

- `skills/<name>/SKILL.md` — agent skills (auto-discovered; do not rename the folders)
- `commands/*.md` + `.opencode/command/*.md` — slash commands (keep the two copies identical)
- `bin/` — setup + sync + migration scripts · `scripts/` — runtime helpers (Python/bash)
- `_templates/` — Obsidian + note templates · `docs/` — guides + playbooks
- `wiki/` — the knowledge vault (content); everything else is machinery

## Conventions to follow when editing

- **Line endings:** shell/python/json/markdown check out **LF** (enforced by `.gitattributes`). Never introduce CRLF — it breaks `#!/usr/bin/env bash` on Linux/WSL2.
- **Never** add a `Co-Authored-By: Claude` trailer to commits in this repo.
- **Folder-structure changes go through the schema**, never ad-hoc: edit `bin/structure/schema.json` (bump `version`, add a `renames[]` entry and/or a `bin/migrations/NNN-*.sh` script). The vault is migrated by `bin/migrate-structure.sh` (dry-run default, `git mv`, loss-verified). Don't move `wiki/` folders by hand.
- **Wiki filing** follows `wiki/meta/engineering-conventions.md` (the routing table). The machine router is `scripts/wiki-mode.py` — keep it consistent with that doc.
- **Graph config** has one source of truth: `_templates/obsidian/graph.json` (copied to `.obsidian/graph.json` by `bin/setup-vault.sh`). Don't add a second copy.
- **Sync policy:** `bin/sync.sh` — local wins for `wiki/`/`.raw/`/`.vault-meta/` (content), upstream wins for machinery. It never pushes.
- Migration scripts must be **idempotent, forward-only, `git mv` (never delete-then-write), merge-on-collision**.

## What NOT to touch

- Loader-discovered dirs at root (`skills/`, `commands/`, `agents/`, `hooks/`, `.claude-plugin/`, `_templates/`) — moving them breaks plugin discovery.
- Machine-local, gitignored state under `.vault-meta/` (`structure-version`, `address-counter.txt`, etc.).
