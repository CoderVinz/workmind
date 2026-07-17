#!/usr/bin/env bash
# tablinum sync — pull machinery updates with zero manual conflict handling.
# Policy: local always wins for content (wiki/, .raw/, .vault-meta/),
# upstream always wins for machinery (everything else). Never pushes.
set -u
cd "$(git rev-parse --show-toplevel)"

# self-configure the clone (idempotent) — repo-side replacement for manual git config
git config pull.rebase true
git config rebase.autoStash true

# snapshot all local state so nothing can block the pull or get lost
git add -A
git commit -qm "local vault state (auto-sync)" 2>/dev/null || true

if git -c core.editor=true pull --rebase; then
  echo "sync: up to date"
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
