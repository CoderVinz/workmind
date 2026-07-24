#!/usr/bin/env bash
# tablinum sync — pull machinery updates with zero manual conflict handling.
# Policy: local always wins for content (wiki/, .raw/, .vault-meta/),
# upstream always wins for machinery (everything else). Never pushes.
set -u
cd "$(git rev-parse --show-toplevel)"

# After pulling machinery, tell the user (never auto-apply) if the canonical
# wiki layout advanced past this vault's content. Migration mutates content,
# so it is always an explicit, reviewed step — see bin/migrate-structure.sh.
check_structure() {
  local schema="bin/structure/schema.json" marker=".vault-meta/structure-version"
  command -v node >/dev/null 2>&1 || return 0
  [ -f "$schema" ] || return 0
  local target local_v
  target=$(node -e "console.log(require('./$schema').version)" 2>/dev/null) || return 0
  local_v=0; [ -f "$marker" ] && local_v=$(tr -dc '0-9' < "$marker"); [ -z "$local_v" ] && local_v=0
  if [ "${target:-0}" -gt "$local_v" ]; then
    echo ""
    echo "structure: layout advanced v$local_v -> v$target."
    echo "  review + migrate your content with:  bash bin/migrate-structure.sh"
    echo "  (dry run by default; add --apply to execute. Never auto-runs.)"
  fi
}

# self-configure the clone (idempotent) — repo-side replacement for manual git config
git config pull.rebase true
git config rebase.autoStash true

# snapshot all local state so nothing can block the pull or get lost
git add -A
git commit -qm "local vault state (auto-sync)" 2>/dev/null || true

if git -c core.editor=true pull --rebase; then
  echo "sync: up to date"
  check_structure
  exit 0
fi

in_rebase() {
  [ -d "$(git rev-parse --git-path rebase-merge)" ] || [ -d "$(git rev-parse --git-path rebase-apply)" ]
}

# ponytail: fixed 20-iteration cap instead of tracking rebase step count
for _ in $(seq 1 20); do
  in_rebase || break
  git diff --name-only --diff-filter=U -z | while IFS= read -r -d '' f; do
    case "$f" in
      wiki/*|.raw/*|.vault-meta/*)
        # content: keep the local version (theirs = local commit during rebase)
        git checkout --theirs -- "$f" 2>/dev/null && git add -- "$f" \
          || git rm -q --cached -- "$f" 2>/dev/null || true ;;
      .obsidian/*)
        # machine-local config: untrack, keep on disk
        git rm -q --cached -- "$f" 2>/dev/null || true ;;
      *)
        # machinery: take upstream (ours = upstream during rebase)
        git checkout --ours -- "$f" 2>/dev/null && git add -- "$f" \
          || git rm -q -- "$f" 2>/dev/null || true ;;
    esac
  done
  git -c core.editor=true rebase --continue 2>/dev/null \
    || git -c core.editor=true rebase --skip 2>/dev/null || true
done

if in_rebase; then
  echo "sync: could not auto-resolve, aborting — vault left as it was before sync"
  git rebase --abort
  exit 1
fi
echo "sync: done"
check_structure
