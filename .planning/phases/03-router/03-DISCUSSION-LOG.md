# Phase 3: Router - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-04-24
**Phase:** 03-router
**Areas discussed:** Classification approach, Suggestion UX, Dispatch mechanism, Skill identity

---

## Classification approach

| Option | Description | Selected |
|--------|-------------|----------|
| LLM reasoning over SKILL.md descriptions | Router reads each council's SKILL.md description/trigger phrases and matches using Claude's NLU. No explicit keyword lists. Adding a new council = adding its SKILL.md. | ✓ |
| Router-maintained keyword map | Router maintains its own explicit mapping of keywords/patterns to councils. More predictable but requires updating the router every time. | |
| Interactive narrowing | Structured decision tree — router asks clarifying sub-questions to narrow down. More interactive but slower. | |

**User's choice:** LLM reasoning over SKILL.md descriptions
**Notes:** Auto-discovery via descriptions — no hardcoded map needed.

---

| Option | Description | Selected |
|--------|-------------|----------|
| Static list in router SKILL.md | Router reads a static list of council skill directories baked into its own SKILL.md. Simple, explicit. Must update router when adding a council. | ✓ |
| Dynamic registry file | Router references a registry file that all councils register into during install. Auto-discovers without being edited. | |
| Static list with graceful fallback | Static list plus instructions to handle unknown councils gracefully. | |

**User's choice:** Static list in router SKILL.md
**Notes:** Simple and explicit. Update the list when shipping new councils.

---

| Option | Description | Selected |
|--------|-------------|----------|
| Best guess with override | Router picks best guess, presents with reasoning. User can override. One round-trip. | ✓ |
| Top-2 candidates when uncertain | When confidence is low, show top 2 candidates with pros/cons. Adds a step. | |
| Always show full ranking | Always presents all councils ranked by fit. More info but noisy. | |

**User's choice:** Best guess with override
**Notes:** None

---

| Option | Description | Selected |
|--------|-------------|----------|
| Closest match with caveat | Suggest the closest council anyway but flag low confidence. User decides. | ✓ |
| Honest "no match" with council directory | Says "none fit well" and lists what each council covers. | |
| Default to council-code | Picks code council as default fallback. | |

**User's choice:** Closest match with caveat
**Notes:** None

---

## Suggestion UX

| Option | Description | Selected |
|--------|-------------|----------|
| Compact recommendation block | Short structured block: council name, 1-2 sentence reasoning, confirm/override prompt. | ✓ |
| Ranked council table | Mini-table of all councils with fit scores, highlighted best match. | |
| Conversational prose | Paragraph explaining reasoning and suggesting council inline. | |

**User's choice:** Compact recommendation block
**Notes:** None

---

| Option | Description | Selected |
|--------|-------------|----------|
| Confirm or pick different | Two options: "Run [suggested]" or "Pick a different council" (shows full list). | ✓ |
| Confirm, skip, or pick different | Three options adding an escape hatch for users who know which council they want. | |
| Simple yes/no | Just yes/no — if no, user types council name themselves. | |

**User's choice:** Confirm or pick different
**Notes:** None

---

| Option | Description | Selected |
|--------|-------------|----------|
| Pass question through as-is | Router passes original question to council. Council handles context extraction. | ✓ |
| Router reformulates question | Router summarizes/reformulates before passing. Could help focus but risks losing nuance. | |
| Question + classification reasoning | Passes question plus router's reasoning as additional context. | |

**User's choice:** Pass question through as-is
**Notes:** None

---

## Dispatch mechanism

| Option | Description | Selected |
|--------|-------------|----------|
| Skill tool invocation | Router uses Skill tool to invoke chosen council. Clean hand-off, same conversation. | ✓ |
| Suggest command, user invokes | Router outputs the slash command as text, user runs it manually. | |
| Agent tool spawn | Router spawns council as subagent. Separate context, result comes back as tool result. | |

**User's choice:** Skill tool invocation
**Notes:** None

---

| Option | Description | Selected |
|--------|-------------|----------|
| Classify only installed councils | Router only classifies between councils that actually exist. Static list, updated when new councils ship. | ✓ |
| Classify all planned, flag uninstalled | Knows about all planned councils, can flag uninstalled ones. | |
| Category-based with fallbacks | Classifies into broad categories and maps to installed councils. | |

**User's choice:** Classify only installed councils
**Notes:** None

---

## Skill identity

| Option | Description | Selected |
|--------|-------------|----------|
| /council-router | Follows council-* naming convention. | ✓ |
| /council (reassign from code) | Short and natural but requires reassigning from council-code. | |
| /route or /ask-council | Shorter but breaks naming convention. | |

**User's choice:** /council-router
**Notes:** User also requested /council as additional trigger — see reassignment decision below.

---

| Option | Description | Selected |
|--------|-------------|----------|
| Router coexists with direct invocation | Both work. Direct invocations (/council-code, /council-strategy) remain. Router is for when you don't know which council. | ✓ |
| Router is primary, direct is shortcut | All go through router first. Direct still works but router is "front door". | |
| Router replaces direct invocation | Router is the only entry point. | |

**User's choice:** Router coexists with direct invocation
**Notes:** None

---

| Option | Description | Selected |
|--------|-------------|----------|
| Explicit router triggers only | Only /council-router and phrases like "which council", "route this", "help me pick". Clean separation. | ✓ |
| Router captures ambiguous triggers | Also picks up "second opinion", "stress test" that currently go to council-code. | |
| Router intercepts all natural language | Everything council-related goes through classification first. | |

**User's choice:** Explicit router triggers only
**Notes:** None

---

### /council reassignment

| Option | Description | Selected |
|--------|-------------|----------|
| /council = router, /council-code = direct code | /council triggers the router. /council-code goes directly to code council. Short name = smart entry point. | ✓ |
| /council = router with auto-confirm | /council triggers router, but auto-confirms for obvious code matches. | |

**User's choice:** /council = router, /council-code = direct code
**Notes:** User explicitly requested /council as additional router trigger ("Ich möchte auch anstelle von council-router auch council direkt aufrufen können")

---

## Claude's Discretion

- Exact wording of classification prompt within router SKILL.md
- Format details of recommendation block (bold, emoji, spacing)
- How "Pick a different council" list is presented
- Error handling when Skill tool invocation fails

## Deferred Ideas

None — discussion stayed within phase scope
