# Phase 1: Foundation - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-04-23
**Phase:** 1-foundation
**Areas discussed:** Agent rename strategy, Settings patcher extraction, Backward compatibility approach

---

## Agent rename strategy

| Option | Description | Selected |
|--------|-------------|----------|
| Hard cutover | Rename files to code-*.md in repo AND install.sh. Old bare-name symlinks removed on re-run. No shims. | ✓ |
| Compatibility shims | Rename in repo, create bare-name symlinks for one release cycle. | |
| Dual names | Keep bare names, add code-* aliases. Both exist forever. | |

**User's choice:** Hard cutover
**Notes:** Clean, no cruft. Users must re-run install.sh.

### Follow-up: Uninstall cleanup

| Option | Description | Selected |
|--------|-------------|----------|
| Clean both | --uninstall removes both bare-name and code-prefixed files | ✓ |
| Only clean new names | Only remove code-* names, orphan bare-name files remain | |

**User's choice:** Clean both
**Notes:** Drop bare-name cleanup after one release cycle.

---

## Settings patcher extraction

| Option | Description | Selected |
|--------|-------------|----------|
| CLI tool with --install/--uninstall | Extract to hooks/patch-settings.js as CLI. install.sh calls it with flags. | ✓ |
| Module with exported functions | Export functions, invoke via node -e. More flexible, more complex. | |
| You decide | Let Claude decide the extraction approach. | |

**User's choice:** CLI tool with --install/--uninstall
**Notes:** Simple contract: one script, two modes.

### Follow-up: Single vs separate scripts

| Option | Description | Selected |
|--------|-------------|----------|
| Single script, flag-driven | One patch-settings.js handles all mutations. Callers pass flags. | ✓ |
| Separate scripts per concern | patch-statusline.js and patch-hooks.js. Each does one thing. | |

**User's choice:** Single script, flag-driven
**Notes:** One entry point, one backup cycle per run.

---

## Backward compatibility approach

| Option | Description | Selected |
|--------|-------------|----------|
| Update references only | Keep skills/council-code/, update agent refs in SKILL.md | |
| Rename skill directory too | Rename to new namespace pattern | |

**User's choice:** Other — "I always want to have council first to be able to have all of them in a group like gsd"
**Notes:** Naming convention is council-* prefix for all skills (council-code, council-strategy, etc.). The existing directory already follows this pattern. Only internal agent references need updating. Also add disable-model-invocation: true to frontmatter.

---

## Claude's Discretion

- Exact flag interface design for patch-settings.js
- Backup naming convention for settings.json
- MIGRATION.md or CHANGELOG wording

## Deferred Ideas

None — discussion stayed within phase scope
