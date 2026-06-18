# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

Centralized store for Claude Code configuration: agents and plugins. Clone this repo and run `/apply` to configure a new machine.

## Repository Structure

- `common/agents/` — global agents, symlinked to `~/.claude/agents/` by `/apply`
- `common/_claude.md` — optional; applied to `~/.claude/CLAUDE.md` by `/apply`
- `projects/<project>/` — git submodule per project, containing `agents/`
- `projects/<project>/_claude.md` — optional; applied to the project's `CLAUDE.md` by `/apply`
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

## Adding a _claude.md

Place a `_claude.md` at:
- `common/_claude.md` — applied to `~/.claude/CLAUDE.md` (global Claude config)
- `projects/<project>/_claude.md` — applied to the project's `CLAUDE.md`

When `/apply` runs and finds a `_claude.md`, it prompts:
- **Copy/override** — replaces the target `CLAUDE.md` with this file
- **Reference** — prepends a pointer to the top of the existing target

## Adding a New Project

1. Create a new git repo for the project config (e.g. `atlas-claude-config`)
2. Add it as a submodule: `git submodule add <url> projects/<project>`
3. Inside the submodule, create `agents/` as needed
4. Commit the `.gitmodules` change in claude-hub
