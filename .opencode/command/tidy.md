---
description: Lint the wiki and normalize folder structure — health check plus cleanup in one pass
---

Two passes over the vault, in order:

1. **Lint**: read skills/wiki-lint/SKILL.md and execute it — orphans, dead
   wikilinks, frontmatter gaps, empty sections.

2. **Structure**: read docs/playbooks/streamline-structure.md and execute it —
   map folders against the canonical layout, propose moves/merges, wait for
   confirmation, then apply, rewrite wikilinks, rebuild the index.

Finish with one combined report: lint findings fixed, pages moved/merged,
links rewritten. Commit at the end. NEVER push.

Arguments: $ARGUMENTS
