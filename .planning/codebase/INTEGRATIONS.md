# Integrations — council-code

**Mapped:** 2026-04-23

## External Services

### GitHub

- **Repository:** `https://github.com/btiknas/council-code.git`
- **Used by:** `hooks/council-check-update.js` — fetches `origin/main` to detect new versions
- **Used by:** `skills/council-update/SKILL.md` — fast-forward pulls from origin
- **Protocol:** Git over HTTPS (SSH also supported per README)

## Claude Code Integration

### Plugin System

- Registered via `.claude-plugin/plugin.json`
- Skills exposed: `council-code` (main orchestrator), `council-update` (updater)
- Agents exposed: 5 persona definitions in `agents/`

### Hooks

| Hook | Event | Purpose |
|------|-------|---------|
| `council-check-update.js` | `SessionStart` | Background `git fetch` to detect updates |
| `council-check-update-worker.js` | (spawned by above) | Detached process for non-blocking fetch |
| `council-statusline.js` | `statusLine` | Shows update badge + delegates to other statusline |

### Cache

- `~/.cache/council-code/update-check.json` — debounced (1h) update check result
- Contains: `update_available`, `local_ahead`, `checked_at`, `behind_count`, `commits`

## No External APIs

- No REST/GraphQL API calls
- No database connections
- No auth providers
- No webhooks
- Entirely file-system and git based
