#!/usr/bin/env bash
# Migration 001 — named sub-index pages + meta/ orientation layout.
# Idempotent: brings a pre-refactor vault to the v1 canonical layout.
#   - move getting-started.md / overview.md from wiki/ root into wiki/meta/
#   - rename alias-stub _index.md -> "<Folder> Index.md" in content folders
#   - repoint old [[folder/_index]] path links to [[<Folder> Index]]
set -u

mv_git() { git mv -k "$1" "$2" 2>/dev/null || mv "$1" "$2"; }

# --- getting-started / overview -> meta/ --------------------------------------
mkdir -p wiki/meta
for f in getting-started overview; do
  if [ -f "wiki/$f.md" ] && [ ! -e "wiki/meta/$f.md" ]; then
    echo "  move wiki/$f.md -> wiki/meta/$f.md"
    mv_git "wiki/$f.md" "wiki/meta/$f.md"
  fi
done

# --- _index.md stubs -> named "<Folder> Index.md" -----------------------------
# folder:Name pairs
for pair in "concepts:Concepts" "entities:Entities" "sources:Sources" \
            "references:References" "processes:Processes" "projects:Projects" \
            "meta:Meta"; do
  dir="wiki/${pair%%:*}"
  name="${pair##*:}"
  [ -d "$dir" ] || continue
  if [ -f "$dir/_index.md" ] && [ ! -e "$dir/$name Index.md" ]; then
    echo "  rename $dir/_index.md -> $dir/$name Index.md"
    mv_git "$dir/_index.md" "$dir/$name Index.md"
  fi
done

# --- rewrite old path-style index links ---------------------------------------
for pair in "concepts:Concepts" "entities:Entities" "sources:Sources"; do
  dir="${pair%%:*}"; name="${pair##*:}"
  grep -rl "\[\[$dir/_index" wiki --include='*.md' 2>/dev/null | while IFS= read -r f; do
    echo "  relink [[$dir/_index]] -> [[$name Index]] in $f"
    sed -i "s#\[\[$dir/_index\(|[^]]*\)\?\]\]#[[$name Index]]#g" "$f"
  done
done

exit 0
