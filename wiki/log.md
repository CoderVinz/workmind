---
type: meta
title: "Operation Log"
updated: 2026-07-14
tags:
  - meta
  - log
status: evergreen
related:
  - "[[index]]"
  - "[[hot]]"
  - "[[overview]]"
---

# Operation Log

Navigation: [[index]] | [[hot]] | [[overview]]

Append-only. New entries go at the TOP. Never edit past entries.

Entry format: `## [YYYY-MM-DD] operation | Title`

Parse recent entries: `grep "^## \[" wiki/log.md | head -10`

---

## [2026-07-14] init | Vault created from tablinum template
- Machinery: claude-obsidian upstream + distill skill
- Content: blank scaffold — run `/wiki` to scaffold for the work domain
