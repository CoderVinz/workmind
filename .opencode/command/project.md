---
description: Create a project page and cross-link everything in the vault related to it
---

Create a new project in the wiki and wire it into existing knowledge.

Input: project name plus a one-line description. If missing, ask for both.

1. Create `wiki/projects/<kebab-case-name>.md` following the obsidian-markdown
   skill conventions: frontmatter (`type: project`, `status: active`, `created:`
   today, `tags:`), sections for Goal, Status, Related, Log.

2. Find related vault content: extract the key terms from the name and
   description, then search the whole vault for them (use the wiki-retrieve
   skill if `.vault-meta/bm25/` exists, otherwise plain text search across
   `wiki/`). Also check `wiki/entities/` and `wiki/concepts/` for pages whose
   titles or aliases match.

3. In the project's Related section, add a wikilink per match with a
   half-line reason ("[[page]] — covers the auth flow this project changes").
   Only genuinely related pages — no keyword-coincidence padding. Obsidian
   backlinks make the reverse direction visible automatically; do not edit
   the matched pages.

4. Add the project to `wiki/index.md` under projects, log the creation per
   the wiki skill's log conventions, rebuild the index
   (`node build-index.mjs` or the repo's equivalent).

5. Commit. NEVER push.

6. Report: page created, related pages linked with reasons, anything
   searched but deliberately not linked.

Arguments: $ARGUMENTS
