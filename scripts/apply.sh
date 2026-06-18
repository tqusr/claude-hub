#!/usr/bin/env bash
set -euo pipefail

HUB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGENTS_SRC="$HUB_DIR/common/agents"
AGENTS_DST="$HOME/.claude/agents"

new=()
replaced=()
skipped=()
conflicts=()

# ---------------------------------------------------------------------------
# 1. Symlink common agents
# ---------------------------------------------------------------------------

mkdir -p "$AGENTS_DST"

for f in "$AGENTS_SRC"/*.md; do
  [ -e "$f" ] || continue
  name="$(basename "$f")"
  target="$AGENTS_DST/$name"

  if [ -L "$target" ]; then
    ln -sf "$f" "$target"
    replaced+=("$name")
  elif [ -f "$target" ]; then
    conflicts+=("$name:$f")
  else
    ln -s "$f" "$target"
    new+=("$name")
  fi
done

# Handle conflicts interactively
for entry in "${conflicts[@]+"${conflicts[@]}"}"; do
  name="${entry%%:*}"
  src="${entry#*:}"
  target="$AGENTS_DST/$name"
  echo ""
  echo "CONFLICT: ~/.claude/agents/$name is a regular file, not a symlink."
  read -r -p "Replace with symlink? [y/N] " answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    ln -sf "$src" "$target"
    replaced+=("$name (was conflict, now replaced)")
  else
    skipped+=("$name")
  fi
done

# ---------------------------------------------------------------------------
# 2. Apply _claude.md files
# ---------------------------------------------------------------------------

claude_md_applied=()
claude_md_skipped=()

apply_claude_md() {
  local src="$1"
  local dst="$2"
  local label="$3"

  [ -f "$src" ] || return 0

  echo ""
  echo "_claude.md found for $label"
  echo "  Source: $src"
  echo "  Target: $dst"
  echo ""
  echo "  [c] Copy/override  — replace target with this file"
  echo "  [r] Reference      — prepend a pointer in the existing target"
  echo "  [s] Skip"
  read -r -p "  Choice [c/r/s]: " choice

  case "$choice" in
    [Cc])
      mkdir -p "$(dirname "$dst")"
      cp "$src" "$dst"
      claude_md_applied+=("$label (copied)")
      ;;
    [Rr])
      mkdir -p "$(dirname "$dst")"
      if grep -qF "$src" "$dst" 2>/dev/null; then
        claude_md_skipped+=("$label (reference already present)")
      else
        local tmp
        tmp=$(mktemp)
        {
          printf '> **Important:** Also read `%s` for important instructions.\n\n' "$src"
          [ -f "$dst" ] && cat "$dst" || true
        } > "$tmp"
        mv "$tmp" "$dst"
        claude_md_applied+=("$label (referenced)")
      fi
      ;;
    *)
      claude_md_skipped+=("$label")
      ;;
  esac
}

# Common: common/_claude.md → ~/.claude/CLAUDE.md
apply_claude_md "$HUB_DIR/common/_claude.md" "$HOME/.claude/CLAUDE.md" "global (~/.claude/CLAUDE.md)"

# Projects: projects/<name>/_claude.md → <project-root>/CLAUDE.md
for proj_dir in "$HUB_DIR/projects"/*/; do
  [ -d "$proj_dir" ] || continue
  src="${proj_dir}_claude.md"
  [ -f "$src" ] || continue
  proj_name="$(basename "$proj_dir")"
  echo ""
  read -r -p "Project '$proj_name': enter project root path [default: $HOME/$proj_name]: " proj_root
  proj_root="${proj_root:-$HOME/$proj_name}"
  apply_claude_md "$src" "$proj_root/CLAUDE.md" "project $proj_name ($proj_root/CLAUDE.md)"
done

# ---------------------------------------------------------------------------
# 3. Install plugins
# ---------------------------------------------------------------------------

plugins_installed=()
plugins_present=()
plugins_failed=()

ensure_marketplace() {
  local source="$1"
  local name="$2"
  if ! claude plugin marketplace list 2>&1 | grep -q "^  ❯ $name"; then
    claude plugin marketplace add "$source" 2>&1 || true
  fi
}

install_plugin() {
  local spec="$1"
  local name="${spec%%@*}"
  if claude plugin list 2>&1 | grep -q "❯ $name@"; then
    plugins_present+=("$name")
    return
  fi
  local output exit_code=0
  output=$(claude plugin install "$spec" 2>&1) || exit_code=$?
  if [ $exit_code -ne 0 ]; then
    plugins_failed+=("$name")
  else
    plugins_installed+=("$name")
  fi
}

reload_plugins() {
  claude reload-plugins 2>&1 || true
}

ensure_marketplace "jarrodwatts/claude-hud" "claude-hud"

install_plugin "superpowers@claude-plugins-official"
install_plugin "claude-hud@claude-hud"

# ---------------------------------------------------------------------------
# 4. Summary
# ---------------------------------------------------------------------------

echo ""
echo "=== apply summary ==="

if [ ${#new[@]} -gt 0 ]; then
  echo ""
  echo "Symlinked (new):"
  for n in "${new[@]}"; do echo "  + $n"; done
fi

if [ ${#replaced[@]} -gt 0 ]; then
  echo ""
  echo "Replaced (updated symlink):"
  for n in "${replaced[@]}"; do echo "  ~ $n"; done
fi

if [ ${#skipped[@]} -gt 0 ]; then
  echo ""
  echo "Skipped (conflict, kept original):"
  for n in "${skipped[@]}"; do echo "  - $n"; done
fi

if [ ${#plugins_installed[@]} -gt 0 ]; then
  echo ""
  echo "Plugins installed:"
  for n in "${plugins_installed[@]}"; do echo "  + $n"; done
fi

if [ ${#plugins_present[@]} -gt 0 ]; then
  echo ""
  echo "Plugins already present:"
  for n in "${plugins_present[@]}"; do echo "  = $n"; done
fi

if [ ${#plugins_failed[@]} -gt 0 ]; then
  echo ""
  echo "Plugins FAILED to install:"
  for n in "${plugins_failed[@]}"; do echo "  ! $n"; done
fi

if [ ${#claude_md_applied[@]} -gt 0 ]; then
  echo ""
  echo "CLAUDE.md applied:"
  for n in "${claude_md_applied[@]}"; do echo "  + $n"; done
fi

if [ ${#claude_md_skipped[@]} -gt 0 ]; then
  echo ""
  echo "CLAUDE.md skipped:"
  for n in "${claude_md_skipped[@]}"; do echo "  - $n"; done
fi

echo ""
echo "Done."
