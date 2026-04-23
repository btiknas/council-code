# Architecture Patterns — Multi-Council Decision System

**Domain:** Claude Code plugin — multi-council orchestration
**Researched:** 2026-04-23
**Confidence:** HIGH (current official docs verified)

---

## System Overview

The system is a **pure-Markdown plugin** running inside Claude Code. There is no compiled runtime — Claude Code's skill/agent/hook primitives are the execution layer. The multi-council extension adds a routing layer on top of the existing single-council orchestrator pattern.

### The Two-Layer Model

```
Layer 1 — Router (new)
  Classifies the question → suggests council → user confirms

Layer 2 — Council Orchestrator (existing, replicated per domain)
  Spawns ~5 advisors in parallel → synthesizes chairman verdict
```

These layers are independent. The router is a skill that calls another skill. Each council orchestrator is self-contained and works without the router (backward compatibility preserved).

---

## Components

### Component Map

```
council-code/
│
├── Router (new)
│   └── skills/council-router/SKILL.md
│       Classifies questions, suggests correct council, dispatches on confirm.
│       Communicates with: user (for confirmation), then delegates to council skill.
│
├── Council Orchestrators (one per domain)
│   ├── skills/council-code/SKILL.md       ← existing
│   ├── skills/council-strategy/SKILL.md   ← new
│   ├── skills/council-design/SKILL.md     ← new
│   ├── skills/council-research/SKILL.md   ← new
│   └── skills/council-review/SKILL.md     ← new
│       Each orchestrator: reads context → spawns 5 advisors in parallel → synthesizes.
│       Communicates with: advisor agents (via Task tool), user (chairman output).
│
├── Advisor Rosters (5 agents per council)
│   ├── agents/contrarian.md               ← existing (code-focus)
│   ├── agents/first-principles.md         ← existing (code-focus)
│   ├── agents/expansionist.md             ← existing (code-focus)
│   ├── agents/outsider.md                 ← existing (code-focus)
│   ├── agents/executor.md                 ← existing (code-focus)
│   ├── agents/strategy-*.md               ← new (strategy-focus personas)
│   ├── agents/design-*.md                 ← new (design-focus personas)
│   ├── agents/research-*.md               ← new (research-focus personas)
│   └── agents/review-*.md                 ← new (review-focus personas)
│       Each agent: self-contained subagent definition (frontmatter + persona body).
│       Communicates with: nobody (parallel, no anchoring).
│
├── Hooks
│   ├── hooks/council-check-update.js      ← existing (SessionStart)
│   ├── hooks/council-check-update-worker.js ← existing
│   ├── hooks/council-statusline.js        ← existing (statusLine)
│   └── hooks/council-git-trigger.js       ← new (PreToolUse on git ops)
│       Hooks communicate with: Claude Code runtime via stdin/stdout JSON.
│
└── Installer
    └── install.sh
        Communicates with: ~/.claude/ filesystem, settings.json.
```

### Component Responsibilities

| Component | Responsibility | Communicates With |
|-----------|---------------|-------------------|
| `council-router` skill | Classify question type, recommend council, dispatch after confirm | User (confirm dialog), council skills (via delegation) |
| `council-*` orchestrator skills | Extract decision, spawn advisors in parallel, chairman synthesis | Task tool (spawns advisors), user (output) |
| `agents/<role>.md` | Single-lens analysis from specific advisory perspective | Nothing (receives context, returns structured analysis) |
| `council-git-trigger.js` hook | Detect git commits/PRs, prompt council invocation | Claude Code runtime (PreToolUse/PostToolUse events) |
| `council-check-update.js` | Detect available updates, write cache | Filesystem (cache), git (origin/main) |
| `council-statusline.js` | Render update badge in statusline | Filesystem (cache), delegate statusline |
| `install.sh` | Symlink/copy all assets into `~/.claude/`, patch `settings.json` | Filesystem, Node.js (JSON patching) |

---

## Data Flow

### Primary Flow: Routed Council Invocation

```
User input
  │
  ▼
council-router/SKILL.md
  │  1. Classifies question ("this is a strategy question")
  │  2. Recommends council ("suggest: council-strategy")
  │  3. Waits for user confirmation ("run council-strategy? [y/n/other]")
  │
  ├─ confirmed ──▶  council-<domain>/SKILL.md
  │                   │  1. Extracts decision prompt + context
  │                   │  2. Spawns 5 advisors in parallel (Task tool)
  │                   │
  │                   ├──▶ agents/advisor-1.md  ──▶ structured analysis
  │                   ├──▶ agents/advisor-2.md  ──▶ structured analysis
  │                   ├──▶ agents/advisor-3.md  ──▶ structured analysis
  │                   ├──▶ agents/advisor-4.md  ──▶ structured analysis
  │                   └──▶ agents/advisor-5.md  ──▶ structured analysis
  │                   │
  │                   ▼
  │                  Chairman synthesis
  │                  (agreements, clashes, blind spots, recommendation, first action)
  │
  └─ overridden ──▶  council-<other>/SKILL.md   (user picks different council)
```

### Direct Invocation Flow (backward-compatible)

```
User: "/council-code" or trigger phrase
  │
  ▼
council-code/SKILL.md  (no router involved)
  │
  └─ same parallel spawn + synthesis as above
```

### Git Hook Trigger Flow (new)

```
User runs: git commit / git push / opens PR
  │
  ▼
council-git-trigger.js (PreToolUse hook, matcher: "Bash(git commit*|git push*)")
  │  1. Detects git operation
  │  2. Identifies changed files / commit scope
  │  3. Injects context into Claude: "This is a significant commit — run /council-review?"
  │
  ▼
User can invoke /council-review with pre-populated context
```

### Hook-to-Settings Integration

```
install.sh
  │  Reads existing ~/.claude/settings.json
  │  Appends SessionStart hook entry (council-check-update.js)
  │  Replaces statusLine command (council-statusline.js, delegates to previous)
  │  Saves settings.json
  │
  ▼
SessionStart (each Claude Code session)
  └─ council-check-update.js ──▶ detached worker ──▶ git fetch ──▶ cache write

statusLine render
  └─ council-statusline.js ──▶ reads cache ──▶ badge + delegate output
```

---

## Project Structure (Target State)

```
council-code/
├── .claude-plugin/
│   └── plugin.json                    # Version bump needed for new councils
├── agents/
│   ├── contrarian.md                  # EXISTING — code focus
│   ├── first-principles.md            # EXISTING — code focus
│   ├── expansionist.md                # EXISTING — code focus
│   ├── outsider.md                    # EXISTING — code focus
│   ├── executor.md                    # EXISTING — code focus
│   ├── strategy-market-analyst.md     # NEW
│   ├── strategy-risk-assessor.md      # NEW
│   ├── strategy-growth-hacker.md      # NEW
│   ├── strategy-operator.md           # NEW
│   ├── strategy-skeptic.md            # NEW
│   ├── design-ux-researcher.md        # NEW
│   ├── design-system-thinker.md       # NEW
│   ├── design-accessibility.md        # NEW
│   ├── design-motion-critic.md        # NEW
│   ├── design-pragmatist.md           # NEW
│   ├── research-domain-expert.md      # NEW
│   ├── research-skeptic.md            # NEW
│   ├── research-historian.md          # NEW
│   ├── research-practitioner.md       # NEW
│   ├── research-synthesizer.md        # NEW
│   ├── review-security-auditor.md     # NEW
│   ├── review-performance-critic.md   # NEW
│   ├── review-readability.md          # NEW
│   ├── review-test-coverage.md        # NEW
│   └── review-architect.md            # NEW
├── skills/
│   ├── council-code/SKILL.md          # EXISTING
│   ├── council-update/SKILL.md        # EXISTING
│   ├── council-router/SKILL.md        # NEW — classifier + dispatcher
│   ├── council-strategy/SKILL.md      # NEW
│   ├── council-design/SKILL.md        # NEW
│   ├── council-research/SKILL.md      # NEW
│   └── council-review/SKILL.md        # NEW
├── hooks/
│   ├── council-check-update.js        # EXISTING
│   ├── council-check-update-worker.js # EXISTING
│   ├── council-statusline.js          # EXISTING
│   └── council-git-trigger.js         # NEW — git op detector
├── docs/
│   ├── personas.md                    # EXISTING (extend with new councils)
│   └── usage.md                       # EXISTING (extend with examples)
├── install.sh                         # EXISTING — extend for new skills/agents/hooks
└── README.md                          # EXISTING — update for new councils
```

---

## Patterns to Follow

### Pattern 1: Self-Contained Advisor

Each advisor agent is fully portable. It receives a standardized brief, produces a standardized output format, and references nothing outside itself.

**What:** The agent file has all context it needs in its frontmatter + body. No shared state.
**When:** Every new advisor in every new council.
**Key property:** The same advisor can be invoked standalone ("get the Strategy Skeptic's view on X") or as part of a council run.

Agent frontmatter structure:
```yaml
---
name: <council>-<role>
description: <one-line description of lens + domain>
tools: Read, Grep, Glob, WebSearch, WebFetch
---
```

### Pattern 2: Thin Orchestrator

The council SKILL.md holds protocol, not persona logic. Step 1 (extract), Step 2 (spawn parallel), Step 3 (synthesize) — that's all. The substance lives in the agents.

**What:** Orchestrator contains the parallel-spawn protocol and output format. Persona logic stays in agents/.
**When:** Every council skill.
**Key property:** Editing a persona never requires editing the orchestrator.

### Pattern 3: Router as Suggest-and-Confirm

The router classifies but never auto-dispatches without user confirmation.

**What:** Router outputs: "(1) classified as: X (2) recommended council: Y (3) confirm? [y / n / pick different]"
**When:** Any invocation that enters via `/council` without a specific council suffix.
**Key property:** User always retains control. Router adds intelligence without removing agency.

### Pattern 4: Install Idempotency

The installer is re-runnable. Installing twice produces the same result as installing once. New councils are registered by extending arrays in install.sh, not by modifying the install logic.

```bash
# In install.sh, extend these arrays — no logic changes needed:
SKILLS=( council-code council-update council-router council-strategy ... )
PERSONAS=( contrarian first-principles ... strategy-market-analyst ... )
HOOKS=( council-statusline.js council-check-update.js council-git-trigger.js )
```

### Pattern 5: Hook Composition via Delegation

Hooks preserve pre-existing configuration by saving and delegating, never replacing outright. The statusline hook already does this. The git trigger hook should follow the same pattern: append to existing PreToolUse rules, don't overwrite.

---

## Anti-Patterns to Avoid

### Anti-Pattern 1: Cross-Advisor Communication

**What:** Advisor A reads Advisor B's output before writing its own.
**Why bad:** Destroys independence. Advisor B anchors on A's framing. Reduces diversity of the council to near-zero.
**Instead:** All 5 Task tool calls in a single parallel batch. Never sequential.

### Anti-Pattern 2: Router Auto-Dispatch

**What:** Router sees "this is a strategy question" and immediately runs the strategy council without user confirmation.
**Why bad:** Wastes 5+ subagent runs if the user wanted a different council or didn't want a council at all. User loses control.
**Instead:** Router presents a suggestion with a confirmation step. "Looks like a strategy question — run council-strategy? [y / different council / cancel]"

### Anti-Pattern 3: Shared Advisor Files Across Councils

**What:** Using the same `contrarian.md` for both code and strategy councils with a domain parameter.
**Why bad:** Domain context matters enormously for advisor effectiveness. A "code contrarian" who finds race conditions is useless for evaluating a pricing strategy. Skill dilution.
**Instead:** Separate agent files per council with domain-specific mandates and output formats. Naming: `agents/strategy-skeptic.md` not `agents/contrarian.md` with a flag.

### Anti-Pattern 4: Monolithic Council Skill

**What:** One SKILL.md contains both the orchestration protocol and the full advisor personas inline.
**Why bad:** Any persona edit requires editing the orchestrator. Users can't invoke a single persona standalone.
**Instead:** Orchestrator is < 150 lines of pure protocol. Personas live in separate agent files referenced by name.

### Anti-Pattern 5: Install Mutation of Core Settings

**What:** install.sh overwrites the entire `settings.json` hooks section.
**Why bad:** Destroys other tools' hooks (GSD, user's custom hooks, etc.).
**Instead:** Append-only writes with identity checks. The existing install.sh already demonstrates this correctly — preserve the pattern.

### Anti-Pattern 6: Router Council Becomes 6th Council

**What:** Treating the router as a regular council with its own advisor roster.
**Why bad:** The router's job is classification + dispatch, not deliberation. Adding advisors to it creates a meta-council overhead that delivers no user value.
**Instead:** The router is a thin classifier skill. No advisors, no synthesis. One output: which council to run.

---

## Suggested Build Order

Dependencies between components determine build order:

```
Phase 1 — Foundation (no dependencies)
  ├── agent files for new councils (each is independent)
  └── These are the leaves — no component depends on them yet

Phase 2 — Council Orchestrators (depend on: agent files existing)
  ├── skills/council-strategy/SKILL.md
  ├── skills/council-design/SKILL.md
  ├── skills/council-research/SKILL.md
  └── skills/council-review/SKILL.md
  Each skill references its agents — agents must exist first.

Phase 3 — Router (depends on: all council skills existing)
  └── skills/council-router/SKILL.md
  Router suggests councils by name — all councils must exist first,
  or router must be scoped to councils that already exist.

Phase 4 — Install Expansion (depends on: all new files existing)
  └── install.sh — extend arrays, re-run tests
  Installer references filenames — all files must exist.

Phase 5 — Git Hook Trigger (independent of Phase 1-4)
  └── hooks/council-git-trigger.js
  Can be built at any point since it hooks into PreToolUse on Bash,
  not into specific council skills.
```

Note: Phases 1-3 can be done council-by-council. "Ship council-strategy" before "ship council-design." The router can be added after 2+ councils exist and updated as more are added.

---

## Integration Points with Existing System

| Existing Component | How New System Integrates |
|-------------------|--------------------------|
| `skills/council-code/SKILL.md` | Unchanged. Backward-compatible direct invocation preserved. |
| `agents/contrarian.md` etc. | Unchanged. New council agents are in separate files with new names. |
| `install.sh` | Arrays extended (SKILLS, PERSONAS, HOOKS). Logic unchanged. |
| `hooks/council-check-update.js` | Unchanged. No interaction with new councils. |
| `hooks/council-statusline.js` | Unchanged. No interaction with new councils. |
| `settings.json` patch logic | `patch_settings_install` extended to add PreToolUse entry for git trigger hook. |

---

## Scalability Considerations

| Concern | Current (1 council) | Target (5 councils + router) | Future (10+ councils) |
|---------|--------------------|-----------------------------|----------------------|
| Agent files | 5 | ~25 | ~50 |
| Context loading | All agent descriptions in context | All descriptions in context (managed by Claude Code at 1% of window) | May need `disable-model-invocation: true` on council agents to reduce context load |
| Skill descriptions | 2 skills | 7 skills | Set description char limit; front-load key trigger phrases |
| Install time | ~1s | ~2s | Negligible (file ops) |
| Router accuracy | N/A | Binary (code vs non-code) sufficient at 5 councils | May need examples/few-shot if taxonomy grows complex |

---

## Sources

- Official Claude Code skills documentation: https://code.claude.com/docs/en/skills (HIGH confidence — current official docs, April 2026)
- Official Claude Code subagents documentation: https://code.claude.com/docs/en/sub-agents (HIGH confidence — current official docs)
- Official Claude Code plugins documentation: https://code.claude.com/docs/en/plugins (HIGH confidence — current official docs)
- Official Claude Code hooks documentation (via WebFetch): https://code.claude.com/docs/en/hooks (HIGH confidence — current official docs)
- Anthropic "Building Effective Agents" — Routing + Orchestrator-Workers patterns: https://anthropic.com/research/building-effective-agents (MEDIUM confidence — confirmed patterns align with project architecture)
- Existing codebase: `/Users/D052192/src/council-code/` (HIGH confidence — direct inspection)
