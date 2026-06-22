#!/usr/bin/env bash
set -euo pipefail

# Usage: bash apply_project.sh <project-name> <project-root>
# Example: bash apply_project.sh cve-patcher /home/albin/my-yocto-project

HUB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <project-name> <project-root>" >&2
  exit 1
fi

PROJECT_NAME="$1"
PROJECT_ROOT="$2"
PROJECT_DIR="$HUB_DIR/projects/$PROJECT_NAME"

if [[ ! -d "$PROJECT_DIR" ]]; then
  echo "ERROR: Project '$PROJECT_NAME' not found at $PROJECT_DIR" >&2
  exit 1
fi

AGENTS_DST="$HOME/.claude/agents"
SKILLS_DST="$HOME/.claude/skills"

agents_new=()
agents_replaced=()
skills_new=()
skills_replaced=()
claude_md_applied=()
claude_md_skipped=()

# ---------------------------------------------------------------------------
# 1. Symlink project agents → ~/.claude/agents/<project>--<agent>.md
# ---------------------------------------------------------------------------

mkdir -p "$AGENTS_DST"

AGENTS_SRC="$PROJECT_DIR/agents"
if [[ -d "$AGENTS_SRC" ]] && compgen -G "$AGENTS_SRC/*.md" > /dev/null 2>&1; then
  for f in "$AGENTS_SRC"/*.md; do
    [[ -e "$f" ]] || continue
    name="${PROJECT_NAME}--$(basename "$f")"
    target="$AGENTS_DST/$name"
    if [[ -L "$target" ]]; then
      ln -sf "$f" "$target"
      agents_replaced+=("$name")
    else
      ln -s "$f" "$target"
      agents_new+=("$name")
    fi
  done
else
  echo "(no agents/*.md files — skipping agent symlinks)"
fi

# ---------------------------------------------------------------------------
# 2. Symlink project skills → ~/.claude/skills/<skill>.md
# ---------------------------------------------------------------------------

mkdir -p "$SKILLS_DST"

SKILLS_SRC="$PROJECT_DIR/skills"
# Skills are directories containing SKILL.md (e.g. skills/patch-cves/SKILL.md)
if [[ -d "$SKILLS_SRC" ]]; then
  found_skills=0
  for d in "$SKILLS_SRC"/*/; do
    [[ -d "$d" ]] || continue
    [[ -f "$d/SKILL.md" ]] || continue
    found_skills=1
    name="$(basename "$d")"
    target="$SKILLS_DST/$name"
    if [[ -L "$target" || -d "$target" ]]; then
      rm -f "$target"
      ln -s "$d" "$target"
      skills_replaced+=("$name")
    else
      ln -s "$d" "$target"
      skills_new+=("$name")
    fi
  done
  [[ $found_skills -eq 0 ]] && echo "(no skills/<name>/SKILL.md found — skipping skill symlinks)"
else
  echo "(no skills/ directory — skipping skill symlinks)"
fi

# ---------------------------------------------------------------------------
# 3. Handle _claude.md → <project-root>/CLAUDE.md
# ---------------------------------------------------------------------------

CLAUDE_MD_SRC="$PROJECT_DIR/_claude.md"
CLAUDE_MD_DST="$PROJECT_ROOT/CLAUDE.md"

if [[ -f "$CLAUDE_MD_SRC" ]]; then
  echo ""
  echo "_claude.md found for project '$PROJECT_NAME'"
  echo "  Source: $CLAUDE_MD_SRC"
  echo "  Target: $CLAUDE_MD_DST"
  echo ""
  echo "  [c] Copy/override  — replace target with this file"
  echo "  [r] Reference      — prepend a pointer in the existing target"
  echo "  [s] Skip"
  read -r -p "  Choice [c/r/s]: " choice

  case "$choice" in
    [Cc])
      mkdir -p "$(dirname "$CLAUDE_MD_DST")"
      cp "$CLAUDE_MD_SRC" "$CLAUDE_MD_DST"
      claude_md_applied+=("copied to $CLAUDE_MD_DST")
      ;;
    [Rr])
      mkdir -p "$(dirname "$CLAUDE_MD_DST")"
      if grep -qF "$CLAUDE_MD_SRC" "$CLAUDE_MD_DST" 2>/dev/null; then
        claude_md_skipped+=("reference already present in $CLAUDE_MD_DST")
      else
        tmp=$(mktemp)
        {
          printf '> **Important:** Also read `%s` for project-specific CVE patching instructions.\n\n' "$CLAUDE_MD_SRC"
          [[ -f "$CLAUDE_MD_DST" ]] && cat "$CLAUDE_MD_DST" || true
        } > "$tmp"
        mv "$tmp" "$CLAUDE_MD_DST"
        claude_md_applied+=("referenced in $CLAUDE_MD_DST")
      fi
      ;;
    *)
      claude_md_skipped+=("$CLAUDE_MD_DST")
      ;;
  esac
else
  echo "(no _claude.md found — skipping)"
fi

# ---------------------------------------------------------------------------
# 4. Summary
# ---------------------------------------------------------------------------

echo ""
echo "=== apply_project summary: $PROJECT_NAME ==="

[[ ${#agents_new[@]} -gt 0 ]]      && { echo ""; echo "Agents symlinked (new):";      for n in "${agents_new[@]}";      do echo "  + $n"; done; }
[[ ${#agents_replaced[@]} -gt 0 ]] && { echo ""; echo "Agents symlinked (updated):";  for n in "${agents_replaced[@]}"; do echo "  ~ $n"; done; }
[[ ${#skills_new[@]} -gt 0 ]]      && { echo ""; echo "Skills symlinked (new):";      for n in "${skills_new[@]}";      do echo "  + $n"; done; }
[[ ${#skills_replaced[@]} -gt 0 ]] && { echo ""; echo "Skills symlinked (updated):";  for n in "${skills_replaced[@]}"; do echo "  ~ $n"; done; }
[[ ${#claude_md_applied[@]} -gt 0 ]] && { echo ""; echo "CLAUDE.md applied:"; for n in "${claude_md_applied[@]}"; do echo "  + $n"; done; }
[[ ${#claude_md_skipped[@]} -gt 0 ]] && { echo ""; echo "CLAUDE.md skipped:"; for n in "${claude_md_skipped[@]}"; do echo "  - $n"; done; }

echo ""
echo "Done."
