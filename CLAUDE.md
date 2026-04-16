# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

Centralized store for Claude Code configuration: agents, knowledge vaults, and plugins. Clone this repo and run `/apply` to configure a new machine.

## Repository Structure

- `common/agents/` — global agents, symlinked to `~/.claude/agents/` by `/apply`
- `common/vaults/` — shared knowledge vaults (regular directories, committed to this repo)
- `projects/<project>/` — git submodule per project, containing `agents/` and `vaults/`
- `skills/apply.md` — the `/apply` slash command (thin wrapper around `scripts/apply.sh`)
- `scripts/apply.sh` — the apply implementation
- `plugins.md` — plugin documentation and install commands

## Bootstrapping a New Machine

1. Clone this repo: `git clone <remote> ~/claude-hub`
2. Register the `/apply` command:
   ```bash
   mkdir -p ~/.claude/commands
   ln -s ~/claude-hub/skills/apply.md ~/.claude/commands/apply.md
   ```
3. Run `/apply` in a Claude Code session (or `bash ~/claude-hub/scripts/apply.sh` directly) — it will symlink agents and install plugins.

## Working on a Project

```bash
# Clone the project submodule
git -C ~/claude-hub submodule update --init -- projects/embedded

# Symlink project agents into the project's .claude/agents/
ln -s ~/claude-hub/projects/embedded/agents/<agent>.md ~/<project>/.claude/agents/<agent>.md
```

## Adding a New Global Agent

Add to `common/agents/` and commit. Run `/apply` (or manually symlink) to activate.

## Adding a New Project

1. Create a new git repo for the project config (e.g. `atlas-claude-config`)
2. Add it as a submodule: `git submodule add <url> projects/<project>`
3. Inside the submodule, create `agents/` and `vaults/` as needed
4. Commit the `.gitmodules` change in claude-hub

## Adding a New Vault

- Common vault: add the vault directory to `common/vaults/<name>` and commit
- Project vault: add inside the project submodule at `vaults/<name>` and commit + push the submodule

## Vault Structure Convention

Each vault follows the `embedded-documentation` pattern:
- `raw/` — immutable source documents (never edited by agents)
- `wiki/` — LLM-generated markdown organized by category
- `index.md` — lean master index (~50 lines)
- `log.md` — append-only operation log
- `CLAUDE.md` — governs agent behavior within the vault
