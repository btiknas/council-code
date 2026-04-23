#!/usr/bin/env node
// council-code — settings.json patcher
//
// Extracted from install.sh. Called by install.sh and future council installers.
// Usage: node patch-settings.js --install|--uninstall --settings PATH [--statusline CMD] [--hook CMD] [--next-file PATH]
//
// Flags:
//   --install              Run install mode (set statusLine, add SessionStart hook)
//   --uninstall            Run uninstall mode (restore/remove statusLine, remove SessionStart hook)
//   --settings  PATH       Path to settings.json to patch (required)
//   --statusline CMD       Command to set as statusLine.command (required for --install)
//   --hook      CMD        Command to add to SessionStart hooks (required for --install)
//   --next-file PATH       File to save/restore previous statusLine command (optional)

'use strict';

const fs = require('fs');
const path = require('path');

// ---------------------------------------------------------------------------
// argv parsing (manual scan, no npm deps)
// ---------------------------------------------------------------------------
const argv = process.argv.slice(2);
const get = (flag) => {
  const i = argv.indexOf(flag);
  if (i === -1 || i + 1 >= argv.length) return null;
  const val = argv[i + 1];
  if (val.startsWith('--')) return null;  // next arg is a flag, not a value
  return val;
};
const has = (flag) => argv.includes(flag);

const settingsFile  = get('--settings');
const nextFile      = get('--next-file');
const statuslineCmd = get('--statusline');
const hookCmd       = get('--hook');
const isInstall     = has('--install');
const isUninstall   = has('--uninstall');

// ---------------------------------------------------------------------------
// Validation
// ---------------------------------------------------------------------------
if (isInstall && isUninstall) {
  console.error('Error: --install and --uninstall are mutually exclusive');
  process.exit(1);
}

if (!isInstall && !isUninstall) {
  console.error('Usage: node patch-settings.js --install|--uninstall --settings PATH [--statusline CMD] [--hook CMD] [--next-file PATH]');
  process.exit(1);
}

if (!settingsFile) {
  console.error('Error: --settings PATH is required');
  process.exit(1);
}

// ---------------------------------------------------------------------------
// Install mode
// ---------------------------------------------------------------------------
if (isInstall) {
  // Ensure settings file exists
  if (!fs.existsSync(settingsFile)) {
    fs.writeFileSync(settingsFile, '{}\n');
  }

  let raw = '';
  try { raw = fs.readFileSync(settingsFile, 'utf8'); } catch (e) {}
  const backup = `${settingsFile}.bak.${Date.now()}`;
  if (raw) fs.writeFileSync(backup, raw);

  let cfg = {};
  try { cfg = JSON.parse(raw || '{}'); } catch (e) {
    console.error(`settings.json is not valid JSON — refusing to patch. Backup at ${backup}`);
    process.exit(1);
  }

  // 1. statusLine: if a different command is already set, save it for delegation.
  cfg.statusLine = cfg.statusLine || { type: 'command', command: '' };
  const existing = (cfg.statusLine.command || '').trim();
  if (existing && existing !== statuslineCmd) {
    if (nextFile) {
      fs.writeFileSync(nextFile, existing + '\n');
      console.log(`  preserved previous statusLine -> ${nextFile}`);
    }
  }
  cfg.statusLine.type = 'command';
  cfg.statusLine.command = statuslineCmd;

  // 2. SessionStart hook: append ours if not already present.
  cfg.hooks = cfg.hooks || {};
  cfg.hooks.SessionStart = cfg.hooks.SessionStart || [];
  const already = cfg.hooks.SessionStart.some(group =>
    (group.hooks || []).some(h => (h.command || '').includes('council-check-update.js'))
  );
  if (!already && hookCmd) {
    cfg.hooks.SessionStart.push({
      hooks: [{ type: 'command', command: hookCmd }],
    });
  }

  fs.writeFileSync(settingsFile, JSON.stringify(cfg, null, 2) + '\n');
  console.log(`  patched ${settingsFile} (backup: ${backup})`);
}

// ---------------------------------------------------------------------------
// Uninstall mode
// ---------------------------------------------------------------------------
if (isUninstall) {
  let raw = '';
  try { raw = fs.readFileSync(settingsFile, 'utf8'); } catch (e) { process.exit(0); }
  const backup = `${settingsFile}.bak.${Date.now()}`;
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

  fs.writeFileSync(settingsFile, JSON.stringify(cfg, null, 2) + '\n');
  console.log(`  cleaned ${settingsFile} (backup: ${backup})`);
}
