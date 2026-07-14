---
type: incident
title: "{{title}}"
project: "{{slug}}"
status: open        # open | resolved | postmortem-done
severity: high      # low | medium | high | critical
started: "{{datetime}}"
resolved: ""
created: "{{date}}"
updated: "{{date}}"
tags:
  - incident
  - operations
related: []
---

# {{title}}

## Impact

(Who/what was affected, for how long, blast radius.)

## Timeline

- `HH:MM` — detection (how was it noticed?)
- `HH:MM` — ...
- `HH:MM` — resolved

## Root cause

(Mechanism. Five-whys depth, no blame.)

## What went well / badly

- Well: (detection, tooling, communication)
- Badly: (gaps)

## Action items

- [ ] (Each one links to an [[improvement]] or [[bug]] note with an owner.)
