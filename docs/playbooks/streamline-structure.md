# Task: streamline wiki folder structure

One-shot task for the coding agent. Read fully, then execute in order.

## Context

Ingestion of older wikis created duplicate/parallel folders in this vault
(e.g. concept pages under both `wiki/concepts/` and somewhere in
`wiki/resources/`). Goal: one canonical home per page type, no duplicate
folders, all wikilinks intact.

Canonical layout: the single source of truth is `bin/structure/schema.json`
(`folders[]`). Read it first — do not invent new top-level folders. It also
lists declarative `renames[]`; for versioned layout changes prefer
`bash bin/migrate-structure.sh` (deterministic). This task handles the
*ad-hoc* drift that migration can't know about — duplicate/parallel folders
left by ingesting older wikis.

## Steps

1. Map the actual tree: list every folder under `wiki/` with its markdown
   file count. Flag folders that are NOT in the canonical layout above
   (e.g. `wiki/resources/concepts/`) and folders duplicating another's purpose.

2. Propose a move plan: for each misplaced page — current path, target path,
   and whether a page on the same topic already exists at the target
   (then MERGE content instead of moving). Show the full plan and WAIT for
   the user's confirmation before touching anything.

3. Execute the confirmed plan:
   - move/merge the pages
   - update every wikilink that referenced the old paths (search the whole
     vault for each moved filename)
   - delete now-empty non-canonical folders; leave canonical folders alone
     even when empty (they are template scaffolding)

4. Update `wiki/index.md` and any sub-index pages if they linked moved pages.
   (tablinum has no build-index generator; the wiki skills maintain the index.)

5. Run the wiki-lint skill; fix dead links it finds.

6. Commit with a short message. NEVER push.

7. Report: pages moved, pages merged, folders removed, links rewritten.
