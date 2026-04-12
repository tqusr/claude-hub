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
