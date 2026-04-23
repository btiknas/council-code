# Concerns — council-code

**Mapped:** 2026-04-23

## Technical Debt

### Missing Agent Definitions for Subagent Types
The SKILL.md references `subagent_type: general-purpose` for spawning advisors, but the actual agent `.md` files have specific `subagent_type` names in their frontmatter (e.g., `contrarian`, `executor`). The orchestrator doesn't explicitly reference the subagent types from the persona files — it uses `general-purpose` and includes the role instructions in the prompt. This works but means the dedicated agent type registrations in frontmatter are informational rather than functional.

### Broken Pre-Push Hook
The `.git/hooks/pre-push` referenced a non-existent `.git/hooks/h` file (likely leftover from Husky setup). Has been manually removed but root cause (Husky misconfiguration) may recur if Husky is ever re-added.

### Reserved Directories Empty
- `mcp-server/` — reserved for future MCP integration, contains only README.md
- `hooks/README.md` — placeholder

## Known Issues

### No Version Pinning
The update mechanism (`council-update`) always fast-forwards to `origin/main`. There's no way to pin to a specific version or skip a breaking update. If a bad commit lands on main, all users auto-see the update badge.

### Copy-Mode Install Staleness
Users who install with `--copy` don't get automatic update detection. The update-check hook can't resolve the repo path since there's no symlink to follow. These users must manually re-run `install.sh --copy`.

## Security

- **No secrets in codebase** — pure prompt engineering
- `install.sh` patches `~/.claude/settings.json` — always creates a timestamped backup first
- Hooks execute with user privileges (no elevation)
- `council-check-update-worker.js` spawns detached processes — cleanup relies on process exit

## Fragile Areas

### Settings.json Patching (`install.sh`)
The Node.js inline scripts that patch `settings.json` are complex:
- Must preserve existing hooks (GSD SessionStart entries)
- Must preserve existing statusLine (delegation chain)
- Must handle missing/empty/malformed JSON gracefully
- Edge case: concurrent installs could corrupt the file

### Statusline Delegation Chain
`council-statusline.js` reads a delegate command from `council-statusline-next.txt` and pipes stdin JSON to it. If the delegate command changes format or crashes, the statusline silently degrades. No health check for the delegate.
