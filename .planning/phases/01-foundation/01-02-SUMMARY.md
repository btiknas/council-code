---
phase: 01-foundation
plan: 02
status: complete
started: 2026-04-23T20:00:00Z
completed: 2026-04-23T20:05:00Z
duration_minutes: 5
---

## What Was Built

Standalone `hooks/patch-settings.js` CLI tool extracted from the inline Node.js heredoc in `install.sh`. Supports `--install` and `--uninstall` modes with flag-driven interface for settings.json mutations.

### Key Decisions

- Manual argv parsing (no npm dependencies) — stdlib only (fs, path)
- Idempotent SessionStart append keyed on `council-check-update.js` string
- Delegation chain preserved via `--next-file` for statusLine handoff
- Backup-before-mutate with timestamped `.bak` suffix

### Requirements Addressed

- FOUND-02: Extracted settings patcher as reusable foundation for multi-council installers

## Self-Check: PASSED

- [x] `node --check hooks/patch-settings.js` exits 0
- [x] Running without args prints usage and exits non-zero
- [x] File is executable with `#!/usr/bin/env node` shebang
- [x] Uses only Node.js stdlib (fs, path) — zero npm dependencies
- [x] Contains idempotent check string `council-check-update.js`
- [x] Contains statusLine detection string `council-statusline.js`
- [x] Install mode: backs up, sets statusLine, preserves delegation chain, appends SessionStart idempotently
- [x] Uninstall mode: backs up, restores/removes statusLine, removes SessionStart entry
- [x] Double-install produces exactly 1 SessionStart entry (idempotent)

## Key Files

key-files:
  created:
    - hooks/patch-settings.js (139 lines — standalone settings.json patcher CLI)

## Deviations

None.

## Commits

- `b5b9f89`: feat(01-02): create hooks/patch-settings.js standalone CLI tool
