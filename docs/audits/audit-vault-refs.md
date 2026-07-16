# Task: audit stale vault references

One-shot task for the coding agent. Read fully, then execute the steps in order.

## Context

The active wiki vault is **this repo** (tablinum, the current working directory).
One or more test wikis were created earlier in other folders; global agent config
or skill files may still point to them. Goal: every wiki skill and instruction
file must resolve to this repo and nothing else.

## Steps

1. Search these locations recursively for any absolute path or vault name that
   is NOT this repo (look for `workmind`, `test`, `wiki` in paths, and any
   hardcoded `C:\` vault paths):
   - `~/.config/opencode/` (AGENTS.md, opencode.json, skill/)
   - `~/.claude/` (CLAUDE.md, skills/)
   - this repo's own config files (`.opencode/`, `.claude/`, AGENTS.md, opencode.json)

2. Show every match found — file path plus matching line — BEFORE changing
   anything, and wait for confirmation.

3. Update each stale reference to point to this repo's absolute path instead.
   If a skill file resolves the vault relative to the working directory, leave
   it as is — that is correct behavior.

4. Do NOT delete any folders or vaults. Only edit config/instruction files.
   The user removes old test vaults manually after review.

5. Verify: state which vault path each config now resolves to, then read
   `wiki/index.md` and `wiki/hot.md` from this repo to confirm skills resolve
   here.

6. Report every change as a list: file, old value, new value.
