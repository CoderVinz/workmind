---
type: process
title: "{{name}}"
area: ""            # deploy | release | access | ticketing | hr | ...
tools: []          # wikilinks to the resources/tools pages this process needs, e.g. [[GitHub Actions]], [[Vault]]
project: ""        # optional: the project slug/wikilink this process serves, if any
last_verified: "{{date}}"
status: evergreen
created: "{{date}}"
updated: "{{date}}"
tags:
  - process
related: []
---

# {{name}}

## When

(Situations where this process applies.)

## Tools

(The systems/tools this process depends on — wikilink each to its `resources/tools/` page, and mirror them in the `tools:` frontmatter. If the process serves a specific project, wikilink its `_project.md` and set `project:`.)

## Steps

1. (Concrete. Links to tools/forms/channels.)

## Owner

(Which [[team]]/[[person]] owns the process; where to ask when stuck.)

## Notes

(Exceptions, history, what changed recently. Bump `last_verified` when followed successfully.)
