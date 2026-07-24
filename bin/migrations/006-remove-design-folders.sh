#!/usr/bin/env bash
# Migration 006 — remove design-system/ and resources/design/ (no design work).
# Idempotent + loss-safe: each folder is removed only when empty; if you put
# content there, it is kept and flagged for /tidy to reroute.
set -u

remove_if_empty() {
  d="$1"
  [ -d "$d" ] || return 0
  [ -f "$d/.gitkeep" ] && git rm -qf "$d/.gitkeep" 2>/dev/null || true
  if [ -z "$(ls -A "$d" 2>/dev/null)" ]; then
    rmdir "$d" 2>/dev/null || true
    echo "  removed empty $d"
  else
    echo "  KEEP $d — not empty, leaving content for /tidy to reroute"
  fi
}

remove_if_empty wiki/design-system
remove_if_empty wiki/resources/design
exit 0
