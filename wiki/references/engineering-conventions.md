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
| Learned a tool/library/pattern | concept/source | `resources/tools/` or `resources/patterns/` |
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

## Starting a new project

1. Create `wiki/projects/<slug>/_project.md` from `_templates/project.md` (+ empty `bugs/ decisions/ improvements/ notes/`)
2. Add the project to [[hot]] under Active context
3. Log it in [[log]]

## Role checklists — what belongs in here

**Developer:** every non-trivial bug (symptom + root cause, not just the fix), every architecture/library decision, tech-debt improvements as you spot them, snippets you'd otherwise re-google, per-session `/save`.

**Operations:** every incident within 24h while memory is fresh, runbook for anything done twice, infra/services as entity notes under `resources/tools/`, verify+bump runbooks when used.

**Designer:** design explorations before they're lost to Figma history, feedback logs on the design note itself, design-system components under `areas/design-system/`, inspiration with source links under `resources/design/`.
