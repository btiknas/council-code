---
phase: 03-router
reviewed: 2026-04-24T00:00:00Z
depth: standard
files_reviewed: 3
files_reviewed_list:
  - skills/council-router/SKILL.md
  - skills/council-code/SKILL.md
  - install.sh
findings:
  critical: 0
  warning: 3
  info: 3
  total: 6
status: issues_found
---

# Phase 03: Code Review Report

**Reviewed:** 2026-04-24
**Depth:** standard
**Files Reviewed:** 3
**Status:** issues_found

## Summary

Three files reviewed: the new `council-router` skill, the existing `council-code` skill, and the installer. No critical (security/crash) issues were found. The router design is sound and internally consistent.

Three warnings cover a behavioral ambiguity in the router caused by `disable-model-invocation: true` paired with a free-form reasoning step, an undocumented `--symlink` flag in the installer, and a subtle `echo '{}' > file` call that is safe now but fragile. Three info items flag documentation inconsistencies and a dead-code pattern in the argument parser.

---

## Warnings

### WR-01: `disable-model-invocation: true` conflicts with inline classification in Step 1

**File:** `skills/council-router/SKILL.md:4`

**Issue:** The frontmatter sets `disable-model-invocation: true`, which means the skill cannot emit free-form text without calling a tool. Step 1 of the protocol instructs the model to "read the question, reason about fit, select a council" as an inline inference step before calling `AskUserQuestion`. Under `disable-model-invocation: true` this reasoning cannot be surfaced as text — it happens silently, or the model must jump directly to the `AskUserQuestion` call. This works in practice (internal reasoning is still possible before a tool call), but the directive in the protocol ("Do NOT spawn a subagent for classification. This is a single inference step") implies visible reasoning, which the flag prevents. The mismatch will confuse future maintainers who read Step 1 and see no tool call driving it.

**Fix:** Either add a brief comment in the frontmatter explaining why `disable-model-invocation: true` is intentional despite the reasoning step, or remove the flag if visible classification reasoning is desired:

```yaml
# disable-model-invocation: true is intentional: classification happens as
# pre-tool reasoning before AskUserQuestion; no free-form response is needed.
disable-model-invocation: true
```

---

### WR-02: `--symlink` flag is undocumented in help text and usage comment

**File:** `install.sh:38-40`

**Issue:** The argument parser at line 38 accepts `--symlink` as a valid flag and sets `MODE="symlink"`. However, the usage comment at the top of the file (lines 13-16) lists only `--copy` and `--uninstall`. The `--help` handler on line 40 renders lines 2-17 of the script via `sed -n '2,17p' "$0"`, which does not include the `--symlink` line. Users who read `--help` have no way to discover this flag.

Since `--symlink` is the default (line 46: `MODE="${MODE:-symlink}"`), the flag is a no-op in practice but the omission from the help text is misleading and the acceptance of an undocumented argument is confusing.

**Fix:** Add `--symlink` to the usage block comment:

```bash
# Usage:
#   ./install.sh              # symlink (default, recommended — git pull to update)
#   ./install.sh --symlink    # same as default, explicit
#   ./install.sh --copy       # copy files instead of symlinking
#   ./install.sh --uninstall  # remove everything we installed, restore previous statusLine
```

---

### WR-03: `patch_settings_install` creates settings.json with shell redirect, not mkdir-safe

**File:** `install.sh:105`

**Issue:** `patch_settings_install` contains:
```bash
[[ -f "$SETTINGS_FILE" ]] || { echo '{}' > "$SETTINGS_FILE"; }
```
`SETTINGS_FILE` is `$CLAUDE_DIR/settings.json`. If `$CLAUDE_DIR` does not exist, this write fails silently (the `{ ... }` block does not check exit status, and `set -e` would be suppressed inside `[[ ]] ||` short-circuit). In the current code flow this is safe because `mkdir -p "$SKILLS_DIR" "$AGENTS_DIR" "$HOOKS_DIR"` on line 161 runs before `patch_settings_install` on line 185 — and `$SKILLS_DIR` is a subdirectory of `$CLAUDE_DIR`, so `$CLAUDE_DIR` is guaranteed to exist by line 185. However, if `patch_settings_install` is ever called earlier (e.g., extracted to a standalone function call), the race condition becomes real.

**Fix:** Add a guard inside `patch_settings_install` or replace the redirect with a mkdir-safe form:

```bash
patch_settings_install() {
  mkdir -p "$(dirname "$SETTINGS_FILE")"
  [[ -f "$SETTINGS_FILE" ]] || { echo '{}' > "$SETTINGS_FILE"; }
  ...
}
```

---

## Info

### IN-01: Agent reference paths in council-code are repo-relative, not install-relative

**File:** `skills/council-code/SKILL.md:41,109-115`

**Issue:** Line 41 and the References section (lines 109-115) cite agent files as `agents/code-contrarian.md` etc. These are repo-relative paths. At runtime, the agents are installed to `~/.claude/agents/code-contrarian.md`. The paths in the skill are used as documentation (not executed), but they create confusion for users who try to locate files from the skill's references.

**Fix:** Either qualify the paths as "repo paths" or update them to the installed location:

```markdown
## References (installed to `~/.claude/agents/`)
- `code-contrarian.md` — Fatal flaw finder
```

---

### IN-02: Duplicate `--copy` / `--symlink` silently accepted

**File:** `install.sh:29-37`

**Issue:** The conflict-detection guard pattern is:
```bash
[[ -z "$MODE" || "$MODE" == "copy" ]] || { echo "Error: ..." }
```
This allows `--copy --copy` and `--symlink --symlink` (same flag twice) without error, since the second check passes when `$MODE` already equals the flag's own value. This is harmless but inconsistent with the intent of detecting conflicting modes.

**Fix:** Enforce strict single-use:
```bash
--copy)
  [[ -z "$MODE" ]] || { echo "Error: --copy conflicts with --$MODE" >&2; exit 2; }
  MODE="copy" ;;
```

---

### IN-03: Help text uses hardcoded line range in sed (fragile)

**File:** `install.sh:40`

**Issue:** `sed -n '2,17p' "$0"` hardcodes line numbers 2 through 17 to extract the usage block for `--help`. Adding or removing any line in the header block (including the shebang or a blank line) will silently truncate or expand the help output. The pattern will also include non-comment lines if the block grows.

**Fix:** Use a sentinel-based extraction that does not depend on line numbers:

```bash
-h|--help)
  sed -n '/^# Usage/,/^[^#]/{ /^#/p }' "$0" | sed 's/^# \{0,1\}//'
  exit 0 ;;
```

---

_Reviewed: 2026-04-24_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
