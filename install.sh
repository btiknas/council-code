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

MODE="symlink"
for arg in "$@"; do
  case "$arg" in
    --copy)      MODE="copy" ;;
    --uninstall) MODE="uninstall" ;;
    --symlink)   MODE="symlink" ;;
    -h|--help)
      sed -n '2,17p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *) echo "Unknown arg: $arg" >&2; exit 2 ;;
  esac
done

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

  local wrapper="$HOOKS_DIR/council-statusline.js"
  local check_hook="$HOOKS_DIR/council-check-update.js"
  local next_file="$HOOKS_DIR/council-statusline-next.txt"

  node - "$SETTINGS_FILE" "$wrapper" "$check_hook" "$next_file" <<'NODE'
const fs = require('fs');
const [file, wrapper, checkHook, nextFile] = process.argv.slice(2);

const wrapperCmd = `node "${wrapper}"`;
const checkCmd = `node "${checkHook}"`;

let raw = '';
try { raw = fs.readFileSync(file, 'utf8'); } catch (e) {}
const backup = `${file}.bak.${Date.now()}`;
if (raw) fs.writeFileSync(backup, raw);

let cfg = {};
try { cfg = JSON.parse(raw || '{}'); } catch (e) {
  console.error(`settings.json is not valid JSON — refusing to patch. Backup at ${backup}`);
  process.exit(1);
}

// 1. statusLine: if a different command is already set, save it for delegation.
cfg.statusLine = cfg.statusLine || { type: 'command', command: '' };
const existing = (cfg.statusLine.command || '').trim();
if (existing && existing !== wrapperCmd) {
  fs.writeFileSync(nextFile, existing + '\n');
  console.log(`  preserved previous statusLine → ${nextFile}`);
}
cfg.statusLine.type = 'command';
cfg.statusLine.command = wrapperCmd;

// 2. SessionStart hook: append ours if not already present.
cfg.hooks = cfg.hooks || {};
cfg.hooks.SessionStart = cfg.hooks.SessionStart || [];
const already = cfg.hooks.SessionStart.some(group =>
  (group.hooks || []).some(h => (h.command || '').includes('council-check-update.js'))
);
if (!already) {
  cfg.hooks.SessionStart.push({
    hooks: [{ type: 'command', command: checkCmd }],
  });
}

fs.writeFileSync(file, JSON.stringify(cfg, null, 2) + '\n');
console.log(`  patched ${file} (backup: ${backup})`);
NODE
}

patch_settings_uninstall() {
  [[ -f "$SETTINGS_FILE" ]] || return 0
  have_node || { warn "node not found — settings.json left as-is, remove hooks manually"; return 0; }

  local next_file="$HOOKS_DIR/council-statusline-next.txt"
  node - "$SETTINGS_FILE" "$next_file" <<'NODE'
const fs = require('fs');
const [file, nextFile] = process.argv.slice(2);

let raw = '';
try { raw = fs.readFileSync(file, 'utf8'); } catch (e) { process.exit(0); }
const backup = `${file}.bak.${Date.now()}`;
fs.writeFileSync(backup, raw);

let cfg;
try { cfg = JSON.parse(raw); } catch (e) { console.error('settings.json invalid; not touched'); process.exit(0); }

// Restore previous statusLine if we saved one; otherwise remove ours.
if (cfg.statusLine && typeof cfg.statusLine.command === 'string' &&
    cfg.statusLine.command.includes('council-statusline.js')) {
  let restored = '';
  try { restored = fs.readFileSync(nextFile, 'utf8').trim(); } catch (e) {}
  if (restored) {
    cfg.statusLine.command = restored;
    console.log(`  restored previous statusLine`);
  } else {
    delete cfg.statusLine;
    console.log(`  removed statusLine`);
  }
}

// Remove our SessionStart entry.
if (cfg.hooks && Array.isArray(cfg.hooks.SessionStart)) {
  cfg.hooks.SessionStart = cfg.hooks.SessionStart
    .map(group => ({
      ...group,
      hooks: (group.hooks || []).filter(h => !(h.command || '').includes('council-check-update.js')),
    }))
    .filter(group => (group.hooks || []).length > 0);
  if (cfg.hooks.SessionStart.length === 0) delete cfg.hooks.SessionStart;
}

fs.writeFileSync(file, JSON.stringify(cfg, null, 2) + '\n');
console.log(`  cleaned ${file} (backup: ${backup})`);
NODE

  [[ -f "$next_file" ]] && rm -f "$HOOKS_DIR/council-statusline-next.txt"
}

# --- main --------------------------------------------------------------------

echo "council-code installer"
echo "  repo:   $REPO_ROOT"
echo "  target: $CLAUDE_DIR"
echo "  mode:   $MODE"
echo

SKILLS=( council-code council-update )
PERSONAS=( contrarian first-principles expansionist outsider executor )
HOOKS=( council-statusline.js council-check-update.js council-check-update-worker.js )

if [[ "$MODE" == "uninstall" ]]; then
  patch_settings_uninstall
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
