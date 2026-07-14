# SETUP — Work Laptop Bootstrap

Instructions for setting up a work laptop into the workmind system: Obsidian on Windows, opencode (or another Agent Skills-compatible agent) in WSL2, vault on the Windows filesystem.

Written for an AI agent: if you are an agent reading this on a fresh machine, fill the settings from the user, execute the steps top to bottom, verify each, and report what was done. A human can follow them manually too.

**Golden rule of this vault: work content never leaves the work laptop.** The GitHub remote is fetch-only (machinery updates in), push is disabled (work notes never out). See step 3.

---

## 0. Settings

Customize per laptop / per job. Ask the user for anything not derivable.

| Setting | Value | Notes |
|---------|-------|-------|
| `WIN_USER` | `<windows username>` | `cmd.exe /c "echo %USERNAME%"` from WSL |
| `VAULT_WIN` | `C:\Users\<WIN_USER>\Git\workmind` | Windows path — what Obsidian opens |
| `VAULT_WSL` | `/mnt/c/Users/<WIN_USER>/Git/workmind` | Same folder from WSL — what the agent opens |
| `GIT_NAME` / `GIT_EMAIL` | `<work identity>` | Work name + work email — NOT the personal identity |
| `AGENT` | `opencode` | Or `claude-code`, `codex` — affects step 4 symlink target |
| `WIKI_TOPIC` | `<one sentence>` | What this brain is about, e.g. "my work as a backend engineer at Acme on payments infra" — used to scaffold in step 6 |
| `BACKUP` | `<OneDrive path or "employer backup">` | Local-only content needs a backup story — see step 7 |

The vault lives on the Windows side (not inside WSL) on purpose: Obsidian's file watching and obsidian-git are reliable on NTFS, and a markdown vault is small enough that `/mnt/c` overhead doesn't matter.

## 1. State check first

Steps are idempotent — check what exists, skip what is done:

```bash
command -v git node                      # required in WSL
command -v python3 make                  # needed for retrieval tooling (scripts/, Makefile)
ls "$VAULT_WSL" 2>/dev/null              # vault cloned?
ls ~/.opencode/skills/workmind 2>/dev/null  # skills linked?
```

## 2. Prerequisites

Windows side (PowerShell, winget ids): `Obsidian.Obsidian`, `Git.Git` (optional — WSL git suffices for the vault).

WSL side: `git`, `nodejs` (LTS), `python3`, `make` via the distro package manager, plus the agent itself (opencode: `curl -fsSL https://opencode.ai/install | bash` or per current docs).

## 3. Clone — fetch-only remote

The repo is public — no GitHub credentials needed on the work laptop, ever:

```bash
git clone https://github.com/CoderVinz/workmind.git "$VAULT_WSL"
```

Then lock it down:

```bash
cd "$VAULT_WSL"
git remote set-url --push origin DISABLED   # fetch-only: pull machinery updates, never push
git config user.name  "$GIT_NAME"           # work identity, repo-local
git config user.email "$GIT_EMAIL"
git config core.autocrlf input              # required: avoids phantom-modified CRLF churn on /mnt/c
```

Verify: `git remote -v` must show `DISABLED` as the push URL. `git push` must fail.

## 4. Install skills for the agent

From the vault root:

```bash
bash bin/setup-multi-agent.sh
```

Or manually for opencode:

```bash
mkdir -p ~/.opencode/skills
ln -s "$VAULT_WSL/skills" ~/.opencode/skills/workmind
```

`AGENTS.md` in the vault root is picked up automatically by opencode when working inside the repo — it covers session bootstrap (read `wiki/hot.md` first) and conventions.

## 5. Obsidian

1. Run `bash bin/setup-vault.sh` from the vault root (downloads the Excalidraw plugin binary, not tracked in git).
2. Open Obsidian → Open folder as vault → `VAULT_WIN`.
3. Trust the vault and enable community plugins when prompted.
4. obsidian-git plugin: enable **auto-commit only** — turn OFF auto-push and auto-pull (push is disabled at the git level anyway, but keep the plugin from erroring).

## 6. Scaffold the wiki

The vault is pre-configured in **PARA mode** (`.vault-meta/mode.json`, committed) with an engineering layer for multi-project dev/ops/design work — see `wiki/references/engineering-conventions.md` for the layout, routing table, and note lifecycles. Dashboards: open `wiki/meta/engineering.base` in Obsidian.

In the agent, at the vault root, say:

> set up wiki: `WIKI_TOPIC`

The `wiki` skill scaffolds the domain specifics (hot cache, overview). Then for each active project:

> new project: `<name>` — creates `wiki/projects/<slug>/_project.md` from `_templates/project.md` per the conventions doc

Commit the scaffold locally.

## 7. Content rules — read this, future me

- **Commit locally, freely.** Full git history stays on this laptop. Never push (it's disabled — leave it that way).
- **Backup**: local-only means this laptop holds the only copy of the content. Either place the vault inside a work OneDrive-synced folder, or confirm employer endpoint backup covers it. Record the choice in `BACKUP`.
- **Machinery updates in**: `git fetch origin && git merge origin/main` (merge may touch machinery files only; content lives in paths the remote never changes).
- **Machinery improvements out**: if you improve a skill/template here and want to keep it across jobs, redo the change in the workmind repo from the personal machine and push from there. Never from here.
- Employer policy check: opencode sends prompts/content to its configured model provider — confirm the provider and the note-taking itself are within policy before putting sensitive work information in the vault.

## 8. Changing job or laptop

Nothing to migrate: work content belongs to the employer and stays (or is disposed of) per their policy. On the next machine, start again from step 0 — the system, templates, and any machinery improvements you pushed from the personal machine are all in the repo.

## Workflow reference

- End of session: `/save`
- Monthly: `/distill`
- Health check: `/wiki-lint`
- Query: "what do you know about X" / `wiki-query`
