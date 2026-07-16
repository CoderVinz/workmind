# Task: rescue stuck rebase, rebase local content onto origin/main

One-shot recovery for the coding agent. The vault's git is stuck mid-rebase;
local commits keep re-adding machine-local state files that origin/main
untracked, causing endless conflicts. Strategy: abort, snapshot everything to a
backup branch, reset to origin/main, restore content and local state from the
snapshot. NEVER push anything.

## Steps — execute in order, show output of each

1. Move blocking untracked state files aside (create `../state-aside/` first):
   - `.obsidian/workspace.json`, `.obsidian/graph.json`, `.raw/.manifest.json`,
     `.vault-meta/address-counter.txt`, `.vault-meta/tiling-thresholds.json`
   - skip any that don't exist

2. `git rebase --abort` — if it names other blocking untracked files, move
   those aside too and retry until it succeeds.

3. `git add -A` then `git commit -m "snapshot"` ("nothing to commit" is fine).

4. `git branch backup`

5. `git reset --hard origin/main`

6. `git checkout backup -- wiki .obsidian .raw .vault-meta`

7. `git restore --staged .` then `git add -A` then
   `git commit -m "local vault content"` — the new .gitignore keeps runtime
   state files out; only wiki content and tracked config get committed.

8. Move the files from `../state-aside/` back to their original locations,
   overwriting, then delete `../state-aside/`.

9. Restore graph color groups as UTF-8:
   `git show b7431fd:.obsidian/graph.json | Set-Content .obsidian/graph.json -Encoding utf8`

10. Verify and report: `git status` clean; `git log --oneline -3` shows
    "local vault content" on top of origin/main; spot-check that `wiki/`
    still contains the ingested notes.

11. Tell the user: keep the `backup` branch until the vault looks right in
    Obsidian for a few days, then delete it with `git branch -D backup`.

## Hard rules

- NEVER run `git push`.
- NEVER delete anything except `../state-aside/` at the end.
- If any step fails unexpectedly, STOP and show the user the exact error.
