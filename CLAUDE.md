# council-code — Claude Code context

This repo is a Claude Code plugin that provides a **five-advisor code decision council**.

## Structure

```
council-code/
├── .claude-plugin/plugin.json    # Plugin manifest
├── agents/                        # 5 persona subagent definitions
│   ├── contrarian.md
│   ├── first-principles.md
│   ├── expansionist.md
│   ├── outsider.md
│   └── executor.md
├── skills/council-code/SKILL.md   # Orchestrator skill (entry point)
├── docs/                          # Extended persona notes + examples
├── hooks/                         # (reserved for future hooks)
├── mcp-server/                    # (reserved for future MCP integration)
└── README.md                      # User-facing install + usage
```

## How it works

The skill at `skills/council-code/SKILL.md` is the entry point. When triggered (via `/council`, "second opinion," "stress test this," etc.) it:

1. Extracts a clean decision prompt + relevant context from the conversation
2. Spawns all 5 advisors **in parallel** (same message, 5 Task tool calls) to prevent anchoring
3. Receives their independent analyses
4. Synthesizes a chairman verdict: agreements, clashes, blind spots, recommendation, first action

Each advisor is a standalone subagent definition in `agents/` — they can also be invoked individually (e.g. "get the Contrarian view on X") without running the full council.

## Development notes

- **Don't add a 6th permanent advisor.** Five is deliberate — enough for diversity, few enough that synthesis stays tractable.
- **Persona files are self-contained.** Each `agents/<name>.md` has frontmatter + full instruction body. Keep them portable so users can copy one persona standalone if they want.
- **The skill orchestrator stays thin.** Logic lives in the persona prompts, not in the orchestrator. Editing a persona shouldn't require editing `SKILL.md`.
- **Code-focused for now.** Future siblings (`council-strategy`, `council-design`, etc.) will share the same 5-persona shape but with different domain framing.
