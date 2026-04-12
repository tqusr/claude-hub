# Claude Hub Setup Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Populate the `claude-hub` repository with agents, vault scaffolding, plugin documentation, and an `/apply` skill that bootstraps a new machine.

**Architecture:** All global agents are copied from `~/.claude/agents/` into `agents/common/`, with `obsidian-embedded-kb` updated to reference the in-repo vault path. Project-specific agents go under `agents/projects/<project>/`. Vaults are git submodules; `embedded-documentation` requires a remote to be set up first. The `/apply` skill lives at `skills/apply.md` and is symlinked to `~/.claude/commands/apply.md` so Claude Code discovers it as `/apply`.

**Tech Stack:** Bash, git submodules, Claude Code skill markdown files

---

## File Map

| Action | Path | Purpose |
|--------|------|---------|
| Create | `agents/common/code-documenter.md` | Global agent |
| Create | `agents/common/expert-debugger.md` | Global agent |
| Create | `agents/common/expert-developer.md` | Global agent |
| Create | `agents/common/workflow-planner.md` | Global agent |
| Create | `agents/common/embedded-system-tester.md` | Global agent |
| Create | `agents/common/obsidian-embedded-kb.md` | Global agent (vault path updated) |
| Create | `agents/common/yocto-build-engineer.md` | Global agent |
| Create | `agents/projects/atlas/embedded-system-tester.md` | Atlas-specific agent |
| Create | `agents/projects/atlas/obsidian-embedded-kb.md` | Atlas-specific agent |
| Create | `agents/projects/atlas/yocto-build-engineer.md` | Atlas-specific agent |
| Create | `vaults/common/.gitkeep` | Placeholder for future common vaults |
| Create | `vaults/projects/atlas/.gitkeep` | Placeholder; submodule added in Task 5 |
| Create | `skills/apply.md` | `/apply` slash command |
| Create | `plugins.md` | Plugin documentation |
| Create | `CLAUDE.md` | Repo guidance |

---

## Task 1: Create directory structure, CLAUDE.md, and plugins.md

**Files:**
- Create: `vaults/common/.gitkeep`
- Create: `vaults/projects/atlas/.gitkeep`
- Create: `plugins.md`
- Create: `CLAUDE.md`

- [ ] **Step 1: Create directory scaffolding**

```bash
mkdir -p agents/common agents/projects/atlas vaults/common vaults/projects/atlas skills
touch vaults/common/.gitkeep vaults/projects/atlas/.gitkeep
```

- [ ] **Step 2: Verify directories exist**

```bash
find . -type d | sort
```

Expected output includes: `./agents/common`, `./agents/projects/atlas`, `./vaults/common`, `./vaults/projects/atlas`, `./skills`

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

- `agents/common/` — global agents, symlinked to `~/.claude/agents/` by `/apply`
- `agents/projects/<project>/` — project-specific agents, applied manually per project
- `vaults/common/` — shared knowledge vaults (git submodules), cloned by `/apply`
- `vaults/projects/<project>/` — project-specific vaults (git submodules), cloned manually
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

## Adding a New Agent

- Global: add to `agents/common/` and commit.
- Project-specific: add to `agents/projects/<project>/` and commit.
- Run `/apply` (or manually symlink) to activate on the current machine.

## Adding a New Vault

- Push the vault to a remote git repo.
- Add as a submodule: `git submodule add <url> vaults/common/<name>` or `vaults/projects/<project>/<name>`.
- Commit the `.gitmodules` change.
- Common vaults are cloned automatically by `/apply`; project vaults are cloned manually.

## Vault Structure Convention

Each vault follows the `embedded-documentation` pattern:
- `raw/` — immutable source documents (never edited by agents)
- `wiki/` — LLM-generated markdown organized by category
- `index.md` — lean master index (~50 lines)
- `log.md` — append-only operation log
- `CLAUDE.md` — governs agent behavior within the vault

## Applying Project Agents Manually

```bash
ln -s ~/claude-hub/agents/projects/atlas/<agent>.md ~/atlas/.claude/agents/<agent>.md
```
```

- [ ] **Step 5: Commit**

```bash
git add agents/ vaults/ skills/ plugins.md CLAUDE.md
git commit -m "feat: initialize claude-hub structure with CLAUDE.md and plugins.md"
```

---

## Task 2: Add global common agents

Copy the 6 straightforward global agents (all except `obsidian-embedded-kb`) from `~/.claude/agents/` into `agents/common/`.

**Files:**
- Create: `agents/common/code-documenter.md`
- Create: `agents/common/expert-debugger.md`
- Create: `agents/common/expert-developer.md`
- Create: `agents/common/workflow-planner.md`
- Create: `agents/common/embedded-system-tester.md`
- Create: `agents/common/yocto-build-engineer.md`

- [ ] **Step 1: Copy agents**

```bash
cp ~/.claude/agents/code-documenter.md agents/common/
cp ~/.claude/agents/expert-debugger.md agents/common/
cp ~/.claude/agents/expert-developer.md agents/common/
cp ~/.claude/agents/workflow-planner.md agents/common/
cp ~/.claude/agents/embedded-system-tester.md agents/common/
cp ~/.claude/agents/yocto-build-engineer.md agents/common/
```

- [ ] **Step 2: Verify all 6 files are present**

```bash
ls agents/common/
```

Expected: `code-documenter.md`, `embedded-system-tester.md`, `expert-debugger.md`, `expert-developer.md`, `workflow-planner.md`, `yocto-build-engineer.md`

- [ ] **Step 3: Commit**

```bash
git add agents/common/
git commit -m "feat: add global common agents"
```

---

## Task 3: Add obsidian-embedded-kb with updated vault path

Copy `obsidian-embedded-kb.md` and replace every occurrence of `~/embedded-documentation/` with `~/claude-hub/vaults/projects/atlas/embedded-documentation/`.

**Files:**
- Create: `agents/common/obsidian-embedded-kb.md`

- [ ] **Step 1: Copy the agent**

```bash
cp ~/.claude/agents/obsidian-embedded-kb.md agents/common/obsidian-embedded-kb.md
```

- [ ] **Step 2: Replace all vault path references**

```bash
sed -i 's|~/embedded-documentation/|~/claude-hub/vaults/projects/atlas/embedded-documentation/|g' agents/common/obsidian-embedded-kb.md
```

- [ ] **Step 3: Verify the replacement — no old path should remain**

```bash
grep "~/embedded-documentation/" agents/common/obsidian-embedded-kb.md
```

Expected: no output (zero matches)

- [ ] **Step 4: Verify the new path is present**

```bash
grep "~/claude-hub/vaults/projects/atlas/embedded-documentation/" agents/common/obsidian-embedded-kb.md | wc -l
```

Expected: a number greater than 0

- [ ] **Step 5: Commit**

```bash
git add agents/common/obsidian-embedded-kb.md
git commit -m "feat: add obsidian-embedded-kb with hub-relative vault path"
```

---

## Task 4: Add atlas project-specific agents

Copy the three atlas project agents from `~/atlas/.claude/agents/`.

**Files:**
- Create: `agents/projects/atlas/embedded-system-tester.md`
- Create: `agents/projects/atlas/obsidian-embedded-kb.md`
- Create: `agents/projects/atlas/yocto-build-engineer.md`

- [ ] **Step 1: Copy agents**

```bash
cp ~/atlas/.claude/agents/embedded-system-tester.md agents/projects/atlas/
cp ~/atlas/.claude/agents/obsidian-embedded-kb.md agents/projects/atlas/
cp ~/atlas/.claude/agents/yocto-build-engineer.md agents/projects/atlas/
```

- [ ] **Step 2: Verify all 3 files are present**

```bash
ls agents/projects/atlas/
```

Expected: `embedded-system-tester.md`, `obsidian-embedded-kb.md`, `yocto-build-engineer.md`

- [ ] **Step 3: Commit**

```bash
git add agents/projects/atlas/
git commit -m "feat: add atlas project-specific agents"
```

---

## Task 5: Add embedded-documentation as a git submodule

**Prerequisite:** `~/embedded-documentation` has no remote configured. Before this task, push it to a remote (GitHub, GitLab, etc.) and note the URL.

**Files:**
- Modify: `.gitmodules` (created by git submodule add)
- Create: `vaults/projects/atlas/embedded-documentation/` (submodule)

- [ ] **Step 1: Push embedded-documentation to a remote (manual step)**

```bash
# In ~/embedded-documentation:
cd ~/embedded-documentation
git remote add origin <your-remote-url>
git push -u origin master
```

Replace `<your-remote-url>` with the actual URL (e.g. `git@github.com:youruser/embedded-documentation.git`).

- [ ] **Step 2: Remove the placeholder .gitkeep from the atlas vault dir**

```bash
git rm vaults/projects/atlas/.gitkeep
```

- [ ] **Step 3: Add the submodule**

```bash
git submodule add <your-remote-url> vaults/projects/atlas/embedded-documentation
```

- [ ] **Step 4: Verify the submodule is registered**

```bash
cat .gitmodules
```

Expected output:
```
[submodule "vaults/projects/atlas/embedded-documentation"]
	path = vaults/projects/atlas/embedded-documentation
	url = <your-remote-url>
```

- [ ] **Step 5: Verify the submodule content is present**

```bash
ls vaults/projects/atlas/embedded-documentation/
```

Expected: `CLAUDE.md`, `docs`, `index.md`, `log.md`, `raw`, `wiki`

- [ ] **Step 6: Commit**

```bash
git add .gitmodules vaults/projects/atlas/embedded-documentation
git commit -m "feat: add embedded-documentation as atlas vault submodule"
```

---

## Task 6: Write the /apply skill

The skill instructs Claude to symlink common agents, clone common vault submodules, and install plugins. It is stored at `skills/apply.md` and symlinked to `~/.claude/commands/apply.md` so Claude Code exposes it as `/apply`.

**Files:**
- Create: `skills/apply.md`

- [ ] **Step 1: Write skills/apply.md**

```markdown
---
description: Bootstrap this machine with agents, vaults, and plugins from claude-hub
---

Apply the claude-hub configuration to this machine. Work through these steps in order and report a summary when done.

## 1. Symlink common agents

For each `.md` file in `~/claude-hub/agents/common/`:

1. Check if `~/.claude/agents/<filename>` exists:
   - **Does not exist** → create symlink: `ln -s ~/claude-hub/agents/common/<filename> ~/.claude/agents/<filename>`
   - **Is already a symlink** → replace it: `ln -sf ~/claude-hub/agents/common/<filename> ~/.claude/agents/<filename>`
   - **Is a regular file (not a symlink)** → ask the user: "~/.claude/agents/<filename> is a regular file, not a symlink. Replace with symlink or skip?"

Run this for all files:

```bash
for f in ~/claude-hub/agents/common/*.md; do
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

For any CONFLICT lines, pause and ask the user before proceeding.

## 2. Clone common vaults

```bash
git -C ~/claude-hub submodule update --init --recursive -- vaults/common/
```

If `vaults/common/` has no submodules yet, this is a no-op — that is fine.

## 3. Install plugins

For each plugin listed below, run the install command. If the plugin is already installed, `claude plugin install` will skip it gracefully.

```bash
claude plugin install superpowers@claude-plugins-official
claude plugin install claude-hud@claude-hud
```

## 4. Report summary

Print what was:
- Symlinked (new)
- Replaced (existing symlink)
- Skipped (user chose to skip a conflict)
- Plugins installed / already present
```

- [ ] **Step 2: Symlink the skill so /apply is discoverable**

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

## Task 7: Verify the setup on the current machine

Run `/apply` to confirm it correctly symlinks all agents and installs plugins on this machine (which already has them, so it should show "replaced" and "already installed").

- [ ] **Step 1: Back up current agent symlinks (safety check)**

```bash
ls -la ~/.claude/agents/
```

Note which files are regular files vs symlinks. If any are regular files, decide whether to replace them before proceeding.

- [ ] **Step 2: Run /apply in a Claude Code session**

Invoke `/apply` and confirm the output shows all 7 common agents were symlinked (or replaced if they were already symlinks) and both plugins were present.

- [ ] **Step 3: Verify symlinks point to the hub**

```bash
ls -la ~/.claude/agents/ | grep "claude-hub"
```

Expected: all 7 common agents now symlink into `~/claude-hub/agents/common/`.

- [ ] **Step 4: Final commit with any cleanup**

```bash
git status
# If clean, nothing to do. If there are leftover .gitkeep files to remove, clean them up.
git add -A && git commit -m "chore: finalize claude-hub initial setup" || echo "nothing to commit"
```
