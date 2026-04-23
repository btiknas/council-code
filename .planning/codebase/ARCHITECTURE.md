# Architecture — council-code

**Mapped:** 2026-04-23

## Pattern

**Plugin architecture** — Claude Code plugin with skill orchestrator + subagent delegation.

The system has no runtime code of its own. It's a collection of prompt documents (Markdown) that Claude Code's runtime interprets:
1. **Skills** define workflows (how to orchestrate)
2. **Agents** define personas (how to think)
3. **Hooks** provide background automation (JavaScript)

## Components

```
┌─────────────────────────────────────────────────┐
│              Claude Code Runtime                 │
│                                                  │
│  ┌──────────────────┐   ┌────────────────────┐  │
│  │  SKILL.md         │   │  Agent Tool         │  │
│  │  (orchestrator)   │──▶│  (5 parallel calls) │  │
│  └──────────────────┘   └────────┬───────────┘  │
│                                  │               │
│    ┌─────────┬─────────┬─────────┼─────────┐    │
│    ▼         ▼         ▼         ▼         ▼    │
│  contra-  first-   expansion  outsider  executor │
│  rian.md  princ.md  ist.md    .md       .md      │
│                                                  │
│  ┌──────────────────┐                            │
│  │  Hooks (JS)       │ SessionStart, statusLine  │
│  └──────────────────┘                            │
└─────────────────────────────────────────────────┘
```

## Data Flow

1. User invokes `/council-code` or trigger phrase
2. Orchestrator (SKILL.md) extracts decision prompt + context
3. 5 Agent tool calls spawned **in parallel** (single message)
4. Each agent reads context, produces structured analysis via its output format
5. Orchestrator receives all 5 results
6. Chairman synthesis produced with agreements, clashes, blind spots, recommendation

## Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| Parallel-only spawning | Prevents anchoring — advisors must not see each other's output |
| 5 personas (no more, no less) | Enough for diversity, few enough for tractable synthesis |
| Self-contained persona files | Portable — can be used standalone outside the council |
| No code execution | Pure prompt engineering — zero runtime dependencies beyond Claude Code |
| Hooks in Node.js | Claude Code hooks run as shell commands; Node.js provides safe JSON handling |

## Entry Points

| Entry Point | Trigger |
|-------------|---------|
| `skills/council-code/SKILL.md` | `/council`, trigger phrases |
| `skills/council-update/SKILL.md` | `/council-update` |
| `hooks/council-check-update.js` | SessionStart event |
| `hooks/council-statusline.js` | statusLine rendering |
| `install.sh` | Manual installation |
