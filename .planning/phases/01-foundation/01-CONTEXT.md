# Phase 1: Foundation - Context

**Gathered:** 2026-04-23
**Status:** Ready for planning

<domain>
## Phase Boundary

Agent namespace refactor + installer refactor — the pre-conditions for extending the system with new councils. Renames existing agent files to council-prefixed names, extracts the settings.json patcher to a reusable script, adds `disable-model-invocation: true` to SKILL.md frontmatter, and ensures `/council-code` and `/council` triggers work identically after all changes.

</domain>

<decisions>
## Implementation Decisions

### Agent rename strategy
- **D-01:** Hard cutover — rename all 5 agent files from bare names (`contrarian.md`) to code-prefixed names (`code-contrarian.md`) in the repo and in install.sh. No compatibility shims, no dual names.
- **D-02:** install.sh re-run cleans up old bare-name symlinks/copies from `~/.claude/agents/`. Users must re-run install.sh after updating.
- **D-03:** install.sh `--uninstall` removes both old bare-name AND new code-prefixed files to handle users who installed before the rename. Drop bare-name cleanup after one release cycle.

### Settings patcher extraction
- **D-04:** Extract inline Node.js heredoc from install.sh to a standalone `hooks/patch-settings.js` CLI tool with `--install` and `--uninstall` modes.
- **D-05:** Single script, flag-driven — one `patch-settings.js` handles all settings.json mutations (statusline wiring, SessionStart hook registration, future needs). Callers pass flags like `--statusline`, `--hook "command"`.
- **D-06:** Each future council installer calls the same `patch-settings.js` — it's the shared entry point for settings.json mutations across all councils.

### Backward compatibility
- **D-07:** Skill naming convention is `council-*` prefix (like `gsd-*`): `council-code`, `council-strategy`, `council-design`, etc. The existing `skills/council-code/` directory and skill name already follow this pattern — no rename needed.
- **D-08:** SKILL.md internal references updated from `agents/contrarian.md` to `agents/code-contrarian.md` (and all other agents). Triggers `/council-code` and `/council` continue to work identically.
- **D-09:** Add `disable-model-invocation: true` to council-code SKILL.md frontmatter per FOUND-03.

### Claude's Discretion
- Exact flag interface design for patch-settings.js (argument parsing, validation, error messages)
- Whether patch-settings.js uses a JSON config input or purely CLI flags
- Exact backup naming convention for settings.json backups
- MIGRATION.md or CHANGELOG entry wording for the rename

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Existing codebase
- `install.sh` — Current installer with inline settings.json patching (~60 lines of Node.js heredoc), persona arrays, and symlink/copy logic
- `skills/council-code/SKILL.md` — Current orchestrator skill with agent references that need updating
- `.claude-plugin/plugin.json` — Plugin manifest (version, metadata)
- `agents/contrarian.md` — Example agent file showing current frontmatter structure (name, description, tools fields)

### Hooks
- `hooks/council-statusline.js` — Statusline wrapper that delegates to previous statusline
- `hooks/council-check-update.js` — SessionStart hook for update checking
- `hooks/council-check-update-worker.js` — Worker for update check

No external specs — requirements are fully captured in decisions above and REQUIREMENTS.md (FOUND-01 through FOUND-04).

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `install.sh` — Mature installer with symlink/copy modes, backup logic (`backup_if_real`), and idempotent behavior. The patcher extraction refactors its internals but the shell functions stay.
- `hooks/council-statusline.js` — Delegates to previous statusline via `council-statusline-next.txt`. This delegation pattern is preserved.
- `hooks/council-check-update.js` + worker — SessionStart hook. Already a standalone file — no changes needed.

### Established Patterns
- **Symlink-first install**: Default mode is symlink (git pull to update), `--copy` as alternative. All new councils should follow this pattern.
- **Backup before mutate**: `backup_if_real()` backs up non-symlink files before replacing. `patch_settings_install` creates timestamped backups of settings.json.
- **Agent frontmatter**: Each agent `.md` has YAML frontmatter with `name`, `description`, `tools` fields.

### Integration Points
- `~/.claude/agents/` — Where agent files are installed (symlinked or copied)
- `~/.claude/skills/` — Where skill directories are installed
- `~/.claude/hooks/` — Where hook scripts are installed
- `~/.claude/settings.json` — Mutated by patcher for statusline and hooks

</code_context>

<specifics>
## Specific Ideas

- Naming convention is `council-*` prefix for skills (like `gsd-*`) — user wants all council skills grouped together in listings
- Agent files use `{council}-{persona}.md` pattern: `code-contrarian.md`, `code-executor.md`, etc.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 01-foundation*
*Context gathered: 2026-04-23*
