# Claude Hub — Design Spec

**Date:** 2026-04-12  
**Status:** Approved

---

## Purpose

A git repository that centralizes Claude Code configuration — agents, knowledge vaults, and plugin documentation — so it can be bootstrapped onto any new machine with a single `/apply` command.

---

## Repository Structure

```
claude-hub/
├── agents/
│   ├── common/                        # Global agents, symlinked to ~/.claude/agents/ by /apply
│   │   ├── code-documenter.md
│   │   ├── expert-debugger.md
│   │   ├── expert-developer.md
│   │   ├── workflow-planner.md
│   │   ├── embedded-system-tester.md
│   │   ├── obsidian-embedded-kb.md    # vault path updated to ~/claude-hub/vaults/
│   │   └── yocto-build-engineer.md
│   └── projects/
│       └── atlas/                     # Applied manually when starting work on atlas
│           ├── embedded-system-tester.md
│           ├── obsidian-embedded-kb.md
│           └── yocto-build-engineer.md
├── vaults/
│   ├── common/                        # Git submodules cloned by /apply
│   └── projects/
│       └── atlas/
│           └── embedded-documentation/  # Git submodule, cloned manually
├── skills/
│   └── apply.md                       # The /apply Claude Code skill
├── plugins.md                         # Plugin documentation and install commands
└── CLAUDE.md
```

---

## Agents

### Common agents (`agents/common/`)

These are global agents that apply on every machine. `/apply` creates symlinks from `~/.claude/agents/<name>.md` → `~/claude-hub/agents/common/<name>.md`.

The `obsidian-embedded-kb` agent is stored in the hub with the vault path updated to `~/claude-hub/vaults/projects/atlas/embedded-documentation/` (instead of `~/embedded-documentation/`). The original agent at `~/.claude/agents/obsidian-embedded-kb.md` is not modified.

### Project agents (`agents/projects/<project>/`)

Agents specific to a project, applied manually when beginning work on that project. The user symlinks them into the project's `.claude/agents/` directory:

```bash
ln -s ~/claude-hub/agents/projects/atlas/<agent>.md ~/atlas/.claude/agents/<agent>.md
```

---

## Vaults

Vaults are git submodules. They are divided into:

- `vaults/common/` — shared knowledge vaults, cloned by `/apply`
- `vaults/projects/<project>/` — project-specific vaults, cloned manually

Currently registered vaults:

| Path | Project | Description |
|------|---------|-------------|
| `vaults/projects/atlas/embedded-documentation` | atlas | Yocto/embedded Linux knowledge wiki |

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

1. **Agents** — for each file in `agents/common/`:
   - If no file exists at `~/.claude/agents/<name>.md`: create symlink
   - If a symlink already exists: replace it
   - If a regular file (non-symlink) exists: ask the user "Replace with symlink or skip?"

2. **Vaults** — run `git submodule update --init --recursive` scoped to `vaults/common/` to clone any common vaults not yet present locally.

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
- Project agent symlinking — done manually per project, not by `/apply`
- Project vault cloning — done manually per project, not by `/apply`
