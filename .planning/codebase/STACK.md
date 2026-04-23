# Stack — council-code

**Mapped:** 2026-04-23

## Languages

- **Markdown** — Primary language for all agent definitions, skills, and documentation
- **JavaScript (Node.js)** — Hooks and installer automation
- **Bash** — `install.sh` installer script

## Runtime

- **Claude Code** — Plugin runtime (skills, agents, hooks)
- **Node.js >= 14** — Required for hooks (`child_process`, `fs`, `path`)

## Package Manager

- No `package.json` — this is not an npm package
- `.claude-plugin/plugin.json` defines the plugin manifest (name, version `0.4.0`, description)
- `.claude-plugin/marketplace.json` — marketplace listing metadata

## Dependencies

- **Zero runtime dependencies** — pure Node.js stdlib (`fs`, `path`, `os`, `child_process`)
- **Claude Code** — host runtime provides Agent tool, AskUserQuestion, Bash, Read, etc.
- **Git** — required for update-check hooks and installer

## Configuration

| File | Purpose |
|------|---------|
| `.claude-plugin/plugin.json` | Plugin manifest with version, name, keywords |
| `.claude-plugin/marketplace.json` | Marketplace listing metadata |
| `.mcp.json` | MCP server configuration (currently empty/placeholder) |
| `CLAUDE.md` | Project context document for Claude Code sessions |

## Versioning

- Semantic versioning via `plugin.json` → currently `0.4.0`
- Updates distributed via `git pull` (symlink install) or re-running `install.sh --copy`
