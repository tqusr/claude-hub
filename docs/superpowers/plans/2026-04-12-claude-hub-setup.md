# Claude Hub Setup Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Populate the `claude-hub` repository with agents, vault scaffolding, plugin documentation, and an `/apply` skill that bootstraps a new machine.

**Architecture:** Top level splits into `common/` (global agents + shared vaults) and `projects/` (per-project submodules). Each project submodule is its own git repo containing `agents/` and `vaults/`. The `/apply` skill lives at `skills/apply.md`, symlinked to `~/.claude/commands/apply.md` for Claude Code discovery.

**Tech Stack:** Bash, git submodules, Claude Code skill markdown files

---

## File Map

| Action | Path | Purpose |
|--------|------|---------|
| Create | `common/agents/code-documenter.md` | Global agent |
| Create | `common/agents/expert-debugger.md` | Global agent |
| Create | `common/agents/expert-developer.md` | Global agent |
| Create | `common/agents/workflow-planner.md` | Global agent |
| Create | `common/agents/embedded-system-tester.md` | Global agent |
| Create | `common/agents/obsidian-embedded-kb.md` | Global agent (vault path updated) |
| Create | `common/agents/yocto-build-engineer.md` | Global agent |
| Create | `common/vaults/.gitkeep` | Placeholder for future common vaults |
| Create | `projects/embedded/agents/embedded-system-tester.md` | Atlas-specific agent (inside submodule) |
| Create | `projects/embedded/agents/obsidian-embedded-kb.md` | Atlas-specific agent (inside submodule) |
| Create | `projects/embedded/agents/yocto-build-engineer.md` | Atlas-specific agent (inside submodule) |
| Create | `projects/embedded/vaults/.gitkeep` | Placeholder; vault submodule added later |
| Create | `skills/apply.md` | `/apply` slash command |
| Create | `plugins.md` | Plugin documentation |
| Create | `CLAUDE.md` | Repo guidance |

---

## Task 1: Create directory structure, CLAUDE.md, and plugins.md

**Files:**
- Create: `common/vaults/.gitkeep`
- Create: `plugins.md`
- Create: `CLAUDE.md`

- [ ] **Step 1: Create directory scaffolding**

```bash
mkdir -p common/agents common/vaults skills
touch common/vaults/.gitkeep
```

- [ ] **Step 2: Verify directories exist**

```bash
find . -not -path './.git/*' -type d | sort
```

Expected output includes: `./common/agents`, `./common/vaults`, `./skills`

- [ ] **Step 3: Write plugins.md**

```markdown
# Plugins

## superpowers

- **Plugin ID:** `superpowers@claude-plugins-official`
- **Marketplace:** `superpowers-dev` (source: github:obra/superpowers)
- **Install:** `claude plugin install superpowers@claude-plugins-official`
- **Current version:** 5.0.7
- **Purpose:** Provides skills for brainstorming, planning, TDD, debugging, code review, and agent orchestration workflows.

## claude-hud

- **Plugin ID:** `claude-hud@claude-hud`
- **Marketplace:** `claude-hud` (source: github:jarrodwatts/claude-hud)
- **Install:** `claude plugin install claude-hud@claude-hud`
- **Current version:** 0.0.12
- **Purpose:** Terminal statusline showing Claude Code session info.
```

- [ ] **Step 4: Write CLAUDE.md**

```markdown
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

Centralized store for Claude Code configuration: agents, knowledge vaults, and plugins. Clone this repo and run `/apply` to configure a new machine.

## Repository Structure

- `common/agents/` — global agents, symlinked to `~/.claude/agents/` by `/apply`
- `common/vaults/` — shared knowledge vaults (git submodules), cloned by `/apply`
- `projects/<project>/` — git submodule per project, containing `agents/` and `vaults/`
- `skills/apply.md` — the `/apply` slash command
- `plugins.md` — plugin documentation and install commands

## Bootstrapping a New Machine

1. Clone this repo: `git clone <remote> ~/claude-hub`
2. Register the `/apply` command:
   ```bash
   mkdir -p ~/.claude/commands
   ln -s ~/claude-hub/skills/apply.md ~/.claude/commands/apply.md
   ```
3. Run `/apply` in a Claude Code session — it will symlink agents, clone common vaults, and install plugins.

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

- Push the vault to a remote git repo
- Common vault: `git submodule add <url> common/vaults/<name>`
- Project vault: add inside the project submodule at `vaults/<name>`
- Common vaults are cloned automatically by `/apply`; project vaults are cloned with the project submodule

## Vault Structure Convention

Each vault follows the `embedded-documentation` pattern:
- `raw/` — immutable source documents (never edited by agents)
- `wiki/` — LLM-generated markdown organized by category
- `index.md` — lean master index (~50 lines)
- `log.md` — append-only operation log
- `CLAUDE.md` — governs agent behavior within the vault
```

- [ ] **Step 5: Commit**

```bash
git add common/ skills/ plugins.md CLAUDE.md
git commit -m "feat: initialize claude-hub structure with CLAUDE.md and plugins.md"
```

---

## Task 2: Add global common agents

Copy the 6 straightforward global agents (all except `obsidian-embedded-kb`) from `~/.claude/agents/` into `common/agents/`.

**Files:**
- Create: `common/agents/code-documenter.md`
- Create: `common/agents/expert-debugger.md`
- Create: `common/agents/expert-developer.md`
- Create: `common/agents/workflow-planner.md`
- Create: `common/agents/embedded-system-tester.md`
- Create: `common/agents/yocto-build-engineer.md`

- [ ] **Step 1: Copy agents**

```bash
cp ~/.claude/agents/code-documenter.md common/agents/
cp ~/.claude/agents/expert-debugger.md common/agents/
cp ~/.claude/agents/expert-developer.md common/agents/
cp ~/.claude/agents/workflow-planner.md common/agents/
cp ~/.claude/agents/embedded-system-tester.md common/agents/
cp ~/.claude/agents/yocto-build-engineer.md common/agents/
```

- [ ] **Step 2: Verify all 6 files are present**

```bash
ls common/agents/
```

Expected: `code-documenter.md`, `embedded-system-tester.md`, `expert-debugger.md`, `expert-developer.md`, `workflow-planner.md`, `yocto-build-engineer.md`

- [ ] **Step 3: Commit**

```bash
git add common/agents/
git commit -m "feat: add global common agents"
```

---

## Task 3: Add obsidian-embedded-kb with updated vault path

Copy `obsidian-embedded-kb.md` into `common/agents/` and replace every occurrence of `~/embedded-documentation/` with `~/claude-hub/projects/embedded/vaults/embedded-documentation/`.

**Files:**
- Create: `common/agents/obsidian-embedded-kb.md`

- [ ] **Step 1: Copy the agent**

```bash
cp ~/.claude/agents/obsidian-embedded-kb.md common/agents/obsidian-embedded-kb.md
```

- [ ] **Step 2: Replace all vault path references**

```bash
sed -i 's|~/embedded-documentation/|~/claude-hub/projects/embedded/vaults/embedded-documentation/|g' common/agents/obsidian-embedded-kb.md
```

- [ ] **Step 3: Verify the old path is gone**

```bash
grep "~/embedded-documentation/" common/agents/obsidian-embedded-kb.md
```

Expected: no output (zero matches)

- [ ] **Step 4: Verify the new path is present**

```bash
grep -c "~/claude-hub/projects/embedded/vaults/embedded-documentation/" common/agents/obsidian-embedded-kb.md
```

Expected: a number greater than 0

- [ ] **Step 5: Commit**

```bash
git add common/agents/obsidian-embedded-kb.md
git commit -m "feat: add obsidian-embedded-kb with hub-relative vault path"
```

---

## Task 4: Create atlas project submodule and add project agents

The `projects/embedded/` directory will eventually be a proper git submodule. For now, initialize it as a standalone git repo within the hub so the agents and vault structure are in place. When `embedded-documentation` has a remote, `projects/embedded` can be pushed to its own remote and registered as a submodule of `claude-hub`.

**Files:**
- Create: `projects/embedded/agents/embedded-system-tester.md`
- Create: `projects/embedded/agents/obsidian-embedded-kb.md`
- Create: `projects/embedded/agents/yocto-build-engineer.md`
- Create: `projects/embedded/vaults/.gitkeep`

- [ ] **Step 1: Initialize projects/embedded as a git repo**

```bash
mkdir -p projects/embedded/agents projects/embedded/vaults
git init projects/embedded
touch projects/embedded/vaults/.gitkeep
```

- [ ] **Step 2: Copy atlas project agents**

```bash
cp ~/atlas/.claude/agents/embedded-system-tester.md projects/embedded/agents/
cp ~/atlas/.claude/agents/obsidian-embedded-kb.md projects/embedded/agents/
cp ~/atlas/.claude/agents/yocto-build-engineer.md projects/embedded/agents/
```

- [ ] **Step 3: Verify all 3 agent files are present**

```bash
ls projects/embedded/agents/
```

Expected: `embedded-system-tester.md`, `obsidian-embedded-kb.md`, `yocto-build-engineer.md`

- [ ] **Step 4: Write projects/embedded/CLAUDE.md**

```markdown
# CLAUDE.md — Atlas Project Config

This submodule contains Claude Code configuration for the Atlas/Yocto embedded Linux project.

## Contents

- `agents/` — project-specific agents for Atlas development
- `vaults/` — knowledge vaults (git submodules)

## Vault

The `embedded-documentation` vault (when added) contains the Yocto/embedded Linux knowledge wiki. It follows the standard vault structure with `raw/`, `wiki/`, `index.md`, `log.md`, and `CLAUDE.md`.

## Applying to a machine

```bash
git -C ~/claude-hub submodule update --init -- projects/embedded
ln -s ~/claude-hub/projects/embedded/agents/<agent>.md ~/atlas/.claude/agents/<agent>.md
```
```

- [ ] **Step 5: Commit inside the atlas submodule**

```bash
git -C projects/embedded add .
git -C projects/embedded commit -m "feat: initialize atlas project config with agents"
```

- [ ] **Step 6: Add projects/embedded as a submodule of claude-hub**

```bash
git submodule add ./projects/embedded projects/embedded
```

Note: This uses the local path. Once `projects/embedded` is pushed to a remote, update `.gitmodules` with the real URL:
```bash
git submodule set-url projects/embedded <remote-url>
```

- [ ] **Step 7: Commit the submodule registration**

```bash
git add .gitmodules projects/embedded
git commit -m "feat: add atlas as project submodule"
```

---

## Task 5: Write the /apply skill

**Files:**
- Create: `skills/apply.md`

- [ ] **Step 1: Write skills/apply.md**

```markdown
---
description: Bootstrap this machine with agents, vaults, and plugins from claude-hub
---

Apply the claude-hub configuration to this machine. Work through these steps in order and report a summary when done.

## 1. Symlink common agents

For each `.md` file in `~/claude-hub/common/agents/`, create or update a symlink in `~/.claude/agents/`:

```bash
for f in ~/claude-hub/common/agents/*.md; do
  name=$(basename "$f")
  target=~/.claude/agents/"$name"
  if [ -L "$target" ]; then
    ln -sf "$f" "$target"
    echo "replaced symlink: $name"
  elif [ -f "$target" ]; then
    echo "CONFLICT: $name is a regular file — ask user to replace or skip"
  else
    ln -s "$f" "$target"
    echo "created symlink: $name"
  fi
done
```

For any CONFLICT lines, pause and ask the user: "~/.claude/agents/<name> is a regular file, not a symlink. Replace with symlink or skip?" before continuing.

## 2. Clone common vaults

```bash
git -C ~/claude-hub submodule update --init --recursive -- common/vaults/
```

If `common/vaults/` has no submodules yet, this is a no-op — that is fine.

## 3. Install plugins

```bash
claude plugin install superpowers@claude-plugins-official
claude plugin install claude-hud@claude-hud
```

If a plugin is already installed, the command skips it gracefully.

## 4. Report summary

Print what was:
- Symlinked (new)
- Replaced (existing symlink updated)
- Skipped (user chose to skip a conflict)
- Plugins installed / already present
```

- [ ] **Step 2: Symlink the skill so /apply is discoverable by Claude Code**

```bash
mkdir -p ~/.claude/commands
ln -s ~/claude-hub/skills/apply.md ~/.claude/commands/apply.md
```

- [ ] **Step 3: Verify the symlink**

```bash
ls -la ~/.claude/commands/apply.md
```

Expected: a symlink pointing to `~/claude-hub/skills/apply.md`

- [ ] **Step 4: Commit**

```bash
git add skills/apply.md
git commit -m "feat: add /apply skill for bootstrapping new machines"
```

---

## Task 6: Verify the full setup on the current machine

Run `/apply` to confirm it correctly handles the current machine (agents already exist as regular files — it should prompt per conflict).

- [ ] **Step 1: Check current state of ~/.claude/agents/**

```bash
ls -la ~/.claude/agents/
```

Note which files are regular files vs symlinks.

- [ ] **Step 2: Run /apply in a Claude Code session**

Invoke `/apply` and handle any CONFLICT prompts for the 7 common agents that currently exist as regular files.

- [ ] **Step 3: Verify symlinks point into the hub**

```bash
ls -la ~/.claude/agents/ | grep "claude-hub"
```

Expected: all 7 common agents are now symlinks pointing into `~/claude-hub/common/agents/`.

- [ ] **Step 4: Final commit if any cleanup is needed**

```bash
git -C ~/claude-hub status
git -C ~/claude-hub add -A && git -C ~/claude-hub commit -m "chore: finalize claude-hub initial setup" || echo "nothing to commit"
```
