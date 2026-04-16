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
# 2. Install plugins
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
# 3. Summary
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

echo ""
echo "Done."
