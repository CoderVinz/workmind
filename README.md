# workmind

Work second brain — Obsidian vault + agent wiki machinery, portable across work laptops and jobs.

**Design rule: this repo carries the *system*, never the *content*.** Work notes are committed locally on the work laptop and are never pushed here. That keeps work data off personal GitHub, and makes the setup trivially portable when changing laptop or employer.

## What lives here

| Path | Purpose |
|------|---------|
| `SETUP.md` | Work-laptop bootstrap — settings block + step-by-step install (WSL2 + opencode + Obsidian) |
| `skills/`, `commands/`, `agents/`, `hooks/` | Agent wiki machinery (/wiki, /save, /distill, wiki-query, ...) |
| `scripts/`, `bin/`, `Makefile` | Retrieval/index tooling and setup scripts |
| `wiki/` | Starter scaffold only — real content grows locally, never pushed |
| `wiki/references/engineering-conventions.md` | Multi-project engineering layer: PARA layout, routing table, note lifecycles |
| `wiki/meta/engineering.base` | Dashboards: active projects, open bugs, improvement backlog, decisions, incidents, runbooks |
| `_templates/` | Note templates — project, bug, decision, improvement, runbook, incident, design, meeting, snippet |
| `.obsidian/` | Obsidian config + plugins |

## Quick start (work laptop)

```
git clone https://github.com/CoderVinz/workmind.git
```

Then follow **[SETUP.md](SETUP.md)** — open the repo in your agent (opencode) and say "follow SETUP.md".

## Workflow

- End of session: `/save` — files the session into the wiki
- Monthly: `/distill` — consolidates session notes into concept pages
- Health check: `/wiki-lint`

## Credits

Machinery is [claude-obsidian](https://github.com/AgriciDaniel/claude-obsidian) by AgriciDaniel (MIT), plus a `distill` skill. See `ATTRIBUTION.md` and `LICENSE`.
