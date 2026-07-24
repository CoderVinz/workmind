---
description: Migrate the wiki's folder structure to the current schema version — reviewed, loss-proof, never pushes
---

Bring this vault's content up to the canonical layout in `bin/structure/schema.json`.

1. Run `bash bin/migrate-structure.sh` (DRY RUN) and show the full plan.
2. If the plan is empty ("up to date"), stop and report that.
3. Otherwise summarize what will move/rename, then ask the user to confirm.
4. On confirmation, run `bash bin/migrate-structure.sh --apply` and show output.
   The script snapshots first and hard-resets itself if any page is lost.
5. Run the wiki-lint skill; fix any dead links the migration introduced.
6. Report: what moved, links rewritten, new structure version. NEVER push.

Arguments: $ARGUMENTS
