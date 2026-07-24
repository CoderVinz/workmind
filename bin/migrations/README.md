# Structure migrations

Ordered, idempotent, forward-only scripts run by `bin/migrate-structure.sh`.

Each file is `NNN-slug.sh` where `NNN` matches the `bin/structure/schema.json`
`version` the change ships in. A script runs only when the vault's local
content version (`.vault-meta/structure-version`, gitignored) is below `NNN`.

Rules for a migration script:
- **Idempotent** — safe to re-run; guard every action with an existence check.
- **`git mv`, never delete-then-write** — preserves history and content.
- **Merge on collision, never overwrite** — if the target exists, keep both.
- **Rewrite links you break** — search `wiki/` for the old path/name.
- Exit non-zero on any real failure; the runner hard-resets to the pre-migration
  snapshot, so failing loudly is safe.

Folder-level renames don't need a script — declare them in `schema.json`
`renames[]` and the runner applies them. Use scripts for file-level moves,
renames-with-content-edits, or frontmatter transforms.
