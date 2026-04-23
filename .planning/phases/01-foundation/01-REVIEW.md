---
phase: 01-foundation
reviewed: 2026-04-23T19:52:53Z
depth: standard
files_reviewed: 8
files_reviewed_list:
  - agents/code-contrarian.md
  - agents/code-executor.md
  - agents/code-expansionist.md
  - agents/code-first-principles.md
  - agents/code-outsider.md
  - hooks/patch-settings.js
  - install.sh
  - skills/council-code/SKILL.md
findings:
  critical: 1
  warning: 4
  info: 3
  total: 8
status: issues_found
---

# Phase 01: Code Review Report

**Reviewed:** 2026-04-23T19:52:53Z
**Depth:** standard
**Files Reviewed:** 8
**Status:** issues_found

## Summary

Reviewed the foundation files for the council-code plugin: five advisor persona definitions (markdown), the orchestrator skill definition (markdown), the Node.js settings patcher (`patch-settings.js`), and the shell installer (`install.sh`).

The five advisor persona files (`agents/*.md`) and the orchestrator skill (`SKILL.md`) are well-structured, self-contained, and follow the project's stated design principles. No issues found in those files.

The two executable files -- `patch-settings.js` and `install.sh` -- contain the substantive findings. There is one critical bug (null pointer crash in uninstall path), several missing-validation warnings, and a few informational items including stale documentation references.

## Critical Issues

### CR-01: Null pointer crash in uninstall mode when `--next-file` is not provided

**File:** `hooks/patch-settings.js:116`
**Issue:** In uninstall mode, `nextFile` can be `null` (it is optional per the usage comment on line 13). On line 116, `fs.readFileSync(nextFile, ...)` is called without checking whether `nextFile` is null. Passing `null` to `fs.readFileSync` throws a `TypeError: path must be a string` which crashes the process before the cleaned settings file is written (line 137). The backup has already been written (line 107) but the actual cleanup never completes, leaving settings.json in its original state while the user sees an unhandled exception.

In practice `install.sh` always passes `--next-file`, so this only triggers if `patch-settings.js` is called directly without that flag (which the script's own usage docs permit). Still, the uninstall path crashing on a documented-as-optional argument is a correctness bug.

**Fix:**
```javascript
// Line 115-116: guard nextFile before reading
let restored = '';
if (nextFile) {
  try { restored = fs.readFileSync(nextFile, 'utf8').trim(); } catch (e) {}
}
```

## Warnings

### WR-01: `--statusline` not validated in install mode -- silently writes null into settings.json

**File:** `hooks/patch-settings.js:82`
**Issue:** The comment on line 11 says `--statusline CMD` is "required for --install," but no validation enforces this. If `--install` is run without `--statusline`, `statuslineCmd` is `null`, and line 82 writes `cfg.statusLine.command = null`. This produces a `settings.json` with `"command": null`, which downstream consumers (Claude Code) may not handle gracefully. The same applies to `--hook` (line 30), though line 90 has a partial guard (`if (!already && hookCmd)`).

**Fix:**
```javascript
// Add after line 50 (the !settingsFile check)
if (isInstall && !statuslineCmd) {
  console.error('Error: --statusline CMD is required for --install');
  process.exit(1);
}
```

### WR-02: `argv[i + 1]` can read past the end of the argument array

**File:** `hooks/patch-settings.js:24`
**Issue:** The `get()` helper returns `argv[i + 1]` when a flag is found. If a flag like `--settings` is the last argument (no value following it), `argv[i + 1]` is `undefined`, which the code treats as `null` via the ternary. The script then proceeds with `settingsFile = undefined`, passes the line-47 check (`!settingsFile` is true for undefined), and exits. However, if `--statusline` or `--hook` is the last arg, their undefined values slip through without validation (see WR-01). More subtly, if `--install` appears immediately after `--settings`, the get function returns the string `"--install"` as the settings path.

**Fix:**
```javascript
const get = (flag) => {
  const i = argv.indexOf(flag);
  if (i === -1 || i + 1 >= argv.length) return null;
  const val = argv[i + 1];
  if (val.startsWith('--')) return null;  // next arg is a flag, not a value
  return val;
};
```

### WR-03: Empty catch blocks silently swallow errors

**File:** `hooks/patch-settings.js:62` and `hooks/patch-settings.js:116`
**Issue:** Two `catch (e) {}` blocks silently discard errors. On line 62, if `readFileSync` fails for a reason other than file-not-found (e.g., permission denied on an existing file), the script proceeds with `raw = ''` and overwrites the file with `{}`. On line 116, a permission error reading the next-file is silently ignored, causing the previous statusLine to be lost instead of restored.

**Fix:**
```javascript
// Line 62: distinguish ENOENT from other errors
try { raw = fs.readFileSync(settingsFile, 'utf8'); } catch (e) {
  if (e.code !== 'ENOENT') { console.error(`Cannot read ${settingsFile}: ${e.message}`); process.exit(1); }
}

// Line 116: log non-ENOENT errors so the user knows restoration failed
try { restored = fs.readFileSync(nextFile, 'utf8').trim(); } catch (e) {
  if (e.code !== 'ENOENT') { console.error(`  warning: could not read ${nextFile}: ${e.message}`); }
}
```

### WR-04: `install.sh` does not validate `--install`/`--uninstall` flag conflict forwarding

**File:** `install.sh:28-38`
**Issue:** The argument parser on lines 28-38 accepts multiple mode flags without conflict detection. Running `./install.sh --copy --uninstall` sets `MODE="uninstall"` (last flag wins), which is probably fine, but `./install.sh --uninstall --copy` sets `MODE="copy"` and proceeds with install -- the opposite of what the user asked. The last-flag-wins behavior is a common shell anti-pattern that leads to user confusion.

**Fix:**
```bash
for arg in "$@"; do
  case "$arg" in
    --copy)      [[ "$MODE" != "uninstall" ]] || { err "--copy and --uninstall are mutually exclusive"; exit 2; }; MODE="copy" ;;
    --uninstall) [[ "$MODE" == "symlink" ]] || { err "--uninstall conflicts with --$MODE"; exit 2; }; MODE="uninstall" ;;
    --symlink)   [[ "$MODE" != "uninstall" ]] || { err "--symlink and --uninstall are mutually exclusive"; exit 2; }; MODE="symlink" ;;
    -h|--help)   sed -n '2,17p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *)           echo "Unknown arg: $arg" >&2; exit 2 ;;
  esac
done
```

## Info

### IN-01: CLAUDE.md file tree references stale agent filenames

**File:** `CLAUDE.md:11-15`
**Issue:** The structure listing in `CLAUDE.md` shows the agents as `contrarian.md`, `first-principles.md`, `expansionist.md`, `outsider.md`, `executor.md` (bare names). The actual files on disk are `code-contrarian.md`, `code-executor.md`, etc. (prefixed with `code-`). This was a deliberate rename (the install.sh uninstall path references these as "legacy bare-name agents" on line 134), but CLAUDE.md was not updated to match. This could mislead contributors.

**Fix:** Update the tree in `CLAUDE.md` to show the current filenames:
```
agents/
  code-contrarian.md
  code-first-principles.md
  code-expansionist.md
  code-outsider.md
  code-executor.md
```

### IN-02: `console.log` statements in patch-settings.js

**File:** `hooks/patch-settings.js:78,97,119,122,138`
**Issue:** Five `console.log` calls are present. These are intentional user-facing install/uninstall progress messages (not debug artifacts), so they are appropriate for a CLI tool. Flagging for acknowledgment only -- no action needed.

**Fix:** None required. The console.log calls serve as install-time user feedback.

### IN-03: `err()` helper defined but never called in install.sh

**File:** `install.sh:44`
**Issue:** The `err()` formatting helper is defined on line 44 but never used anywhere in the script. All error output goes through raw `echo` (line 37) or `warn()`. This is minor dead code.

**Fix:** Either remove the unused function or use it for the error message on line 37:
```bash
# Line 37: use err() instead of raw echo
*) err "Unknown arg: $arg"; exit 2 ;;
```

---

_Reviewed: 2026-04-23T19:52:53Z_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
