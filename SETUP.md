# SETUP — Work Laptop Bootstrap

Instructions for setting up a work laptop into the tablinum system: Obsidian on Windows, opencode (or another Agent Skills-compatible agent) in WSL2, vault on the Windows filesystem.

Written for an AI agent: if you are an agent reading this on a fresh machine, fill the settings from the user, execute the steps top to bottom, verify each, and report what was done. A human can follow them manually too.

**Golden rule of this vault: work content never leaves the work laptop.** The GitHub remote is fetch-only (machinery updates in), push is disabled (work notes never out). See step 3.

---

## 0. Settings

Customize per laptop / per job. Ask the user for anything not derivable.

| Setting | Value | Notes |
|---------|-------|-------|
| `WIN_USER` | `<windows username>` | `cmd.exe /c "echo %USERNAME%"` from WSL |
| `VAULT_WIN` | `C:\Users\<WIN_USER>\Git\tablinum` | Windows path — what Obsidian opens |
| `VAULT_WSL` | `/mnt/c/Users/<WIN_USER>/Git/tablinum` | Same folder from WSL — what the agent opens |
| `GIT_NAME` / `GIT_EMAIL` | `<work identity>` | Work name + work email — NOT the personal identity |
| `AGENT` | `opencode` | Or `claude-code`, `codex` — affects step 4 symlink target |
| `WIKI_TOPIC` | `<one sentence>` | What this brain is about, e.g. "my work as a backend engineer at Acme on payments infra" — used to scaffold in step 6 |
| `BACKUP` | `<OneDrive path or "employer backup">` | Local-only content needs a backup story — see step 7 |

The vault lives on the Windows side (not inside WSL) on purpose: Obsidian's file watching and obsidian-git are reliable on NTFS, and a markdown vault is small enough that `/mnt/c` overhead doesn't matter.

## 1. State check first

Steps are idempotent — check what exists, skip what is done:

```bash
command -v git node                      # required in WSL
command -v python3                       # needed for retrieval tooling (scripts/)
ls "$VAULT_WSL" 2>/dev/null              # vault cloned?
ls ~/.opencode/skills/tablinum 2>/dev/null  # skills linked?
```

## 2. Prerequisites

Windows side (PowerShell, winget ids): `Obsidian.Obsidian`, `Git.Git` (optional — WSL git suffices for the vault).

WSL side: `git`, `nodejs` (LTS), `python3`, `make` via the distro package manager, plus the agent itself (opencode: `curl -fsSL https://opencode.ai/install | bash` or per current docs).

## 3. Clone — fetch-only remote

The repo is public — no GitHub credentials needed on the work laptop, ever:

```bash
git clone https://github.com/CoderVinz/tablinum.git "$VAULT_WSL"
```

Then lock it down:

```bash
cd "$VAULT_WSL"
git remote set-url --push origin DISABLED   # fetch-only: pull machinery updates, never push
git config user.name  "$GIT_NAME"           # work identity, repo-local
git config user.email "$GIT_EMAIL"
git config core.autocrlf input              # required: avoids phantom-modified CRLF churn on /mnt/c
git config pull.rebase true                 # local content commits replay on top of machinery updates
git config rebase.autoStash true            # Obsidian keeps the tree dirty; stash/unstash around pulls
cp -rn _templates/obsidian .obsidian                # bootstrap Obsidian config: plugins, settings, graph colors (untracked, machine-local after copy)
```

Verify: `git remote -v` must show `DISABLED` as the push URL. `git push` must fail.

The entire `.obsidian/` directory plus runtime state files
(`.raw/.manifest.json`, `.vault-meta/address-counter.txt`,
`.vault-meta/tiling-thresholds.json`) are gitignored — Obsidian and the vault
machinery rewrite them constantly, and tracking any of them made `git pull`
collide. The shipped Obsidian config lives in `_templates/obsidian/` and is
copied once by the line above. Never `git add -f` anything under `.obsidian/`.

## 4. Install skills for the agent

From the vault root:

```bash
bash bin/setup-multi-agent.sh
```

Or manually for opencode:

```bash
mkdir -p ~/.opencode/skills
ln -s "$VAULT_WSL/skills" ~/.opencode/skills/tablinum
```

`AGENTS.md` in the vault root is picked up automatically by opencode when working inside the repo — it covers session bootstrap (read `wiki/hot.md` first) and conventions.

## 5. Obsidian

1. Run `bash bin/setup-vault.sh` from the vault root (downloads the Excalidraw plugin binary, not tracked in git).
2. Open Obsidian → Open folder as vault → `VAULT_WIN`.
3. Trust the vault and enable community plugins when prompted.
4. obsidian-git ships pre-installed and pre-configured (auto-commit every 10 min, push/pull disabled — settings are committed in `.obsidian/plugins/obsidian-git/data.json`). Just verify in Settings → Community plugins that it is enabled; don't turn push back on.

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
- **Machinery improvements out**: if you improve a skill/template here and want to keep it across jobs, redo the change in the tablinum repo from the personal machine and push from there. Never from here.
- Employer policy check: opencode sends prompts/content to its configured model provider — confirm the provider and the note-taking itself are within policy before putting sensitive work information in the vault.

## 8. DragonScale Memory (optional memory layer)

DragonScale is an opt-in extension that keeps a growing vault tidy and self-linking. It is **not required** — the base vault works without it. Enable it **on this laptop** (it is machine-local; enabling on the personal box does nothing here). All its state (`address-counter.txt`, `tiling-thresholds.json`, `legacy-pages.txt`, `.raw/.manifest.json`) is gitignored and created by setup.

**Enable (once, before your first ingest):**

```bash
bash bin/setup-dragonscale.sh
```

Run it **before ingesting any content**. `wiki-ingest` and `wiki-lint` both gate on `.vault-meta/address-counter.txt` — until setup creates it, addresses stay off in *both* (consistent). Enabling on a fresh vault sets the rollout baseline to today, so there is **zero backfill**: every page from now on gets a stable `address:`, nothing older is enforced.

**Mechanisms and what each needs:**

| Mech | What it does | Extra deps | Recommend |
|------|--------------|-----------|-----------|
| 1 Fold (`/wiki-fold`) | rolls up old log entries so the vault stays lean | none | **on** |
| 2 Addresses | stable page IDs that survive renames | `flock` (standard in WSL2) | **on** |
| 3 Tiling lint | flags near-duplicate pages via local embeddings | `python3` + `ollama` + `ollama pull nomic-embed-text` | skip unless you already run Ollama |
| 4 Boundary autoresearch | picks frontier topics for `/autoresearch` | `python3` | only if you lean on `/autoresearch` |

Mechanisms with missing deps **fail closed / no-op** — the setup script prints a sanity report showing which are live. Re-running setup is idempotent (never overwrites existing state). Mech 1 + 2 are the light, high-value pair; 3 is the only one needing the embedding stack.

**Verify after enabling:** `bash bin/setup-dragonscale.sh` again — the "Sanity checks" block reports `next address`, `python3`, `ollama`, `nomic-embed` status. `/wiki-lint` will then validate addresses (uniqueness, format, post-rollout enforcement).

## 9. Changing job or laptop

Nothing to migrate: work content belongs to the employer and stays (or is disposed of) per their policy. On the next machine, start again from step 0 — the system, templates, and any machinery improvements you pushed from the personal machine are all in the repo.

## Workflow reference

- End of session: `/save`
- Monthly: `/distill`
- Health check: `/wiki-lint`
- Query: "what do you know about X" / `wiki-query`
