---
phase: 01-foundation
verified: 2026-04-23T21:00:00Z
status: human_needed
score: 4/4
overrides_applied: 0
human_verification:
  - test: "Run ./install.sh and verify code-prefixed agents appear in ~/.claude/agents/"
    expected: "5 code-*.md files symlinked, no bare-name files"
    why_human: "Requires filesystem side effects in user home directory and a running Claude Code environment"
  - test: "Type /council-code in a new Claude Code session after install"
    expected: "Council skill triggers and runs 5 advisors as before the rename"
    why_human: "Trigger phrase resolution is a Claude Code runtime behavior that cannot be verified statically"
  - test: "Run ./install.sh --uninstall after installing from a pre-rename state"
    expected: "Both old bare-name and new code-prefixed agent files removed from ~/.claude/agents/"
    why_human: "Requires pre-rename installation state that no longer exists in this repo"
---

# Phase 1: Foundation Verification Report

**Phase Goal:** The codebase is safe to extend with new councils -- no namespace collisions, no install fragility, backward compatibility preserved
**Verified:** 2026-04-23T21:00:00Z
**Status:** human_needed
**Re-verification:** No -- initial verification

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | Existing `/council-code` and `/council` triggers invoke the code council identically to before the rename | VERIFIED | `name: council-code` preserved at SKILL.md line 2; description and trigger phrases unchanged; all 6 agent path references updated to code-prefixed versions |
| 2 | All code council agent files carry `code-` prefix and no bare-name files remain in agents directory | VERIFIED | `ls agents/` shows exactly 5 files: code-contrarian.md, code-executor.md, code-expansionist.md, code-first-principles.md, code-outsider.md; `ls agents/ \| grep -v '^code-'` returns empty |
| 3 | Settings.json patching is performed by a standalone `hooks/patch-settings.js` script callable by any council installer, not inline in install.sh | VERIFIED | hooks/patch-settings.js exists (139 lines), executable, valid syntax; install.sh contains exactly 2 `node.*patch-settings.js` calls (install + uninstall); no `node -` heredoc or `<<'NODE'` patterns remain |
| 4 | All council SKILL.md orchestrators include `disable-model-invocation: true` frontmatter and do not auto-load into context | VERIFIED | skills/council-code/SKILL.md line 4: `disable-model-invocation: true` |

**Score:** 4/4 truths verified

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `agents/code-contrarian.md` | Renamed contrarian agent with `name: code-contrarian` | VERIFIED | 54 lines, `name: code-contrarian` at line 2, description and tools unchanged |
| `agents/code-first-principles.md` | Renamed first-principles agent | VERIFIED | 58 lines, `name: code-first-principles` at line 2 |
| `agents/code-expansionist.md` | Renamed expansionist agent | VERIFIED | 57 lines, `name: code-expansionist` at line 2 |
| `agents/code-outsider.md` | Renamed outsider agent | VERIFIED | 57 lines, `name: code-outsider` at line 2 |
| `agents/code-executor.md` | Renamed executor agent | VERIFIED | 61 lines, `name: code-executor` at line 2 |
| `skills/council-code/SKILL.md` | Updated orchestrator with code-prefixed refs and disable-model-invocation | VERIFIED | 115 lines, `disable-model-invocation: true` present, 6 code-prefixed agent references, zero bare-name references |
| `hooks/patch-settings.js` | Standalone settings.json patcher (min 80 lines) | VERIFIED | 139 lines, executable, valid syntax, uses only fs/path (stdlib), contains `council-check-update.js` idempotent check and `council-statusline.js` detection strings |
| `install.sh` | Updated installer with code-prefixed arrays, delegation, dual-name uninstall | VERIFIED | `bash -n` passes, PERSONAS array code-prefixed, HOOKS includes patch-settings.js, LEGACY_PERSONAS cleanup present, 2 delegation calls, no heredocs |

### Key Link Verification

| From | To | Via | Status | Details |
|------|----|-----|--------|---------|
| `skills/council-code/SKILL.md` | `agents/code-contrarian.md` | Reference path in References section | WIRED | Line 109: `` `agents/code-contrarian.md` -- Fatal flaw finder `` |
| `skills/council-code/SKILL.md` | `agents/code-executor.md` | Reference path in References section | WIRED | Line 113: `` `agents/code-executor.md` -- Monday-morning shipper `` |
| `install.sh` | `hooks/patch-settings.js` | `node $REPO_ROOT/hooks/patch-settings.js --install` | WIRED | Line 100-105 (install delegation), lines 111-114 (uninstall delegation) |
| `install.sh` | `agents/code-contrarian.md` | PERSONAS array drives symlink/copy loop | WIRED | PERSONAS array at line 126 contains `code-contrarian`; loop at line 159/169 uses `$persona.md` |
| `hooks/patch-settings.js` | `~/.claude/settings.json` | `--settings` flag specifies target file | WIRED | Line 27: `const settingsFile = get('--settings')` used throughout install/uninstall logic |
| `hooks/patch-settings.js` | `council-statusline-next.txt` | `--next-file` flag specifies delegation chain file | WIRED | Line 28: `const nextFile = get('--next-file')` used for delegation chain save/restore |

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| patch-settings.js syntax valid | `node --check hooks/patch-settings.js` | Exit 0 | PASS |
| patch-settings.js prints usage without args | `node hooks/patch-settings.js` (no args) | Prints usage, exits 1 | PASS |
| patch-settings.js is executable | `test -x hooks/patch-settings.js` | True | PASS |
| patch-settings.js idempotent install | Double install with `council-check-update.js` hook | 1 SessionStart entry after 2 runs | PASS |
| patch-settings.js uninstall removes entries | Install then uninstall | statusLine removed, SessionStart cleaned | PASS |
| patch-settings.js preserves delegation chain | Install over existing statusLine | Previous command saved to next.txt | PASS |
| install.sh syntax valid | `bash -n install.sh` | Exit 0 | PASS |
| install.sh help works | `bash install.sh --help` | Prints usage, exit 0 | PASS |

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|------------|-------------|--------|----------|
| FOUND-01 | 01-01, 01-03 | Agent files renamed to council-prefixed names to prevent namespace collision | SATISFIED | All 5 agents renamed to code-* prefix; PERSONAS array in install.sh updated; no bare-name files remain |
| FOUND-02 | 01-02, 01-03 | Inline settings.json patcher extracted to standalone reusable script | SATISFIED | hooks/patch-settings.js (139 lines) standalone with --install/--uninstall modes; install.sh heredocs replaced with delegation calls |
| FOUND-03 | 01-01 | All council SKILL.md files include `disable-model-invocation: true` | SATISFIED | skills/council-code/SKILL.md line 4 has `disable-model-invocation: true` |
| FOUND-04 | 01-01, 01-03 | Existing /council-code and /council triggers continue to work | SATISFIED | `name: council-code` preserved in SKILL.md; LEGACY_PERSONAS dual-name uninstall added for upgrade path |

No orphaned requirements found. All 4 FOUND-* requirements mapped to Phase 1 in REQUIREMENTS.md are claimed by plans and have implementation evidence.

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| (none) | - | - | - | No TODO, FIXME, placeholder, or stub patterns found in any modified file |

### Confirmation Bias Counter Findings

1. **Partial requirement (FOUND-02 edge case):** The idempotency check in patch-settings.js is hardcoded to the string `council-check-update.js`. If a future council uses a different hook name, running its installer will not deduplicate -- it will append a second SessionStart entry. This is acceptable for now (the idempotency is scoped to the council ecosystem's single hook) but becomes a design consideration when new councils are added. INFO severity -- not a blocker for Phase 1's goal.

2. **Uninstall leaves empty `hooks: {}` in settings.json:** After uninstall, settings.json retains `"hooks": {}` rather than removing the empty object. This is cosmetically imperfect but functionally harmless -- Claude Code ignores empty hook objects.

3. **Error path with no test:** If `--settings` points to a file with invalid JSON and `--install` is used, the script correctly exits 1 with an error message, but the backup is only written if `raw` is truthy. An empty file (0 bytes) would result in no backup and the catch block for `JSON.parse` would write a backup path that was never created. Edge case, INFO severity.

### Human Verification Required

### 1. End-to-end install cycle

**Test:** Run `./install.sh` from the repo root, then verify `ls ~/.claude/agents/` shows only code-prefixed files
**Expected:** 5 code-*.md files symlinked to the repo's agents/ directory; `patch-settings.js` also symlinked to `~/.claude/hooks/`; settings.json patched with statusLine and SessionStart entries
**Why human:** Requires filesystem side effects in the user's home directory and a running Claude Code environment

### 2. Trigger phrase resolution

**Test:** In a new Claude Code session after install, type `/council-code` or `/council`
**Expected:** The council skill triggers and spawns 5 advisors with the same behavior as before the rename
**Why human:** Trigger phrase resolution is a Claude Code runtime behavior that cannot be verified by static file analysis

### 3. Dual-name uninstall from pre-rename state

**Test:** Install the pre-rename version first (bare-name agents), then update to current code and run `./install.sh --uninstall`
**Expected:** Both old bare-name (contrarian.md, etc.) and new code-prefixed (code-contrarian.md, etc.) files removed from `~/.claude/agents/`
**Why human:** Requires a pre-rename installation state that no longer exists in this repo's working tree

### Gaps Summary

No automated gaps found. All 4 roadmap success criteria are verified through static analysis, file inspection, and behavioral spot-checks. Three items require human verification to confirm runtime behavior: end-to-end install, trigger phrase resolution, and dual-name uninstall from a pre-rename state.

---

_Verified: 2026-04-23T21:00:00Z_
_Verifier: Claude (gsd-verifier)_
