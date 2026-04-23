---
phase: 01-foundation
fixed_at: 2026-04-23T20:06:11Z
review_path: .planning/phases/01-foundation/01-REVIEW.md
iteration: 1
findings_in_scope: 5
fixed: 5
skipped: 0
status: all_fixed
---

# Phase 01: Code Review Fix Report

**Fixed at:** 2026-04-23T20:06:11Z
**Source review:** .planning/phases/01-foundation/01-REVIEW.md
**Iteration:** 1

**Summary:**
- Findings in scope: 5
- Fixed: 5
- Skipped: 0

## Fixed Issues

### CR-01: Null pointer crash in uninstall mode when `--next-file` is not provided

**Files modified:** `hooks/patch-settings.js`
**Commit:** a62cfac
**Applied fix:** Added `if (nextFile)` guard around `fs.readFileSync(nextFile, ...)` in the uninstall path (line 127). When `nextFile` is null, the code now skips the read entirely and falls through to the `delete cfg.statusLine` branch, which is the correct behavior when no previous statusLine was saved.

### WR-01: `--statusline` not validated in install mode -- silently writes null into settings.json

**Files modified:** `hooks/patch-settings.js`
**Commit:** 8483850
**Applied fix:** Added validation block after the `--settings` required check: if `isInstall` is true and `statuslineCmd` is null, the script now prints an error message and exits with code 1. This enforces the documented requirement that `--statusline CMD` is required for `--install` mode.

### WR-02: `argv[i + 1]` can read past the end of the argument array

**Files modified:** `hooks/patch-settings.js`
**Commit:** adc1adf
**Applied fix:** Replaced the one-liner `get()` helper with a multi-line version that: (1) returns null if the flag index is at the end of argv (bounds check), and (2) returns null if the next argument starts with `--` (prevents treating a subsequent flag as a value). This prevents `undefined` values from leaking through and stops adjacent flags from being misinterpreted as values.

### WR-03: Empty catch blocks silently swallow errors

**Files modified:** `hooks/patch-settings.js`
**Commit:** 52e389b
**Applied fix:** Updated two empty `catch (e) {}` blocks to distinguish `ENOENT` (file not found, expected) from other errors (permission denied, etc.). In install mode (line 73), non-ENOENT errors now print a message and exit with code 1. In uninstall mode (line 130), non-ENOENT errors now print a warning so the user knows restoration could not complete, but the script continues to allow the rest of the uninstall to proceed.

### WR-04: `install.sh` does not validate `--install`/`--uninstall` flag conflict forwarding

**Files modified:** `install.sh`
**Commit:** 12c80c2
**Applied fix:** Replaced last-flag-wins behavior with explicit conflict detection. MODE starts as empty string. Each mode flag (`--copy`, `--uninstall`, `--symlink`) checks whether MODE is unset or already set to the same value; if a different mode was already set, the script prints a conflict error and exits with code 2. After the loop, `MODE` defaults to `symlink` via parameter expansion (`${MODE:-symlink}`). The `err()` helper was not used because it is defined after the argument parsing loop.

---

_Fixed: 2026-04-23T20:06:11Z_
_Fixer: Claude (gsd-code-fixer)_
_Iteration: 1_
