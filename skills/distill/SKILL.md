---
name: distill
description: >
  Periodic consolidation pass over the Obsidian wiki vault. Reads accumulated session
  and meta notes, merges overlapping knowledge into evergreen concept pages, marks
  superseded notes, maintains MOC navigation pages, enforces the hot cache eviction
  policy, regenerates the index, and commits. Run monthly or after a burst of sessions
  on one topic. Triggers on: "/distill", "distill", "distill the wiki",
  "consolidate the wiki", "monthly distill", "merge session notes",
  "compress the wiki", "evergreen pass".
allowed-tools: Read Write Edit Glob Grep Bash
---

# distill: Consolidate Session Notes Into Evergreen Knowledge

Session notes pile up; knowledge fragments. This skill periodically merges what the
sessions learned into a small set of evergreen pages, so future sessions read one
current-state page instead of replaying months of history.

Sessions append. Distill compacts. The wiki stays fast to load and true to now.

---

## When to Run

- Monthly (per the global CLAUDE.md pointer), or
- After 3+ sessions land on the same topic, or
- When `wiki/hot.md` exceeds its cap (~6 sections / ~80 lines), or
- When an evergreen page is contradicted by newer session notes.

---

## Distill Workflow

1. **Survey**: read `wiki/hot.md`, then `wiki/log.md` entries since the last
   `distill |` entry, then `wiki/index.md`. List the session/meta notes created in
   that window.
2. **Cluster**: group those notes by topic. A cluster is worth distilling when 2+
   notes overlap, correct each other, or update the same evergreen page.
3. **Consolidate** each chosen cluster:
   - Target an existing page in `wiki/concepts/` if one covers the topic; otherwise
     create one. One page per topic — current state only, declarative present tense.
   - Merge the newest truth. Where notes conflict, the later note wins; say so:
     `(supersedes [[older-note]], see [[newer-note]])`.
   - Cite every source note with `(Source: [[note]])`. Session notes stay in place —
     they are the archive, the evergreen page is the interface.
4. **Mark supersession**: when an evergreen page fully replaces a note's useful
   content, set in that note's frontmatter `status: superseded` and
   `superseded_by: "[[Evergreen Page]]"` (formalism from 2026-07-07; wiki-lint
   check #9 verifies integrity). Never delete the note.
5. **Maintain MOCs**: link each touched evergreen page from the matching
   `wiki/MOC *.md` page; create a new MOC only when a topic has 3+ evergreen pages
   and no home. MOCs are the stable navigation layer between hot.md (cache) and
   index.md (catalog).
6. **Enforce the hot cache policy** in `wiki/hot.md`: keep it under ~6 sections /
   ~80 lines. Evict the oldest resolved section — move any facts not already in its
   detail note into that note, then leave a single line under "Evicted". Refresh
   "Last Updated".
7. **Regenerate the index**: from the vault root run `node build-index.mjs`.
8. **Log** at the TOP of `wiki/log.md`:
   ```
   ## [YYYY-MM-DD] distill | Topic(s)
   - Type: concept
   - Location: wiki/concepts/Page.md (one line per page touched)
   - From: distill run over [note count] notes since [last distill date]
   - Superseded: [[note]] → [[Evergreen Page]] (if any)
   ```
9. **Commit** the vault (`git add -A && git commit && git push`), message like
   `wiki: distill <topic>`.
10. **Confirm**: report pages created/updated, notes superseded, hot cache evictions.

---

## Evergreen Page Frontmatter

```yaml
---
type: concept
title: "Page Title"
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags:
  - <topic-tag>
status: evergreen
related:
  - "[[MOC Page]]"
sources:
  - "[[session-note-1]]"
  - "[[session-note-2]]"
---
```

On update, bump `updated` and append new sources — never drop existing ones.

---

## What to Distill vs. Leave

Distill:
- Clusters of session notes converging on one system, feature, or decision trail
- Gotcha collections scattered across sessions (merge into one reference page)
- Anything hot.md keeps re-explaining — that is a missing evergreen page

Leave alone:
- Single notes with no overlap (nothing to merge yet)
- Notes younger than ~1 week (topic may still be moving)
- `wiki/.raw/` and `wiki/inbox/` (wiki-ingest's territory)
- Superseded notes (already resolved; keep for the record)

Distill rewrites the map, not the territory: session notes are never edited beyond
their frontmatter supersession markers.
