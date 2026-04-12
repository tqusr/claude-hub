# Claude Hub — Design Spec

**Date:** 2026-04-12  
**Status:** Approved (revised)

---

## Purpose

A git repository that centralizes Claude Code configuration — agents, knowledge vaults, and plugin documentation — so it can be bootstrapped onto any new machine with a single `/apply` command.

---

## Repository Structure

```
claude-hub/
├── common/
│   ├── agents/                        # Global agents, symlinked to ~/.claude/agents/ by /apply
│   │   ├── code-documenter.md
│   │   ├── expert-debugger.md
│   │   ├── expert-developer.md
│   │   ├── workflow-planner.md
│   │   ├── embedded-system-tester.md
│   │   ├── obsidian-embedded-kb.md    # vault path updated to ~/claude-hub/projects/atlas/vaults/
│   │   └── yocto-build-engineer.md
│   └── vaults/                        # Git submodules for shared vaults, cloned by /apply
├── projects/
│   └── atlas/                         # Git submodule — self-contained project config
│       ├── agents/
│       │   ├── embedded-system-tester.md
│       │   ├── obsidian-embedded-kb.md
│       │   └── yocto-build-engineer.md
│       └── vaults/
│           └── embedded-documentation/  # Git submodule within atlas submodule
├── skills/
│   └── apply.md                       # The /apply Claude Code skill
├── plugins.md                         # Plugin documentation and install commands
└── CLAUDE.md
```

---

## Top-Level Split: `common/` vs `projects/`

The top level divides by scope, not by resource type:

- **`common/`** — everything that applies on every machine regardless of project: global agents and shared vaults.
- **`projects/<project>/`** — everything for a specific project (agents, vaults, and in future: plugins, settings overrides, etc.), packaged as a **git submodule**. Adding a project to a new machine is a single `git submodule add`.

---

## Common Agents (`common/agents/`)

These are global agents that apply on every machine. `/apply` creates symlinks from `~/.claude/agents/<name>.md` → `~/claude-hub/common/agents/<name>.md`.

The `obsidian-embedded-kb` agent is stored in the hub with the vault path updated to `~/claude-hub/projects/atlas/vaults/embedded-documentation/` (instead of `~/embedded-documentation/`). The original agent at `~/.claude/agents/obsidian-embedded-kb.md` is not modified.

---

## Project Submodules (`projects/<project>/`)

Each project directory is a **git submodule** with its own repository. It contains whatever config is relevant to that project:

```
projects/atlas/
├── agents/       # Project-specific agents
└── vaults/       # Project-specific vaults (git submodules within this repo)
```

Project submodules are **not** applied automatically by `/apply`. When starting work on a project:

```bash
# Clone the project submodule
git -C ~/claude-hub submodule update --init -- projects/atlas

# Symlink project agents into the project's .claude/agents/
ln -s ~/claude-hub/projects/atlas/agents/<agent>.md ~/atlas/.claude/agents/<agent>.md
```

Currently registered project submodules:

| Path | Description |
|------|-------------|
| `projects/atlas/` | Atlas/Yocto embedded Linux project — agents and vaults |

---

## Vaults

Vaults are git submodules. Shared vaults live in `common/vaults/` (cloned by `/apply`); project vaults live inside the project submodule (cloned manually with the project).

Currently registered vaults:

| Path | Project | Description |
|------|---------|-------------|
| `projects/atlas/vaults/embedded-documentation` | atlas | Yocto/embedded Linux knowledge wiki |

### Vault structure convention

Each vault follows the `embedded-documentation` pattern:
- `raw/` — immutable source documents (never edited by agents)
- `wiki/` — LLM-generated markdown, organized by category
- `index.md` — lean master index (~50 lines)
- `log.md` — append-only operation log
- `CLAUDE.md` — governs agent behavior within the vault

---

## `/apply` Skill

Stored at `skills/apply.md`. When invoked via `/apply` in Claude Code, it instructs Claude to:

1. **Agents** — for each file in `common/agents/`:
   - If no file exists at `~/.claude/agents/<name>.md`: create symlink
   - If a symlink already exists: replace it
   - If a regular file (non-symlink) exists: ask the user "Replace with symlink or skip?"

2. **Vaults** — run `git submodule update --init --recursive` scoped to `common/vaults/` to clone any common vaults not yet present locally.

3. **Plugins** — install each plugin listed in `plugins.md` via `claude plugin install`, skipping any already installed.

4. **Summary** — print what was symlinked, replaced, skipped, and installed.

---

## Plugins

Documented in `plugins.md`. Currently:

| Plugin | Marketplace | Install command |
|--------|-------------|-----------------|
| `superpowers@claude-plugins-official` | `superpowers-dev` (github:obra/superpowers) | `claude plugin install superpowers@claude-plugins-official` |
| `claude-hud@claude-hud` | `claude-hud` (github:jarrodwatts/claude-hud) | `claude plugin install claude-hud@claude-hud` |

---

## Out of Scope

- `~/.claude/settings.json` — managed by plugin installation automatically
- Project submodule cloning — done manually per project, not by `/apply`
- Project agent symlinking — done manually per project, not by `/apply`
