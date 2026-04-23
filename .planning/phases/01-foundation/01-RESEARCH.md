# Phase 1: Foundation - Research

**Researched:** 2026-04-23
**Domain:** Claude Code plugin refactor — agent namespace, installer, SKILL.md frontmatter
**Confidence:** HIGH

## Summary

Phase 1 is a pure refactor with zero new user-visible behavior. Every change is a pre-condition for adding new councils safely. The three work streams are independent: (1) rename the 5 code council agent files from bare names to `code-` prefixed names, update references in SKILL.md and install.sh; (2) extract the inline Node.js settings.json patcher from install.sh into a standalone `hooks/patch-settings.js` script with `--install`/`--uninstall` flags; (3) add `disable-model-invocation: true` to the council-code SKILL.md frontmatter.

All changes are in plain text files — no compilation, no dependencies. The existing `install.sh` shell patterns (array-driven installs, `backup_if_real`, idempotent re-run) are fully reusable and require only targeted edits. The settings patcher extraction is the most complex task because the inline Node.js heredoc must be converted to a self-contained script while preserving exact behavioral parity (statusLine delegation chain, append-only SessionStart, timestamped backup).

A live install already exists on this machine: bare-name agents (`contrarian.md`, `executor.md`, `expansionist.md`, `first-principles.md`, `outsider.md`) are in `~/.claude/agents/`. The `--uninstall` path in install.sh must remove both old bare-name files AND install new `code-`-prefixed files atomically so users who re-run install.sh end up in a clean state.

**Primary recommendation:** Tackle the 3 work streams as 3 atomic commits — agent rename, patcher extraction, SKILL.md frontmatter — in that order, so each can be verified independently before the next lands.

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**D-01:** Hard cutover — rename all 5 agent files from bare names (`contrarian.md`) to code-prefixed names (`code-contrarian.md`) in the repo and in install.sh. No compatibility shims, no dual names.

**D-02:** install.sh re-run cleans up old bare-name symlinks/copies from `~/.claude/agents/`. Users must re-run install.sh after updating.

**D-03:** install.sh `--uninstall` removes both old bare-name AND new code-prefixed files to handle users who installed before the rename. Drop bare-name cleanup after one release cycle.

**D-04:** Extract inline Node.js heredoc from install.sh to a standalone `hooks/patch-settings.js` CLI tool with `--install` and `--uninstall` modes.

**D-05:** Single script, flag-driven — one `patch-settings.js` handles all settings.json mutations (statusline wiring, SessionStart hook registration, future needs). Callers pass flags like `--statusline`, `--hook "command"`.

**D-06:** Each future council installer calls the same `patch-settings.js` — it's the shared entry point for settings.json mutations across all councils.

**D-07:** Skill naming convention is `council-*` prefix. The existing `skills/council-code/` directory already follows this — no rename needed.

**D-08:** SKILL.md internal references updated from `agents/contrarian.md` to `agents/code-contrarian.md`. Triggers `/council-code` and `/council` continue to work identically.

**D-09:** Add `disable-model-invocation: true` to council-code SKILL.md frontmatter per FOUND-03.

### Claude's Discretion

- Exact flag interface design for patch-settings.js (argument parsing, validation, error messages)
- Whether patch-settings.js uses a JSON config input or purely CLI flags
- Exact backup naming convention for settings.json backups
- MIGRATION.md or CHANGELOG entry wording for the rename

### Deferred Ideas (OUT OF SCOPE)

None — discussion stayed within phase scope.

</user_constraints>

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| FOUND-01 | Existing agent files renamed to council-prefixed names (`contrarian.md` → `code-contrarian.md`) to prevent namespace collision across councils | Agent rename patterns verified; install.sh array-driven pattern confirms straightforward implementation |
| FOUND-02 | Inline settings.json patcher extracted to standalone reusable script that all councils share | Patcher logic fully read and understood; Node.js stdlib patterns confirmed; exact behavioral parity requirements documented |
| FOUND-03 | All council orchestrator SKILL.md files include `disable-model-invocation: true` frontmatter to prevent auto-loading into context | Frontmatter syntax verified against official Claude Code skills reference; one-line addition to existing SKILL.md |
| FOUND-04 | Existing `/council-code` and `/council` triggers continue to work identically after refactor | Trigger mechanism is the `name:` field in SKILL.md frontmatter — unchanged; only agent reference paths inside SKILL.md body need updating |

</phase_requirements>

---

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Agent namespace management | Filesystem / `~/.claude/agents/` | install.sh orchestration | Claude Code discovers agents from the flat `~/.claude/agents/` directory; naming is the only namespace mechanism |
| Settings.json mutation | `hooks/patch-settings.js` (new) | install.sh (caller) | JSON mutation must be safe (backup, validate, append-only); Node.js owns this, shell script delegates to it |
| Skill invocation control | SKILL.md frontmatter | Claude Code runtime | `disable-model-invocation: true` is a frontmatter directive consumed by Claude Code at skill discovery time |
| Install/uninstall orchestration | `install.sh` | N/A | Shell owns directory creation, symlink management, and delegation to patch-settings.js |
| Backward compatibility for triggers | SKILL.md `name:` field | N/A | The `/council-code` and `/council` triggers are resolved from the skill name — unchanged by this phase |

---

## Standard Stack

### Core

| Component | Version / Type | Purpose | Why Standard |
|-----------|---------------|---------|--------------|
| Bash (install.sh) | POSIX + bash 3.2+ | Install orchestration | Already in use; no new tooling introduced |
| Node.js (hooks) | v25.8.0 (confirmed on this machine) | Settings.json patching | Already used for all hooks; stdlib only (fs, path, process.argv) |
| SKILL.md YAML frontmatter | Claude Code native | Skill metadata and invocation control | Platform-native; no build step |
| Agent `.md` frontmatter | Claude Code native | Agent metadata and tool restrictions | Platform-native; no build step |

### No New Dependencies

This phase introduces no new npm packages, no new shell utilities, and no new external services. Node.js stdlib (`fs`, `path`, `process.argv`) is the only runtime used by patch-settings.js.

[VERIFIED: codebase inspection — install.sh uses `node -` heredoc with stdlib only]

---

## Architecture Patterns

### System Architecture Diagram

```
install.sh (entry point)
    │
    ├── [uninstall mode]
    │       ├── remove bare-name agents from ~/.claude/agents/
    │       ├── remove code-prefixed agents from ~/.claude/agents/
    │       ├── remove hooks, skills
    │       └── node hooks/patch-settings.js --uninstall
    │
    └── [install mode]
            ├── mkdir ~/.claude/{agents,skills,hooks}
            ├── symlink/copy skills/council-code → ~/.claude/skills/council-code
            ├── symlink/copy agents/code-*.md → ~/.claude/agents/code-*.md
            ├── symlink/copy hooks/*.js → ~/.claude/hooks/
            └── node hooks/patch-settings.js --install
                        │
                        ├── read + backup settings.json
                        ├── set statusLine (preserve existing to next.txt)
                        └── append SessionStart hook (idempotent)
```

### Recommended Project Structure

After Phase 1 completes:

```
council-code/
├── agents/
│   ├── code-contrarian.md       # renamed from contrarian.md
│   ├── code-executor.md         # renamed from executor.md
│   ├── code-expansionist.md     # renamed from expansionist.md
│   ├── code-first-principles.md # renamed from first-principles.md
│   └── code-outsider.md         # renamed from outsider.md
├── hooks/
│   ├── council-check-update.js
│   ├── council-check-update-worker.js
│   ├── council-statusline.js
│   ├── patch-settings.js        # NEW — extracted from install.sh heredoc
│   └── README.md
├── skills/
│   └── council-code/
│       └── SKILL.md             # updated: disable-model-invocation + agent refs
└── install.sh                   # updated: new PERSONAS array, calls patch-settings.js
```

### Pattern 1: Array-Driven Install (existing, reuse)

**What:** install.sh iterates bash arrays for each file category (SKILLS, PERSONAS, HOOKS). Adding a council means adding array entries.

**When to use:** Every file that is symlinked or copied to `~/.claude/`.

**Example:**
```bash
# Source: /Users/D052192/src/council-code/install.sh lines 207-209
SKILLS=( council-code council-update )
PERSONAS=( code-contrarian code-first-principles code-expansionist code-outsider code-executor )
HOOKS=( council-statusline.js council-check-update.js council-check-update-worker.js patch-settings.js )

# Array iteration pattern (unchanged):
for persona in "${PERSONAS[@]}"; do
  install_link "$REPO_ROOT/agents/$persona.md" "$AGENTS_DIR/$persona.md"
done
```

[VERIFIED: codebase inspection — install.sh lines 207-250]

### Pattern 2: Uninstall Dual-Name Cleanup (new for D-03)

**What:** During `--uninstall`, remove BOTH old bare-name files (for users who installed before the rename) AND new code-prefixed files. This is a one-release-cycle compatibility measure.

**When to use:** Only in the uninstall branch of install.sh.

**Example:**
```bash
# New uninstall section — remove legacy bare-name agents
LEGACY_PERSONAS=( contrarian first-principles expansionist outsider executor )
for persona in "${LEGACY_PERSONAS[@]}"; do
  remove_target "$AGENTS_DIR/$persona.md"
done

# Remove current code-prefixed agents
PERSONAS=( code-contrarian code-first-principles code-expansionist code-outsider code-executor )
for persona in "${PERSONAS[@]}"; do
  remove_target "$AGENTS_DIR/$persona.md"
done
```

[ASSUMED — pattern derived from D-03 decision; exact variable names at Claude's discretion]

### Pattern 3: patch-settings.js CLI Interface (new, D-04/D-05)

**What:** Standalone Node.js script callable as `node hooks/patch-settings.js --install` or `node hooks/patch-settings.js --uninstall`. All arguments via `process.argv`; no npm dependencies.

**When to use:** Called by install.sh and by future council installers. NOT called directly by the user.

**Example:**
```bash
# Caller in install.sh:
node "$REPO_ROOT/hooks/patch-settings.js" \
  --settings "$SETTINGS_FILE" \
  --install \
  --statusline "node \"$HOOKS_DIR/council-statusline.js\"" \
  --hook "node \"$HOOKS_DIR/council-check-update.js\""
```

Internal structure of patch-settings.js mirrors the current heredoc exactly:
1. Parse argv (`--install`/`--uninstall`, `--settings PATH`, `--statusline CMD`, `--hook CMD`)
2. Read + backup settings.json (timestamped, same as current)
3. `--install`: set statusLine (save displaced cmd to council-statusline-next.txt), append SessionStart hook entry (idempotent check)
4. `--uninstall`: restore previous statusLine from next.txt or delete, remove matching SessionStart hook entry

[ASSUMED — flag names at Claude's discretion; logic parity with current heredoc is required]

### Pattern 4: disable-model-invocation Frontmatter (FOUND-03)

**What:** YAML frontmatter key that prevents Claude Code from auto-invoking the skill during model turns. User can still invoke with `/council-code`.

**When to use:** All council orchestrator SKILL.md files. NOT on individual advisor agent files (those use the `tools:` restriction instead).

**Example:**
```yaml
---
name: council-code
description: Multi-perspective code decision council. [...]
disable-model-invocation: true
---
```

[VERIFIED: official Claude Code skills reference — confirmed in `~/.claude/plugins/marketplaces/claude-plugins-official/plugins/claude-code-setup/skills/claude-automation-recommender/references/skills-reference.md`]

### Anti-Patterns to Avoid

- **Shim files for old agent names:** D-01 locks in hard cutover — do not create `contrarian.md` that redirects to `code-contrarian.md`. Shims don't exist in the Claude Code agent model and there is no redirect mechanism.
- **Modifying the settings.json heredoc instead of extracting it:** If Phase 1 edits the heredoc rather than extracting to `patch-settings.js`, Phase 2 starts with the same fragility. Extract first.
- **Adding `disable-model-invocation: true` to advisor agent files:** This frontmatter key is for SKILL.md files, not agent `.md` files. Agents use `tools:` to restrict capabilities. Adding it to agents would have no documented effect and would be confusing.
- **Renaming `skills/council-code/` directory:** D-07 locks this in — no rename needed. The skill name and directory already follow the `council-*` convention.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Safe JSON mutation | Custom string-replace on settings.json | Node.js `JSON.parse` + `JSON.stringify` (already in use) | Regex on JSON breaks on whitespace variations, unicode, nested quotes |
| Timestamped backup | Custom backup naming | `Date.now()` suffix (already in use in current heredoc) | Simple, sortable, collision-resistant for single-user install |
| Idempotent hook append | Re-check on every install whether hook is already wired | Existing `.some()` check in the inline patcher (preserve this logic) | Prevents duplicate SessionStart entries from multiple install runs |
| Argument parsing | `getopt`, external npm flag parsers | Manual `process.argv` scan (fits 3-4 flags; matches existing hook style) | No npm deps constraint; script is a tool, not a library |

**Key insight:** The goal is behavioral parity with the current inline heredoc, not a feature-rich CLI. Keep patch-settings.js small.

---

## Runtime State Inventory

This phase includes a rename that affects files installed to the user's filesystem at runtime.

| Category | Items Found | Action Required |
|----------|-------------|------------------|
| Stored data | None — no database, no persistent state keyed on agent names | None |
| Live service config | None — no external services reference agent file names | None |
| OS-registered state | `~/.claude/agents/`: 5 bare-name symlinks (`contrarian.md`, `executor.md`, `expansionist.md`, `first-principles.md`, `outsider.md`) confirmed present on this machine [VERIFIED: bash ls] | install.sh `--uninstall` + re-install removes old, installs new |
| Secrets/env vars | None — no env vars reference agent names | None |
| Build artifacts | None — no compiled artifacts; pure Markdown files | None |

**Migration path for existing users:**
```
git pull
./install.sh --uninstall   # removes bare-name files
./install.sh               # installs code-prefixed files
```

The `--uninstall` + reinstall is a two-step because D-02 requires users to re-run install.sh. A MIGRATION.md should document this explicitly. The SKILL.md and hook symlinks do not need re-install (symlinks auto-update on git pull).

**Live settings.json state on this machine:**
- `statusLine` is currently set to GSD's statusline (`node "/Users/D052192/.claude/hooks/gsd-statusline.js"`) — council-code's statusline was displaced by GSD's subsequent install.
- `SessionStart` contains council-check-update.js entry (wired at position 2 of 4 entries) — this survives.
- `council-statusline-next.txt` does NOT exist — this means the statusLine displacement chain was broken.

This real-world state confirms that `patch-settings.js --install` must handle the case where the settings.json already has a different statusLine that is NOT the one we set (i.e., we check if current statusLine is OUR value before deciding to overwrite it, to avoid stomping a third party's statusline that was set after us).

[VERIFIED: bash inspection of `~/.claude/settings.json` and `~/.claude/hooks/`]

---

## Common Pitfalls

### Pitfall 1: Agent Rename Breaks SKILL.md References
**What goes wrong:** Agents are renamed in `agents/` and in install.sh PERSONAS array, but SKILL.md body still references `agents/contrarian.md` etc. The council runs but advisors fail to load.
**Why it happens:** SKILL.md contains explicit file path references in the References section (lines 106-111) and in the Step 2 protocol text. These are documentation references, not runtime-loaded paths — but they must be updated for accuracy and for any future tooling that reads them.
**How to avoid:** Grep for all occurrences of bare agent names in SKILL.md as part of the rename task.
**Warning signs:** `agents/contrarian.md`, `agents/executor.md` etc. appear in SKILL.md after the rename is "done."

### Pitfall 2: Duplicate SessionStart Hook Entry After Re-install
**What goes wrong:** Running `./install.sh` twice (or after an upgrade) adds a second `council-check-update.js` entry to `SessionStart`.
**Why it happens:** The idempotent check in the current heredoc (`already = cfg.hooks.SessionStart.some(...)`) must be preserved verbatim in `patch-settings.js`. Omitting it or changing the detection string breaks idempotency.
**How to avoid:** The `.some()` check string `'council-check-update.js'` must survive the extraction exactly. Test by running `./install.sh` twice and inspecting settings.json.
**Warning signs:** `settings.json` has two identical `council-check-update.js` entries in SessionStart.

### Pitfall 3: patch-settings.js Breaks statusLine Delegation Chain
**What goes wrong:** `patch-settings.js --install` overwrites the statusLine with the council wrapper even when the current statusLine is already something other than council's (e.g., GSD's statusline set after council was last configured). This breaks the user's working statusLine.
**Why it happens:** The current inline patcher checks `if existing !== wrapperCmd` before saving to next.txt. But if the council wrapper was previously installed and then another tool (GSD) overwrote it, next.txt may be absent. Re-running council install will then save GSD's command to next.txt — which is correct behavior. The risk is if patch-settings.js changes this logic.
**How to avoid:** Preserve the exact conditional: "if the current statusLine command is not already OUR wrapper, save the current command to next.txt before overwriting."
**Warning signs:** User reports their GSD statusline disappeared after running `./install.sh`.

### Pitfall 4: install.sh PERSONAS Array Uses Wrong File Extension in Symlink Target
**What goes wrong:** `install_link "$REPO_ROOT/agents/$persona.md" "$AGENTS_DIR/$persona.md"` — the `$persona` variable in the new array is `code-contrarian` (no `.md`), so the `.md` is appended in the install_link call. If someone accidentally adds `.md` to the array entry, the target becomes `code-contrarian.md.md`.
**Why it happens:** The existing PERSONAS array contains bare names without `.md` extension, and the loop appends `.md`. This pattern must be preserved exactly when updating the array.
**How to avoid:** Keep array entries without `.md` suffix, exactly like the current array.
**Warning signs:** `ls ~/.claude/agents/` shows `code-contrarian.md.md` or broken symlinks.

### Pitfall 5: `disable-model-invocation: true` Added in Wrong Frontmatter Position
**What goes wrong:** Adding the key after the closing `---` or inside the body rather than inside the YAML block silently has no effect.
**Why it happens:** SKILL.md already has a 2-line frontmatter (`name:` and `description:`). The new key must go between the `---` delimiters.
**How to avoid:** Verify the frontmatter block is well-formed YAML after the addition. The key goes on a new line between `description:` and the closing `---`.
**Warning signs:** Claude Code still auto-invokes council-code in model turns after the frontmatter change.

---

## Code Examples

Verified patterns from official sources and codebase:

### Current Agent Frontmatter (example: contrarian.md)
```yaml
# Source: /Users/D052192/src/council-code/agents/contrarian.md
---
name: contrarian
description: Devil's advocate for code decisions. [...]
tools: Read, Grep, Glob, WebSearch, WebFetch
---
```

After rename to `code-contrarian.md`, only the filename changes. The `name:` field value is what Claude Code uses for invocation — update `name: contrarian` to `name: code-contrarian` to keep the agent name consistent with the file name.

[VERIFIED: codebase inspection — all 5 agent files follow this frontmatter pattern]

### Target SKILL.md Frontmatter (after FOUND-03)
```yaml
# Source: /Users/D052192/src/council-code/skills/council-code/SKILL.md (current)
# After adding disable-model-invocation: true:
---
name: council-code
description: Multi-perspective code decision council. [...]
disable-model-invocation: true
---
```

[VERIFIED: official Claude Code skills reference + changelog note confirms `/council-code` mid-message invocation still works with this flag]

### install.sh PERSONAS Array Update
```bash
# Current (source: install.sh line 208):
PERSONAS=( contrarian first-principles expansionist outsider executor )

# After rename:
PERSONAS=( code-contrarian code-first-principles code-expansionist code-outsider code-executor )
```

### install.sh Uninstall Dual-Name Cleanup (new section, after D-03)
```bash
# In the uninstall branch, before removing current files:
# Remove legacy bare-name agents (for users who installed pre-rename)
LEGACY_PERSONAS=( contrarian first-principles expansionist outsider executor )
for persona in "${LEGACY_PERSONAS[@]}"; do
  remove_target "$AGENTS_DIR/$persona.md"
done
```

### install.sh Calls patch-settings.js (D-04 extraction)
```bash
# Current (lines 97-148 in install.sh): inline heredoc
# After extraction:
patch_settings_install() {
  [[ -f "$SETTINGS_FILE" ]] || { echo '{}' > "$SETTINGS_FILE"; }
  have_node || { warn "node not found — skipping settings.json patch"; return 0; }
  node "$REPO_ROOT/hooks/patch-settings.js" \
    --settings "$SETTINGS_FILE" \
    --install \
    --statusline "node \"$HOOKS_DIR/council-statusline.js\"" \
    --hook "node \"$HOOKS_DIR/council-check-update.js\"" \
    --next-file "$HOOKS_DIR/council-statusline-next.txt"
}

patch_settings_uninstall() {
  [[ -f "$SETTINGS_FILE" ]] || return 0
  have_node || { warn "node not found — settings.json left as-is"; return 0; }
  node "$REPO_ROOT/hooks/patch-settings.js" \
    --settings "$SETTINGS_FILE" \
    --uninstall \
    --next-file "$HOOKS_DIR/council-statusline-next.txt"
}
```

[ASSUMED — exact flag names at Claude's discretion; behavioral parity is required]

### SKILL.md References Section Update (FOUND-01 + FOUND-04)
```markdown
# Current (lines 106-111 of SKILL.md):
- `agents/contrarian.md` — Fatal flaw finder
- `agents/first-principles.md` — Primitives reducer
...

# After rename:
- `agents/code-contrarian.md` — Fatal flaw finder
- `agents/code-first-principles.md` — Primitives reducer
...
```

Also update inline text in Step 2 protocol: `agents/<role>.md` references must become `agents/code-<role>.md`.

---

## State of the Art

| Old Approach | Current Approach | Notes |
|--------------|------------------|-------|
| Inline Node.js heredoc in shell script | Standalone `hooks/patch-settings.js` | This phase performs this migration |
| Bare-name agents (`contrarian.md`) | Council-prefixed agents (`code-contrarian.md`) | This phase performs this rename |
| No invocation control on SKILL.md | `disable-model-invocation: true` | One-line frontmatter addition |

---

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | `name:` field in agent frontmatter should be updated from `contrarian` to `code-contrarian` to match the new filename | Code Examples | If `name:` is not how Claude Code identifies agents in Task calls, the advisor spawning reference in SKILL.md body may need a different update |
| A2 | patch-settings.js flag interface (e.g., `--install`, `--settings`, `--statusline`, `--hook`, `--next-file`) | Architecture Patterns | Exact flag names are at Claude's discretion — the interface shown is a recommended shape, not a locked spec |
| A3 | LEGACY_PERSONAS array approach for dual-name cleanup is the right pattern for D-03 | Code Examples | If install.sh's `remove_target` function has edge cases for non-existent files, the cleanup loop may produce spurious warnings (not functional breakage) |

---

## Open Questions

1. **Does `name:` in agent frontmatter affect Task tool dispatch?**
   - What we know: The `name:` field in SKILL.md is the slash-command trigger (e.g., `/council-code`). In agent files, `name:` is shown to the user and in descriptions.
   - What's unclear: When SKILL.md instructs "use `subagent_type: general-purpose`" for each Task call, does Claude resolve the advisor's identity from the file path passed in context, or from the `name:` field? If from the `name:` field, renaming `name: contrarian` → `name: code-contrarian` is required for consistency. If Claude Code ignores `name:` for agents, only the filename matters.
   - Recommendation: Update both the filename AND the `name:` field to stay consistent. Low risk.

2. **Should `patch-settings.js` be symlinked into `~/.claude/hooks/` by install.sh?**
   - What we know: It's a shared utility called by install.sh, not by Claude Code's hook system directly.
   - What's unclear: Future council installers (Phase 8) need to call it. If install.sh for council-strategy wants to call it, does it need to be at `~/.claude/hooks/patch-settings.js` or can it be called from the repo path?
   - Recommendation: Don't install it to `~/.claude/hooks/`. Future council repos call it from their own repo root or from a relative path resolved via `readlink -f`. Keep it a dev tool, not a runtime hook.

---

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Node.js | patch-settings.js, all hooks | Yes | v25.8.0 | install.sh already has `have_node` guard with warning |
| Bash | install.sh | Yes | zsh (POSIX-compatible) | N/A |
| Git | Council-update, check-update hooks | Yes | (system git) | N/A |

[VERIFIED: `node --version` → v25.8.0; `have_node` guard already exists in install.sh line 82-84]

---

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | None — no test runner configured |
| Config file | None |
| Quick run command | `bash install.sh --help` (smoke) |
| Full suite command | Manual verification checklist (see Wave 0 Gaps) |

This is a pure-Markdown + shell/Node.js project with no test framework. All validation is behavioral: run install.sh, inspect `~/.claude/agents/`, verify settings.json state.

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| FOUND-01 | `code-contrarian.md` exists in `~/.claude/agents/`, bare `contrarian.md` does not | smoke | `ls ~/.claude/agents/ \| grep -c code-` | Wave 0 |
| FOUND-01 | No bare-name agent files remain in `agents/` repo directory | smoke | `ls agents/ \| grep -v '^code-'` (should return nothing) | Wave 0 |
| FOUND-02 | `hooks/patch-settings.js --install` produces same settings.json state as old heredoc | smoke | `node hooks/patch-settings.js --install --settings /tmp/test-settings.json ...` | Wave 0 |
| FOUND-02 | Re-running `--install` does not add duplicate SessionStart entries | smoke | Manual inspect of settings.json after 2 installs | Wave 0 |
| FOUND-03 | `disable-model-invocation: true` present in SKILL.md frontmatter | smoke | `grep 'disable-model-invocation' skills/council-code/SKILL.md` | Wave 0 |
| FOUND-04 | `/council` and `/council-code` triggers work after rename | manual | Restart Claude Code, type `/council-code`, verify skill loads | Wave 0 |

### Sampling Rate
- **Per task commit:** `bash install.sh --help` (verify script parses without error)
- **Per wave merge:** Full manual verification checklist
- **Phase gate:** All 4 requirements verified before `/gsd-verify-work`

### Wave 0 Gaps
- [ ] `verify-phase1.sh` — shell smoke script checking post-install state of `~/.claude/agents/`, SKILL.md frontmatter, and settings.json idempotency
- [ ] Manual test: run `./install.sh`, then `./install.sh` again, confirm no duplicate SessionStart entries

*(No test framework install needed — pure shell/Node.js verification)*

---

## Security Domain

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V5 Input Validation | Minimal | `JSON.parse` already validates settings.json; argv flag parsing should reject unknown flags |
| V6 Cryptography | No | No cryptographic operations |
| V2 Authentication | No | No user auth layer |

### Threat Patterns

| Pattern | Relevance | Mitigation |
|---------|-----------|------------|
| Settings.json corruption | LOW — Node.js JSON parse failure exits with error message, backup already written | Current backup-before-mutate pattern preserved in patch-settings.js |
| Path traversal in `--settings` flag | LOW — install.sh constructs the path from `$CLAUDE_DIR` variable, not user input | N/A for this use case; patch-settings.js is called from install.sh, not from user input |
| Malformed `--hook` command injection | LOW — argument is written verbatim into JSON string; Node.js JSON.stringify handles escaping | Use `JSON.stringify` when embedding the command string into the JSON object |

---

## Sources

### Primary (HIGH confidence)
- `/Users/D052192/src/council-code/install.sh` — full source inspected [VERIFIED]
- `/Users/D052192/src/council-code/skills/council-code/SKILL.md` — full source inspected [VERIFIED]
- `/Users/D052192/src/council-code/agents/contrarian.md` (and all 4 other agents) — frontmatter pattern confirmed [VERIFIED]
- `~/.claude/plugins/marketplaces/claude-plugins-official/.../skills-reference.md` — `disable-model-invocation` syntax and behavior confirmed [VERIFIED]
- `~/.claude/settings.json` — live settings.json state inspected to understand real-world install conditions [VERIFIED]
- `~/.claude/agents/` — confirmed 5 bare-name symlinks present on this machine [VERIFIED]
- `/Users/D052192/src/council-code/.planning/research/SUMMARY.md` — prior project research for this phase domain [VERIFIED]
- `/Users/D052192/src/council-code/.planning/phases/01-foundation/01-CONTEXT.md` — locked decisions [VERIFIED]

### Secondary (MEDIUM confidence)
- `/Users/D052192/src/council-code/.planning/REQUIREMENTS.md` — requirement text and traceability [VERIFIED]

### Tertiary (N/A)
No web searches required — all claims sourced from codebase inspection or verified documentation on this machine.

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — no new technology; everything is existing codebase patterns
- Architecture: HIGH — all files read; extraction target (heredoc) fully understood
- Pitfalls: HIGH — sourced from direct codebase inspection and live settings.json state
- Runtime state inventory: HIGH — bash-verified on this machine

**Research date:** 2026-04-23
**Valid until:** Stable — pure internal refactor with no external dependencies; research does not expire
