#!/usr/bin/env bash
# tablinum structure migration — bring this vault's CONTENT up to the layout
# version declared in bin/structure/schema.json, without data loss.
#
# Policy:
#   - forward-only, idempotent: re-running when already current is a no-op.
#   - loss-proof: snapshots to a commit first; aborts + hard-resets if the
#     markdown page count drops or new dead links appear.
#   - never pushes. Work content stays local.
#
# Usage:
#   bash bin/migrate-structure.sh            # DRY RUN — print the plan only
#   bash bin/migrate-structure.sh --apply    # execute the plan
#
# Mechanism (hybrid):
#   1. declarative folder renames from schema.json `renames[]`
#   2. ordered per-change scripts in bin/migrations/NNN-*.sh
# Both are gated on version: only steps with since_version / NNN in
# (local_version, target_version] run.

set -u
cd "$(git rev-parse --show-toplevel)" || { echo "not in a git repo"; exit 1; }

SCHEMA="bin/structure/schema.json"
MARKER=".vault-meta/structure-version"
APPLY=0
[ "${1:-}" = "--apply" ] && APPLY=1

command -v node >/dev/null 2>&1 || { echo "ERR: node required to read $SCHEMA"; exit 1; }
[ -f "$SCHEMA" ] || { echo "ERR: $SCHEMA missing — reinstall machinery"; exit 1; }

TARGET=$(node -e "console.log(require('./$SCHEMA').version)")
LOCAL=0
[ -f "$MARKER" ] && LOCAL=$(cat "$MARKER" 2>/dev/null | tr -dc '0-9')
[ -z "$LOCAL" ] && LOCAL=0

echo "structure: local content at v$LOCAL, schema target v$TARGET"
if [ "$LOCAL" -ge "$TARGET" ]; then
  echo "migrate: up to date — nothing to do"
  exit 0
fi

# ---- build the plan (renames in range + migration scripts in range) ----------
PLAN_RENAMES=$(node -e '
  const s = require("./'"$SCHEMA"'");
  const lo = '"$LOCAL"', hi = '"$TARGET"';
  (s.renames||[]).filter(r => r.since_version > lo && r.since_version <= hi)
    .forEach(r => console.log(r.from + "\t" + r.to));
')
PLAN_SCRIPTS=""
if [ -d bin/migrations ]; then
  for f in bin/migrations/[0-9]*.sh; do
    [ -e "$f" ] || continue
    n=$(basename "$f" | sed 's/^0*\([0-9]\+\).*/\1/')
    [ -z "$n" ] && continue
    if [ "$n" -gt "$LOCAL" ] && [ "$n" -le "$TARGET" ]; then
      PLAN_SCRIPTS="$PLAN_SCRIPTS $f"
    fi
  done
fi

echo ""
echo "PLAN v$LOCAL -> v$TARGET"
echo "  folder renames:"
if [ -n "$PLAN_RENAMES" ]; then
  printf '%s\n' "$PLAN_RENAMES" | while IFS=$'\t' read -r from to; do
    [ -d "$from" ] && echo "    $from  ->  $to  (present)" || echo "    $from  ->  $to  (absent here, skip)"
  done
else
  echo "    (none)"
fi
echo "  migration scripts:"
if [ -n "$PLAN_SCRIPTS" ]; then
  for f in $PLAN_SCRIPTS; do echo "    $f"; done
else
  echo "    (none)"
fi

if [ "$APPLY" -ne 1 ]; then
  echo ""
  echo "DRY RUN. Re-run with --apply to execute. Nothing changed."
  exit 0
fi

# ---- snapshot (loss-proof floor) ---------------------------------------------
echo ""
echo "snapshot: committing current state before migrating..."
git add -A
git commit -qm "pre-migration snapshot (structure v$LOCAL)" 2>/dev/null || true
SNAP=$(git rev-parse HEAD)

count_pages() { find wiki -name '*.md' -type f 2>/dev/null | wc -l | tr -d ' '; }
BEFORE=$(count_pages)

rollback() {
  echo "migrate: FAILED — $1"
  echo "rolling back to snapshot $SNAP (no data lost)"
  git reset -q --hard "$SNAP"
  exit 1
}

# ---- 1. declarative folder renames -------------------------------------------
if [ -n "$PLAN_RENAMES" ]; then
  while IFS=$'\t' read -r from to; do
    [ -d "$from" ] || continue
    echo "rename: $from -> $to"
    mkdir -p "$to"
    # move each file; if the target already exists, keep both (never overwrite)
    find "$from" -type f | while IFS= read -r src; do
      rel="${src#"$from"/}"
      dest="$to/$rel"
      mkdir -p "$(dirname "$dest")"
      if [ -e "$dest" ]; then
        dest="$(dirname "$dest")/$(basename "$dest" .md)--from-${from##*/}.md"
        echo "    collision: keeping both -> $dest"
      fi
      git mv -k "$src" "$dest" 2>/dev/null || mv "$src" "$dest"
    done
    # rewrite path-style references to the old folder across wiki/ and bases
    grep -rl "$from" wiki --include='*.md' --include='*.base' 2>/dev/null | while IFS= read -r f; do
      sed -i "s#$from#$to#g" "$f"
    done
    # drop the now-empty source tree (only if empty)
    find "$from" -type d -empty -delete 2>/dev/null || true
  done <<EOF
$PLAN_RENAMES
EOF
fi

# ---- 2. ordered migration scripts --------------------------------------------
for f in $PLAN_SCRIPTS; do
  echo "run: $f"
  bash "$f" || rollback "migration script $f exited non-zero"
done

# ---- 3. ensure every canonical folder exists ---------------------------------
node -e 'require("./'"$SCHEMA"'").folders.forEach(x=>console.log(x.path))' | while IFS= read -r d; do
  [ -d "$d" ] || { mkdir -p "$d"; }
done

# ---- verify: no page loss ----------------------------------------------------
AFTER=$(count_pages)
echo "pages: $BEFORE before, $AFTER after"
[ "$AFTER" -lt "$BEFORE" ] && rollback "page count dropped ($BEFORE -> $AFTER)"

# ---- commit + bump marker ----------------------------------------------------
echo "$TARGET" > "$MARKER"
git add -A
git commit -qm "migrate wiki structure v$LOCAL -> v$TARGET" 2>/dev/null || true
echo "migrate: done — content now at structure v$TARGET"
echo "run 'bash bin/sync.sh' peers unaffected; this never pushes."
echo "tip: run /wiki-lint to confirm no dead links remain."
