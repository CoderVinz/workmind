#!/usr/bin/env bash
# Migration 005 — remove the orphan wiki/projects/issues/ folder.
# It was an undefined scaffold with no routing rule. Idempotent + safe:
# only removes it when empty (ignores if the user put content there).
set -u

d="wiki/projects/issues"
if [ -d "$d" ]; then
  # drop a lone .gitkeep, then remove the dir only if now empty
  [ -f "$d/.gitkeep" ] && git rm -qf "$d/.gitkeep" 2>/dev/null || true
  if [ -z "$(ls -A "$d" 2>/dev/null)" ]; then
    rmdir "$d" 2>/dev/null || true
    echo "  removed empty $d"
  else
    echo "  KEEP $d — not empty, leaving content for /tidy to reroute"
  fi
fi
exit 0
