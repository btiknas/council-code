#!/usr/bin/env bash
# council-code — user-level installer
#
# Installs the skill, personas, update-check hook, and statusline wrapper
# into ~/.claude/ so /council-code and /council-update work without the
# plugin namespace, and the statusline shows `⬆ /council-update` when
# a new version is on origin/main.
#
# Re-runnable and idempotent. Existing non-symlink files are backed up.
# A pre-existing statusLine command (e.g. GSD's) is preserved — our
# wrapper delegates to it and appends its output after the council badge.
#
# Usage:
#   ./install.sh              # symlink (default, recommended — git pull to update)
#   ./install.sh --copy       # copy files instead of symlinking
#   ./install.sh --uninstall  # remove everything we installed, restore previous statusLine

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_HOME:-$HOME/.claude}"
SKILLS_DIR="$CLAUDE_DIR/skills"
AGENTS_DIR="$CLAUDE_DIR/agents"
HOOKS_DIR="$CLAUDE_DIR/hooks"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"

MODE=""
for arg in "$@"; do
  case "$arg" in
    --copy)
      [[ -z "$MODE" || "$MODE" == "copy" ]] || { echo "Error: --copy conflicts with --$MODE" >&2; exit 2; }
      MODE="copy" ;;
    --uninstall)
      [[ -z "$MODE" || "$MODE" == "uninstall" ]] || { echo "Error: --uninstall conflicts with --$MODE" >&2; exit 2; }
      MODE="uninstall" ;;
    --symlink)
      [[ -z "$MODE" || "$MODE" == "symlink" ]] || { echo "Error: --symlink conflicts with --$MODE" >&2; exit 2; }
      MODE="symlink" ;;
    -h|--help)
      sed -n '2,17p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *) echo "Unknown arg: $arg" >&2; exit 2 ;;
  esac
done
MODE="${MODE:-symlink}"

say() { printf '  %s\n' "$*"; }
ok()  { printf '  \033[32m✓\033[0m %s\n' "$*"; }
warn(){ printf '  \033[33m!\033[0m %s\n' "$*"; }
err() { printf '  \033[31m✗\033[0m %s\n' "$*" >&2; }

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

have_node() {
  command -v node >/dev/null 2>&1
}

# --- settings.json patching --------------------------------------------------
#
# Two responsibilities:
#   1. Wire our statusLine wrapper, saving any pre-existing statusLine command
#      to hooks/council-statusline-next.txt so the wrapper can delegate to it.
#   2. Add our SessionStart hook for the update check (append, don't replace
#      the whole SessionStart array — GSD and others may have entries there).
#
# Implemented in node for safe JSON handling. Always writes a timestamped
# backup of settings.json before mutating.

patch_settings_install() {
  [[ -f "$SETTINGS_FILE" ]] || { echo '{}' > "$SETTINGS_FILE"; }
  have_node || { warn "node not found — skipping settings.json patch (statusline + SessionStart hook will NOT be wired)"; return 0; }
  node "$REPO_ROOT/hooks/patch-settings.js" \
    --settings "$SETTINGS_FILE" \
    --install \
    --statusline "node \"$HOOKS_DIR/council-statusline.js\"" \
    --hook "node \"$HOOKS_DIR/council-check-update.js\"" \
    --next-file "$HOOKS_DIR/council-statusline-next.txt"
}

patch_settings_uninstall() {
  [[ -f "$SETTINGS_FILE" ]] || return 0
  have_node || { warn "node not found — settings.json left as-is, remove hooks manually"; return 0; }
  node "$REPO_ROOT/hooks/patch-settings.js" \
    --settings "$SETTINGS_FILE" \
    --uninstall \
    --next-file "$HOOKS_DIR/council-statusline-next.txt"
}

# --- main --------------------------------------------------------------------

echo "council-code installer"
echo "  repo:   $REPO_ROOT"
echo "  target: $CLAUDE_DIR"
echo "  mode:   $MODE"
echo

SKILLS=( council-code council-update )
PERSONAS=( code-contrarian code-first-principles code-expansionist code-outsider code-executor )
HOOKS=( council-statusline.js council-check-update.js council-check-update-worker.js patch-settings.js )

if [[ "$MODE" == "uninstall" ]]; then
  patch_settings_uninstall

  # Remove legacy bare-name agents (for users who installed pre-rename, per D-03)
  LEGACY_PERSONAS=( contrarian first-principles expansionist outsider executor )
  for persona in "${LEGACY_PERSONAS[@]}"; do
    remove_target "$AGENTS_DIR/$persona.md"
  done

  for skill in "${SKILLS[@]}"; do
    remove_target "$SKILLS_DIR/$skill"
  done
  for persona in "${PERSONAS[@]}"; do
    remove_target "$AGENTS_DIR/$persona.md"
  done
  for hook in "${HOOKS[@]}"; do
    remove_target "$HOOKS_DIR/$hook"
  done
  remove_target "$HOME/.cache/council-code/update-check.json"
  echo
  ok "uninstalled. Restart Claude Code to refresh."
  exit 0
fi

mkdir -p "$SKILLS_DIR" "$AGENTS_DIR" "$HOOKS_DIR"

if [[ "$MODE" == "symlink" ]]; then
  for skill in "${SKILLS[@]}"; do
    install_link "$REPO_ROOT/skills/$skill" "$SKILLS_DIR/$skill"
  done
  for persona in "${PERSONAS[@]}"; do
    install_link "$REPO_ROOT/agents/$persona.md" "$AGENTS_DIR/$persona.md"
  done
  for hook in "${HOOKS[@]}"; do
    install_link "$REPO_ROOT/hooks/$hook" "$HOOKS_DIR/$hook"
  done
else
  for skill in "${SKILLS[@]}"; do
    install_copy "$REPO_ROOT/skills/$skill" "$SKILLS_DIR/$skill"
  done
  for persona in "${PERSONAS[@]}"; do
    install_copy "$REPO_ROOT/agents/$persona.md" "$AGENTS_DIR/$persona.md"
  done
  for hook in "${HOOKS[@]}"; do
    install_copy "$REPO_ROOT/hooks/$hook" "$HOOKS_DIR/$hook"
  done
fi

patch_settings_install

echo
ok "done. Restart Claude Code, then try: /council-code"
say "Update indicator: the statusline shows ⬆ /council-update when origin/main is ahead."
if [[ "$MODE" == "symlink" ]]; then
  say "Updates: /council-update  — or: git pull in this repo"
else
  say "Updates: git pull, then re-run ./install.sh --copy."
fi
