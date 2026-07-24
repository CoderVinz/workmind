---
type: service
title: "{{name}}"
owner_team: ""      # team slug — wikilink the team page in Related
status: live        # live | beta | deprecated | retired
repo: ""
tech: []            # wikilinks to technology pages
depends_on: []      # other service slugs
created: "{{date}}"
updated: "{{date}}"
tags:
  - service
  - operations
related: []
---

# {{name}}

## What it does

(One paragraph. Business purpose, who consumes it.)

## Environments

| Env | URL / location | Notes |
|---|---|---|
| prod | | |
| staging | | |

## Dependencies

(Upstream services it calls, downstream consumers, infra it sits on. Wikilinks.)

## Operations

- Runbooks: (wikilinks into `operations/runbooks/`)
- Dashboards/alerts: (URLs)
- Who to page: [[team]] / [[person]]

## Incident history

(wikilinks to incident notes — newest first.)
