---
type: meta
title: "Engineering Conventions"
updated: 2026-07-14
status: evergreen
tags:
  - meta
  - conventions
related:
  - "[[References Index]]"
---

# Engineering Conventions

How this vault organizes developer / operations / design work across multiple projects. Agents: consult this before filing any engineering note. Vault mode is **PARA** (`.vault-meta/mode.json`) — organize by actionability.

Navigation: [[References Index]] | [[hot]] | engineering.base (dashboards)

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
    operations/services/    service catalog — one page per running system (template: service)
    design-system/          cross-project design language, components
  entities/                 the org map — one page per person AND per company/team
    (people templates: person; company/team templates: team)
  processes/                how-things-work-here (template: process), top-level —
                            each links the tools it needs and the project it serves
  resources/                reference material, no action attached
    snippets/               reusable code (template: snippet)
    tools/                  technology pages + ingested docs (template: technology)
    patterns/               architecture & design patterns learned
    design/                 inspiration, external design references
    glossary/               company jargon, acronyms, domain terms (template: glossary)
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
| Met/learned about a person (colleague, client, partner) | `person` | `entities/<Name>.md` |
| Learned about a company or team | `team` | `entities/<name>.md` |
| Encountered a code repository | source | `sources/<repo>.md` |
| New service/system encountered | `service` | `areas/operations/services/<name>.md` |
| New jargon/acronym heard | `glossary` | `resources/glossary/<term>.md` |
| Figured out a company process | `process` | `processes/<name>.md` (link its `tools:` + `project:`) |
| Project finished | — | move `projects/<slug>/` → `archives/<year>/<slug>/`, set `_project.md` status: archived |

Cross-project note → see next section. Unsure which project → ask, don't guess.

## Cross-project and project-less knowledge

The rule: **knowledge lives once, links many times. Never duplicate a note into two projects.**

- **Belongs to no project** → it doesn't go in `projects/` at all. Reusable knowledge (how something works, patterns, snippets, tech gotchas, glossary) → `resources/`. Ongoing duties (ops, team, design system) → `areas/`. Projects are only for work with an outcome and an end.
- **Knowledge shared by 2+ projects** → same thing: it's reference, so it lives in `resources/` (or on the relevant technology/service page), and each `_project.md` wikilinks it. If both projects hit the same postgres quirk, that's a Gotcha on the [[postgres]] tech page, not two bug notes.
- **A decision/bug/improvement that concretely affects 2+ projects** → file it ONCE, in the project where it surfaced (or the one owning the fix), and set `project:` to a list: `project: [slug-a, slug-b]`. Wikilink it from the other project's `_project.md`. Dashboards filter with `project.contains("slug-a")`.
- **Promotion**: when a note written inside one project turns out to matter to a second one, promote it — move the file to `resources/` (or merge into the tech/service page), leave wikilinks from both projects. Move, don't copy; update `related:` links after moving.

Litmus test when filing: "if this project ended tomorrow, is the note dead?" Dead with the project → `projects/<slug>/`. Still useful → `resources/`/`areas/`.

## Frontmatter contract

Every engineering note carries `type`, `title`, `project`, `status`, `created`, `updated`, `tags`. Dashboards (engineering.base) key on these — a note with missing `type`/`project`/`status` is invisible to them. `wiki-lint` should flag violations.

`project:` is a single slug, a list (`[slug-a, slug-b]` for notes affecting several projects), or `cross` for company-wide notes with no specific project.

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

## Org map: people, teams, services, glossary, processes

The "who/what/how" layer — highest-value queries a work brain answers: *who owns X, who do I ask about Y, what does term Z mean, how do we deploy*.

- **People** (`entities/`): every person — colleagues, clients, partners. Factual and professional only — role, expertise, what they own, how to engage. Rule: nothing you wouldn't be comfortable with the person reading. No opinions, no performance judgments. Interaction log = context ("agreed Y on date"), not surveillance.
- **Companies / teams** (`entities/`): mission, members (wikilink person pages), owned services, intake process. Members list is the join point — person pages point back via `team:`. People and organizations share `entities/` — it is the single org map.
- **Services** (`areas/operations/services/`): one page per running system. Distinct from technology pages: postgres = technology (`resources/tools/`), billing-db = service (an instance, with an owner and incidents). Services wikilink their `tech:`, `owner_team:`, runbooks, and incident notes — incidents and runbooks link back. "Who to page" lives here.
- **Glossary** (`resources/glossary/`): one page per term, cheap to capture the moment jargon appears in a meeting. Ask-don't-guess: if the agent meets an unknown acronym in a session, it should check the glossary before asking.
- **Processes** (`processes/`, top-level): deploy flow, access requests, release rituals. Like runbooks but organizational. Every process wikilinks the **tools** it depends on (`resources/tools/` pages, mirrored in the `tools:` frontmatter) and, if it serves one, the **project** it belongs to (`project:` + a link to that `_project.md`). Bump `last_verified` when followed successfully.

Everything wikilinks: person → team → services → tech → projects → bugs/incidents. wiki-query walks these chains, so a well-linked page multiplies the value of every other page.

## Starting a new project

1. Create `wiki/projects/<slug>/_project.md` from `_templates/project.md` (+ empty `bugs/ decisions/ improvements/ notes/`)
2. Add the project to [[hot]] under Active context
3. Log it in [[log]]

## Role checklists — what belongs in here

**Developer:** every non-trivial bug (symptom + root cause, not just the fix), every architecture/library decision, tech-debt improvements as you spot them, snippets you'd otherwise re-google, per-session `/save`.

**Operations:** every incident within 24h while memory is fresh, runbook for anything done twice, infra/services as entity notes under `resources/tools/`, verify+bump runbooks when used.

**Designer:** design explorations before they're lost to Figma history, feedback logs on the design note itself, design-system components under `areas/design-system/`, inspiration with source links under `resources/design/`.
