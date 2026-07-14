---
type: meta
title: "Engineering Conventions"
updated: 2026-07-14
status: evergreen
tags:
  - meta
  - conventions
related:
  - "[[index]]"
---

# Engineering Conventions

How this vault organizes developer / operations / design work across multiple projects. Agents: consult this before filing any engineering note. Vault mode is **PARA** (`.vault-meta/mode.json`) — organize by actionability.

Navigation: [[index]] | [[hot]] | engineering.base (dashboards)

---

## Layout

```
wiki/
  projects/<slug>/          active work with an outcome/deadline
    _project.md             project MOC (template: project) — always exists, links everything
    bugs/                   bug notes (template: bug)
    decisions/              ADRs (template: decision)
    improvements/           future work / ideas / tech debt (template: improvement)
    notes/                  sessions (/save lands here), meetings, scratch
    design/                 design specs for this project (template: design)
  areas/                    ongoing responsibilities, no end date
    operations/runbooks/    runbooks (template: runbook)
    operations/incidents/   incidents & postmortems (template: incident)
    design-system/          cross-project design language, components
    team/                   people, processes, onboarding notes
  resources/                reference material, no action attached
    snippets/               reusable code (template: snippet)
    tools/                  notes on tools/services/libraries
    patterns/               architecture & design patterns learned
    design/                 inspiration, external design references
  archives/<year>/<slug>/   completed projects, moved wholesale from projects/
```

## Routing table

| This happened | File it as | Where |
|---|---|---|
| Found/fixed a bug | `bug` | `projects/<slug>/bugs/YYYY-MM-DD-<slug>.md` |
| Chose between approaches | `decision` | `projects/<slug>/decisions/YYYY-MM-DD-<slug>.md` |
| "We should later..." / tech debt | `improvement` | `projects/<slug>/improvements/<slug>.md` |
| Work session ended (`/save`) | session note | `projects/<slug>/notes/YYYY-MM-DD-<topic>.md` |
| Meeting happened | `meeting` | `projects/<slug>/notes/` (project) or `areas/team/` (general) |
| Prod broke | `incident` | `areas/operations/incidents/YYYY-MM-DD-<slug>.md` |
| Documented a procedure | `runbook` | `areas/operations/runbooks/<service>-<action>.md` |
| UI/UX spec or exploration | `design` | `projects/<slug>/design/` or `areas/design-system/` |
| Reusable code worth keeping | `snippet` | `resources/snippets/<slug>.md` |
| Tech enters the stack | `technology` | `resources/tools/<name>.md` (one page per technology) |
| Docs ingested for a tech | source note | `resources/tools/docs/<name>-<topic>.md`, linked from the tech page |
| Learned a pattern | concept/source | `resources/patterns/` |
| Project finished | — | move `projects/<slug>/` → `archives/<year>/<slug>/`, set `_project.md` status: archived |

Cross-project note → `project: cross`. Unsure which project → ask, don't guess.

## Frontmatter contract

Every engineering note carries `type`, `title`, `project`, `status`, `created`, `updated`, `tags`. Dashboards (engineering.base) key on these — a note with missing `type`/`project`/`status` is invisible to them. `wiki-lint` should flag violations.

Status lifecycles:

- bug: `open → investigating → fixed | wontfix` (root cause filled before `fixed`)
- improvement: `idea → planned → in-progress → done | rejected`
- decision: `proposed → accepted → superseded` (set `supersedes:` on the replacement)
- incident: `open → resolved → postmortem-done` (action items link to improvement/bug notes)
- design: `exploring → spec → shipped`
- runbook: `evergreen`, bump `last_verified` whenever executed successfully

## Technology pages

One page per technology in the stack: `resources/tools/<name>.md` from `_templates/technology.md`. This is the inventory — languages, frameworks, libraries, databases, infra, services, design tools.

Rules:

- `projects:` frontmatter lists every project slug using it; the "What we use it for" table explains purpose per project. Keep both in sync with each `_project.md` `stack:` field (stack entries are wikilinks to tech pages).
- `status:` is radar-style: `trial → adopted → deprecated → retired`. Deprecating a tech → link the [[decision]] that killed it.
- **Ingesting documentation for a tech** ("ingest <url> for <tech>"): run wiki-ingest/defuddle as usual, file the source note under `resources/tools/docs/`, then update the tech page — append the source to `sources:` and "## Ingested documentation", and fold anything that changes how we use it into "## How we use it" / "## Gotchas". The tech page stays the single readable summary; source notes hold the detail.
- Bugs caused by a tech's behavior link both ways (bug note ↔ tech page Gotchas).

Dashboard: engineering.base "Tech Radar" view (grouped by category).

## Starting a new project

1. Create `wiki/projects/<slug>/_project.md` from `_templates/project.md` (+ empty `bugs/ decisions/ improvements/ notes/`)
2. Add the project to [[hot]] under Active context
3. Log it in [[log]]

## Role checklists — what belongs in here

**Developer:** every non-trivial bug (symptom + root cause, not just the fix), every architecture/library decision, tech-debt improvements as you spot them, snippets you'd otherwise re-google, per-session `/save`.

**Operations:** every incident within 24h while memory is fresh, runbook for anything done twice, infra/services as entity notes under `resources/tools/`, verify+bump runbooks when used.

**Designer:** design explorations before they're lost to Figma history, feedback logs on the design note itself, design-system components under `areas/design-system/`, inspiration with source links under `resources/design/`.
