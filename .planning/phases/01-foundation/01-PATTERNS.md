# Phase 1: Foundation - Pattern Map

**Mapped:** 2026-04-23
**Files analyzed:** 8 (3 modified, 5 renamed, 1 new)
**Analogs found:** 8 / 8

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `agents/code-contrarian.md` | agent config | N/A | `agents/contrarian.md` | exact |
| `agents/code-first-principles.md` | agent config | N/A | `agents/first-principles.md` | exact |
| `agents/code-expansionist.md` | agent config | N/A | `agents/expansionist.md` | exact |
| `agents/code-outsider.md` | agent config | N/A | `agents/outsider.md` | exact |
| `agents/code-executor.md` | agent config | N/A | `agents/executor.md` | exact |
| `skills/council-code/SKILL.md` | skill config | N/A | `skills/council-code/SKILL.md` (current) | exact (in-place edit) |
| `install.sh` | installer script | batch | `install.sh` (current) | exact (in-place edit) |
| `hooks/patch-settings.js` | utility script | transform | `install.sh` heredocs lines 105-147 + 155-196 | exact (extraction) |

## Pattern Assignments

### `agents/code-contrarian.md` (and all 4 other renamed agents)

**Analog:** `agents/contrarian.md`

**Full frontmatter pattern** (lines 1-5):
```yaml
---
name: contrarian
description: Devil's advocate for code decisions. Finds the fatal flaw, challenges consensus, surfaces hidden failure modes in proposed architectures, libraries, APIs, refactors, or algorithms.
tools: Read, Grep, Glob, WebSearch, WebFetch
---
```

**What changes:** Only two things per file:
1. The **filename** — `contrarian.md` becomes `code-contrarian.md`
2. The **`name:` field value** — `contrarian` becomes `code-contrarian`

The `description:`, `tools:`, and entire body are unchanged. Repeat for all 5 agents:

| Old filename | New filename | Old `name:` | New `name:` |
|---|---|---|---|
| `contrarian.md` | `code-contrarian.md` | `contrarian` | `code-contrarian` |
| `first-principles.md` | `code-first-principles.md` | `first-principles` | `code-first-principles` |
| `expansionist.md` | `code-expansionist.md` | `expansionist` | `code-expansionist` |
| `outsider.md` | `code-outsider.md` | `outsider` | `code-outsider` |
| `executor.md` | `code-executor.md` | `executor` | `code-executor` |

---

### `skills/council-code/SKILL.md` (skill config, in-place edit)

**Analog:** `skills/council-code/SKILL.md` (current file)

**Frontmatter before** (lines 1-4):
```yaml
---
name: council-code
description: Multi-perspective code decision council. Runs 5 expert advisors (Contrarian, First Principles, Expansionist, Outsider, Executor) in parallel on a code/architecture/engineering question, then synthesizes a chairman verdict with agreements, clashes, blind spots, and a concrete next step.
---
```

**Frontmatter after** (add `disable-model-invocation: true` before closing `---`):
```yaml
---
name: council-code
description: Multi-perspective code decision council. Runs 5 expert advisors (Contrarian, First Principles, Expansionist, Outsider, Executor) in parallel on a code/architecture/engineering question, then synthesizes a chairman verdict with agreements, clashes, blind spots, and a concrete next step.
disable-model-invocation: true
---
```

**Agent reference updates** (lines 40-41 body text, line 108-112 References section):

Current (lines 40-41):
```markdown
Agent definitions live in `agents/` at the repo root (see `agents/contrarian.md`, etc.).
```

After:
```markdown
Agent definitions live in `agents/` at the repo root (see `agents/code-contrarian.md`, etc.).
```

Current References section (lines 108-112):
```markdown
- `agents/contrarian.md` — Fatal flaw finder
- `agents/first-principles.md` — Primitives reducer
- `agents/expansionist.md` — Upside seeker
- `agents/outsider.md` — Distant-domain importer
- `agents/executor.md` — Monday-morning shipper
```

After:
```markdown
- `agents/code-contrarian.md` — Fatal flaw finder
- `agents/code-first-principles.md` — Primitives reducer
- `agents/code-expansionist.md` — Upside seeker
- `agents/code-outsider.md` — Distant-domain importer
- `agents/code-executor.md` — Monday-morning shipper
```

**Grep sweep required:** Before marking SKILL.md done, grep for all bare agent names to catch any inline body references in Step 2 protocol text (lines 55-68):
```bash
grep -n 'agents/contrarian\|agents/first-principles\|agents/expansionist\|agents/outsider\|agents/executor' skills/council-code/SKILL.md
```

---

### `install.sh` (installer script, in-place edit)

**Analog:** `install.sh` (current file)

**PERSONAS array update** (line 208):

Current:
```bash
PERSONAS=( contrarian first-principles expansionist outsider executor )
```

After:
```bash
PERSONAS=( code-contrarian code-first-principles code-expansionist code-outsider code-executor )
```

**HOOKS array update** (line 209) — add `patch-settings.js` to the array:

Current:
```bash
HOOKS=( council-statusline.js council-check-update.js council-check-update-worker.js )
```

After:
```bash
HOOKS=( council-statusline.js council-check-update.js council-check-update-worker.js patch-settings.js )
```

**Uninstall dual-name cleanup** — new block added in the uninstall branch (after line 212, before the existing skills loop):
```bash
# Remove legacy bare-name agents (for users who installed pre-rename, D-03)
LEGACY_PERSONAS=( contrarian first-principles expansionist outsider executor )
for persona in "${LEGACY_PERSONAS[@]}"; do
  remove_target "$AGENTS_DIR/$persona.md"
done
```

**`patch_settings_install` function replacement** (lines 97-148) — replace the heredoc body with a delegation call, preserving the `have_node` guard and fallback warning:
```bash
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
```

**`patch_settings_uninstall` function replacement** (lines 150-197) — same pattern:
```bash
patch_settings_uninstall() {
  [[ -f "$SETTINGS_FILE" ]] || return 0
  have_node || { warn "node not found — settings.json left as-is, remove hooks manually"; return 0; }
  node "$REPO_ROOT/hooks/patch-settings.js" \
    --settings "$SETTINGS_FILE" \
    --uninstall \
    --next-file "$HOOKS_DIR/council-statusline-next.txt"
}
```

**install_link / install_copy / remove_target helpers** (lines 54-80) — unchanged, used verbatim by the new PERSONAS loop:
```bash
install_link() {
  local src="$1" dst="$2"
  backup_if_real "$dst"
  [[ -L "$dst" ]] && rm "$dst"
  ln -s "$src" "$dst"
  ok "linked $dst → $src"
}

remove_target() {
  local target="$1"
  if [[ -L "$target" || -e "$target" ]]; then
    rm -rf "$target"
    ok "removed $target"
  fi
}
```

---

### `hooks/patch-settings.js` (utility script, transform — NEW FILE)

**Analog:** `install.sh` inline Node.js heredocs (lines 105-147 for install, lines 155-196 for uninstall)

This is an extraction, not a greenfield file. The full logic already exists as two heredoc blocks in install.sh. The new file must preserve exact behavioral parity.

**File shebang and require pattern** (copy from `hooks/council-check-update.js` lines 1-5):
```js
#!/usr/bin/env node
// council-code — settings.json patcher
//
// Extracted from install.sh. Called by install.sh and future council installers.
// Usage: node patch-settings.js --install|--uninstall --settings PATH [--statusline CMD] [--hook CMD] [--next-file PATH]

const fs = require('fs');
const path = require('path');
```

**argv parsing pattern** (no npm deps — manual scan matching the style in existing hooks):
```js
const argv = process.argv.slice(2);
const get = (flag) => { const i = argv.indexOf(flag); return i !== -1 ? argv[i + 1] : null; };
const has = (flag) => argv.includes(flag);

const settingsFile = get('--settings');
const nextFile     = get('--next-file');
const statuslineCmd = get('--statusline');
const hookCmd      = get('--hook');
const isInstall    = has('--install');
const isUninstall  = has('--uninstall');
```

**Install logic** — extracted verbatim from install.sh lines 106-146. Key invariants to preserve:

```js
// Backup before mutate (line 114-115 of install.sh heredoc)
const backup = `${settingsFile}.bak.${Date.now()}`;
if (raw) fs.writeFileSync(backup, raw);

// statusLine delegation chain (lines 123-131)
const existing = (cfg.statusLine.command || '').trim();
if (existing && existing !== wrapperCmd) {
  fs.writeFileSync(nextFile, existing + '\n');
  console.log(`  preserved previous statusLine → ${nextFile}`);
}
cfg.statusLine.type = 'command';
cfg.statusLine.command = wrapperCmd;

// Idempotent SessionStart append (lines 136-143) — the `.some()` check string
// 'council-check-update.js' MUST survive verbatim
const already = cfg.hooks.SessionStart.some(group =>
  (group.hooks || []).some(h => (h.command || '').includes('council-check-update.js'))
);
if (!already) {
  cfg.hooks.SessionStart.push({
    hooks: [{ type: 'command', command: checkCmd }],
  });
}
```

**Uninstall logic** — extracted verbatim from install.sh lines 155-196. Key invariants:

```js
// statusLine restore (lines 168-179)
if (cfg.statusLine && typeof cfg.statusLine.command === 'string' &&
    cfg.statusLine.command.includes('council-statusline.js')) {
  let restored = '';
  try { restored = fs.readFileSync(nextFile, 'utf8').trim(); } catch (e) {}
  if (restored) {
    cfg.statusLine.command = restored;
  } else {
    delete cfg.statusLine;
  }
}

// SessionStart removal using filter (lines 182-190)
cfg.hooks.SessionStart = cfg.hooks.SessionStart
  .map(group => ({
    ...group,
    hooks: (group.hooks || []).filter(h => !(h.command || '').includes('council-check-update.js')),
  }))
  .filter(group => (group.hooks || []).length > 0);
if (cfg.hooks.SessionStart.length === 0) delete cfg.hooks.SessionStart;
```

**Error handling pattern** (copy from install.sh heredoc lines 117-121):
```js
let cfg = {};
try { cfg = JSON.parse(raw || '{}'); } catch (e) {
  console.error(`settings.json is not valid JSON — refusing to patch. Backup at ${backup}`);
  process.exit(1);
}
```

**Output pattern** (match install.sh heredoc console.log style — indented with two spaces):
```js
fs.writeFileSync(settingsFile, JSON.stringify(cfg, null, 2) + '\n');
console.log(`  patched ${settingsFile} (backup: ${backup})`);
```

---

## Shared Patterns

### Backup-Before-Mutate
**Source:** `install.sh` lines 46-52 (shell) and lines 113-115 (Node heredoc)
**Apply to:** `hooks/patch-settings.js` — preserve the `Date.now()` timestamp suffix for the settings.json backup

```bash
# Shell variant (install.sh lines 46-52)
backup_if_real() {
  local target="$1"
  if [[ -e "$target" && ! -L "$target" ]]; then
    mv "$target" "$target.bak.$(date +%Y%m%d%H%M%S)"
    warn "existing $target moved to .bak"
  fi
}
```

```js
// Node variant (install.sh heredoc line 114) — use in patch-settings.js
const backup = `${file}.bak.${Date.now()}`;
if (raw) fs.writeFileSync(backup, raw);
```

### have_node Guard
**Source:** `install.sh` lines 82-84 and 97-99
**Apply to:** Both `patch_settings_install` and `patch_settings_uninstall` replacements in install.sh

```bash
have_node() {
  command -v node >/dev/null 2>&1
}

# Usage in functions:
have_node || { warn "node not found — skipping settings.json patch (statusline + SessionStart hook will NOT be wired)"; return 0; }
```

### Node.js Stdlib-Only Pattern
**Source:** `hooks/council-check-update.js` lines 15-19, `hooks/council-statusline.js` lines 18-22
**Apply to:** `hooks/patch-settings.js` — no npm requires, only Node.js stdlib

```js
const fs = require('fs');
const path = require('path');
const os = require('os');
```

### Array-Driven Install Loop
**Source:** `install.sh` lines 207-249
**Apply to:** The updated PERSONAS and HOOKS arrays — no `.md` suffix in array entries; the loop appends it

```bash
PERSONAS=( code-contrarian code-first-principles code-expansionist code-outsider code-executor )
for persona in "${PERSONAS[@]}"; do
  install_link "$REPO_ROOT/agents/$persona.md" "$AGENTS_DIR/$persona.md"
done
```

### Agent Frontmatter Structure
**Source:** `agents/contrarian.md` lines 1-5
**Apply to:** All 5 renamed agent files — `name:`, `description:`, `tools:` in that order

```yaml
---
name: <council>-<role>
description: <one-sentence purpose>
tools: Read, Grep, Glob, WebSearch, WebFetch
---
```

## No Analog Found

All files in this phase have direct analogs. No new patterns need to be sourced from RESEARCH.md.

| File | Role | Data Flow | Reason |
|------|------|-----------|--------|
| — | — | — | — |

## Metadata

**Analog search scope:** `/Users/D052192/src/council-code/` (all directories)
**Files read:** install.sh, skills/council-code/SKILL.md, agents/contrarian.md, hooks/council-statusline.js, hooks/council-check-update.js, .claude-plugin/plugin.json
**Pattern extraction date:** 2026-04-23
