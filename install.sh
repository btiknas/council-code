#!/usr/bin/env bash
# council-code — user-level installer
#
# Installs the skill and personas into ~/.claude/ so they appear as
# bare slash commands (/council-code) without the plugin namespace.
#
# Re-runnable: idempotent. Existing non-symlink files are backed up to *.bak.
#
# Usage:
#   ./install.sh              # symlink (default, recommended — updates via git pull)
#   ./install.sh --copy       # copy files instead of symlinking
#   ./install.sh --uninstall  # remove installed symlinks/files

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_HOME:-$HOME/.claude}"
SKILLS_DIR="$CLAUDE_DIR/skills"
AGENTS_DIR="$CLAUDE_DIR/agents"

MODE="symlink"
for arg in "$@"; do
  case "$arg" in
    --copy)      MODE="copy" ;;
    --uninstall) MODE="uninstall" ;;
    --symlink)   MODE="symlink" ;;
    -h|--help)
      sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *) echo "Unknown arg: $arg" >&2; exit 2 ;;
  esac
done

say() { printf '  %s\n' "$*"; }
ok()  { printf '  \033[32m✓\033[0m %s\n' "$*"; }
warn(){ printf '  \033[33m!\033[0m %s\n' "$*"; }

backup_if_real() {
  local target="$1"
  if [[ -e "$target" && ! -L "$target" ]]; then
    mv "$target" "$target.bak.$(date +%Y%m%d%H%M%S)"
    warn "existing $target moved to .bak"
  fi
}

install_link() {
  local src="$1" dst="$2"
  backup_if_real "$dst"
  [[ -L "$dst" ]] && rm "$dst"
  ln -s "$src" "$dst"
  ok "linked $dst → $src"
}

install_copy() {
  local src="$1" dst="$2"
  backup_if_real "$dst"
  [[ -L "$dst" ]] && rm "$dst"
  if [[ -d "$src" ]]; then
    cp -R "$src" "$dst"
  else
    cp "$src" "$dst"
  fi
  ok "copied $src → $dst"
}

remove_target() {
  local target="$1"
  if [[ -L "$target" || -e "$target" ]]; then
    rm -rf "$target"
    ok "removed $target"
  fi
}

echo "council-code installer"
echo "  repo:   $REPO_ROOT"
echo "  target: $CLAUDE_DIR"
echo "  mode:   $MODE"
echo

SKILLS=( council-code council-update )
PERSONAS=( contrarian first-principles expansionist outsider executor )

if [[ "$MODE" == "uninstall" ]]; then
  for skill in "${SKILLS[@]}"; do
    remove_target "$SKILLS_DIR/$skill"
  done
  for persona in "${PERSONAS[@]}"; do
    remove_target "$AGENTS_DIR/$persona.md"
  done
  echo
  ok "uninstalled. Restart Claude Code to refresh."
  exit 0
fi

mkdir -p "$SKILLS_DIR" "$AGENTS_DIR"

if [[ "$MODE" == "symlink" ]]; then
  for skill in "${SKILLS[@]}"; do
    install_link "$REPO_ROOT/skills/$skill" "$SKILLS_DIR/$skill"
  done
  for persona in "${PERSONAS[@]}"; do
    install_link "$REPO_ROOT/agents/$persona.md" "$AGENTS_DIR/$persona.md"
  done
else
  for skill in "${SKILLS[@]}"; do
    install_copy "$REPO_ROOT/skills/$skill" "$SKILLS_DIR/$skill"
  done
  for persona in "${PERSONAS[@]}"; do
    install_copy "$REPO_ROOT/agents/$persona.md" "$AGENTS_DIR/$persona.md"
  done
fi

echo
ok "done. Restart Claude Code, then try: /council-code (update check: /council-update)"
if [[ "$MODE" == "symlink" ]]; then
  say "Updates: /council-update  — or: git pull in this repo"
else
  say "Updates: git pull, then re-run ./install.sh --copy."
fi
