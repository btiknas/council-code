# Structure — council-code

**Mapped:** 2026-04-23

## Directory Layout

```
council-code/
├── .claude-plugin/
│   ├── plugin.json              # Plugin manifest (name, version, description)
│   └── marketplace.json         # Marketplace listing metadata
├── agents/                      # 5 persona subagent definitions
│   ├── contrarian.md            # Fatal flaw finder
│   ├── first-principles.md      # Problem reducer
│   ├── expansionist.md          # Upside seeker
│   ├── outsider.md              # Cross-domain importer
│   └── executor.md              # Monday-morning shipper
├── skills/
│   ├── council-code/
│   │   └── SKILL.md             # Main orchestrator skill
│   └── council-update/
│       └── SKILL.md             # Update checker skill
├── hooks/
│   ├── council-check-update.js  # SessionStart update check
│   ├── council-check-update-worker.js  # Detached fetch worker
│   ├── council-statusline.js    # Statusline badge renderer
│   └── README.md
├── docs/
│   ├── personas.md              # Extended persona design notes
│   └── usage.md                 # Example transcripts
├── .claude/
│   └── README.md
├── mcp-server/
│   └── README.md                # Reserved for future MCP integration
├── install.sh                   # User-level installer (symlink/copy/uninstall)
├── CLAUDE.md                    # Project context for Claude Code
├── README.md                    # User-facing docs
├── LICENSE                      # MIT
├── SECURITY.md                  # Security policy
├── .mcp.json                    # MCP config placeholder
└── .gitignore
```

## Key Locations

| What | Where |
|------|-------|
| Agent definitions | `agents/*.md` |
| Main skill | `skills/council-code/SKILL.md` |
| Update skill | `skills/council-update/SKILL.md` |
| Hooks | `hooks/*.js` |
| Plugin manifest | `.claude-plugin/plugin.json` |
| Installer | `install.sh` |
| Design docs | `docs/personas.md`, `docs/usage.md` |

## Naming Conventions

- **Agent files:** lowercase, hyphenated (`first-principles.md`)
- **Hook files:** `council-` prefix, kebab-case (`council-check-update.js`)
- **Skills:** kebab-case directories with `SKILL.md` inside
- **Templates/docs:** UPPERCASE.md for important files, lowercase for supporting docs
