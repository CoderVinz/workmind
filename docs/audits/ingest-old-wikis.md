# Task: ingest old test wikis into this vault

One-shot task for the coding agent. Read fully, then execute the steps in order.
Run only AFTER `audit-vault-refs.md` has been completed, so all skills resolve
to this vault.

## Context

The active wiki vault is **this repo** (tablinum, the current working directory).
Older test wikis exist in other folders on this machine. Goal: migrate their
useful content into this vault using the wiki-ingest skill, leaving the old
folders untouched (the user deletes them manually afterwards).

## Steps

1. Ask the user for the absolute paths of the old wiki folders to ingest.
   Confirm each path exists before proceeding.

2. For each old vault, list its notes first (markdown files, skip templates,
   `.obsidian/`, generated indexes, logs) and show the user the list of notes
   you plan to ingest. Wait for confirmation.

3. Ingest per the wiki-ingest skill in this repo (`skills/`), folder by folder:
   - read each note, extract entities and concepts
   - create or update pages in this vault's `wiki/` structure
   - if a page on the same topic already exists here, MERGE into it — never
     create a duplicate page
   - preserve original creation dates in frontmatter where the source has them
   - cross-reference with wikilinks and log the operation as the skill specifies

4. Do NOT modify or delete anything inside the old wiki folders. Read-only.

5. After all ingests: rebuild the index (`node build-index.mjs` from the vault
   root, or the equivalent this repo's Makefile/scripts provide), update
   `wiki/hot.md` if the skill calls for it.

6. Run the wiki-lint skill: dead wikilinks, orphan pages, frontmatter gaps.
   Fix what it finds.

7. Report: notes read per source vault, pages created, pages merged, anything
   skipped and why. Then commit the vault changes with a short message
   (no Co-Authored-By trailer).

8. Remind the user which old folders are now safe to archive and delete —
   but do not delete them yourself.
