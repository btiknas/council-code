# Technology Stack

**Project:** council-code multi-council extension
**Researched:** 2026-04-23
**Confidence:** HIGH — all patterns verified against current official Claude Code documentation (code.claude.com/docs)

---

## Context: What This Is Adding

The existing system is a pure-Markdown Claude Code plugin: SKILL.md orchestrators, agent definition `.md` files, Node.js hooks, and a Bash installer. The new milestone adds multi-council orchestration, a router skill, 4 new councils, git-hook triggers, and an expanded installer — all within the same no-compiled-code constraint.

This document covers the patterns and technology choices needed for that extension. It does not re-cover the existing stack (documented in `.planning/codebase/STACK.md`).

---

## Recommended Stack

### 1. Council Orchestration: SKILL.md with `disable-model-invocation: true` + `context: fork`

**For each council's main orchestrator** (`skills/council-{name}/SKILL.md`):

```yaml
---
name: council-strategy
description: Multi-perspective strategy council. Runs 5 expert advisors in parallel on business/product decisions (pricing, market, roadmap). Trigger: /council-strategy, "strategy council", "stress test this roadmap".
disable-model-invocation: true
---
```

**Why `disable-model-invocation: true`:** Each council is a deliberate invocation, not background knowledge. Without this flag, Claude may auto-load council content mid-conversation, which is always wrong. Councils run when called, not when Claude guesses they're relevant. This also keeps description text out of Claude's constant context, saving tokens.

**Why skills over agents for orchestrators:** Skills have `disable-model-invocation`, `allowed-tools`, `$ARGUMENTS` substitution, and inline shell execution (`` !`command` ``). Agent definitions lack these. The orchestration logic belongs in a skill; the persona definitions belong in agent files. This matches the existing pattern exactly.

**For the `context: fork` pattern:** The current council-code SKILL.md runs inline in the main conversation, then spawns agent Task calls. This is correct and should be preserved. Do NOT add `context: fork` to council orchestrators — that would isolate them from the user's conversation context (the decision being discussed). The `context: fork` pattern is for skills that are fully self-contained research tasks, not for orchestrators that need the conversation as input.

### 2. Advisor Personas: Agent `.md` Files with Restricted Tools

**For each council's 5 advisors** (`agents/{council-name}-{role}.md`):

```yaml
---
name: strategy-contrarian
description: Devil's advocate for strategy and business decisions. Fatal flaw finder for pricing, market, and roadmap choices.
tools: Read, Grep, Glob, WebSearch, WebFetch
---
```

**Naming pattern:** `{council}-{role}.md` (e.g., `strategy-contrarian.md`, `design-ux-researcher.md`). This keeps agents namespaced per council while keeping each agent file self-contained. An agent named `strategy-contrarian` in the `agents/` directory can be invoked standalone without running the full council.

**Why per-council agent files instead of shared personas:** Different domains need different expert lenses. A "UX Researcher" is a meaningful advisor in design but nonsensical in code review. Re-skinning shared prompts with domain wrappers produces worse analysis than writing domain-specific expert identities from scratch. The cost is more files; the benefit is dramatically better persona quality.

**Tool restriction:** Keep the same allowlist as existing personas (`Read, Grep, Glob, WebSearch, WebFetch`). No Write/Edit — advisors analyze, they don't change code. This is a deliberate constraint. The `model` field should be omitted (inherit from session) for all advisors.

### 3. Router Skill: Classifier SKILL.md + Suggest-and-Confirm Pattern

**File:** `skills/council-router/SKILL.md`

```yaml
---
name: council-router
description: Analyzes a decision and suggests the most appropriate council. Use when the right council is unclear. Trigger: /council-router, "which council", "route this".
disable-model-invocation: true
---
```

**Why suggest-and-confirm, not auto-dispatch:** User keeps control over which council runs. The router is a recommendation layer, not an automated dispatcher. This is the right call per the PROJECT.md requirements and avoids running the wrong council on an ambiguous problem. The skill outputs a recommendation with brief rationale, then asks the user to confirm before invoking the target council.

**Implementation pattern:** The router SKILL.md reads the user's question, classifies it across 5 domains (code, strategy, design, research, review), picks the best match, explains why, and ends with: "Run /council-{name} to proceed, or tell me which council you'd prefer." No sub-agent spawning in the router — it's a classification skill, not an orchestrator.

**Why NOT a dedicated classifier agent:** Creating a subagent just for classification adds overhead without benefit. The router runs inline in one turn — simple prompt engineering in a skill is sufficient and matches the zero-runtime-dependency constraint.

### 4. Git Hook Triggers: PostToolUse on Bash + FileChanged for Watched Files

**Mechanism:** Claude Code hooks, configured via `install.sh` patching `~/.claude/settings.json`.

Two hook patterns are appropriate for auto-council on git events:

**Pattern A — PostToolUse on Bash matching git operations:**

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "if": "Bash(git commit *)",
            "command": "node ~/.claude/hooks/council-git-trigger.js"
          }
        ]
      }
    ]
  }
}
```

This fires after Claude runs a git commit command. The hook script reads the staged diff from stdin context and optionally triggers a council-review prompt via a system message.

**Pattern B — FileChanged watching specific files:**

```json
{
  "hooks": {
    "FileChanged": [
      {
        "matcher": "PULL_REQUEST_TEMPLATE.md|.github/pull_request_template.md",
        "hooks": [
          {
            "type": "command",
            "command": "node ~/.claude/hooks/council-pr-watch.js"
          }
        ]
      }
    ]
  }
}
```

**Which to use:** Pattern A (PostToolUse Bash) is the correct approach for commit-time review. It intercepts when Claude is performing git operations, which is the most common workflow. Pattern B is useful for watching PR template changes but less relevant for runtime triggering.

**CRITICAL constraint:** Claude Code has no native git-lifecycle hooks (no pre-commit, no post-commit equivalent that fires from the terminal `git` binary). The PostToolUse hook fires when Claude runs `git commit`, not when the user runs it in a separate terminal. This means git hooks work when Claude is performing the git operation, not for all commits universally. For true universal git integration, a real git pre-commit hook (managed by the installer) is required.

**For universal pre-commit triggers:** Install a traditional `git` hook via `install.sh` that the user can opt into per-project:

```bash
# In install.sh, optional git hook setup
if [[ "$INSTALL_GIT_HOOKS" == "true" ]]; then
  cp "$REPO_ROOT/hooks/git/pre-commit" ".git/hooks/pre-commit"
  chmod +x ".git/hooks/pre-commit"
fi
```

The pre-commit hook can invoke a council-review check as a Node.js script using only stdlib (matching the existing zero-dependency constraint).

**Why Node.js, not shell, for hook scripts:** The existing hooks use Node.js for safe JSON handling and JSON parsing of the Claude Code hook payload. Consistent with this — all new hooks should be Node.js. Shell is only appropriate for the Bash wiring in install.sh itself.

### 5. Installer Pattern: Expanded install.sh with Array Extension

**Approach:** Extend the existing `install.sh` arrays for new skills, agents, and hooks. No architectural change needed.

```bash
# Extend existing arrays
SKILLS=( council-code council-update council-router council-strategy council-design council-research council-review )
PERSONAS=( contrarian first-principles expansionist outsider executor
           strategy-contrarian strategy-market-strategist strategy-customer-advocate strategy-financials-analyst strategy-executor
           design-ux-researcher design-contrarian design-systems-thinker design-accessibility-advocate design-executor
           # ... etc )
HOOKS=( council-statusline.js council-check-update.js council-check-update-worker.js council-git-trigger.js )
```

**Why no architectural change:** The existing pattern (loop over arrays, symlink or copy, idempotent, backup-if-real) is correct and scales to any number of components. The JSON-in-Node-for-settings approach is already well-tested. Do not refactor this. Do extend the `patch_settings_install` function for the new git hook registration.

**Backward compatibility guarantee:** `SKILLS`, `PERSONAS`, and `HOOKS` arrays are additive. Existing `/council-code` and `/council` triggers keep working because the existing skill files are not touched. New skills have new names; new agents have namespaced names.

**Optional git hook install flag:**

```bash
for arg in "$@"; do
  case "$arg" in
    --with-git-hooks) INSTALL_GIT_HOOKS="true" ;;
    ...
  esac
done
```

Git hook installation into the current project's `.git/hooks/` should be opt-in, not default, because it modifies a specific project's git repo rather than the user's Claude setup.

### 6. settings.json Patching: Append-Only Node.js Scripts

**Preserve the existing pattern** of inline Node.js heredocs in `install.sh` for settings.json mutation. This approach:
- Handles pre-existing hooks gracefully (appends to SessionStart array, does not replace)
- Creates timestamped backups before any mutation
- Handles invalid JSON by refusing to patch
- Is idempotent (checks for existing entries before appending)

For new hook registrations (the git trigger), add them to the `patch_settings_install` function using the same append-check pattern already used for the SessionStart hook.

**Do not switch to a separate settings-patcher script** — the inline heredoc keeps everything in one file, which is easier to install and audit.

---

## Alternatives Considered

| Category | Recommended | Alternative | Why Not |
|----------|-------------|-------------|---------|
| Council orchestrators | SKILL.md files | Agent .md files | Agents lack `disable-model-invocation`, `$ARGUMENTS`, inline shell execution |
| Router classification | Inline skill, suggest+confirm | Dedicated classifier subagent | Subagent overhead not warranted for single-turn classification; violates zero-runtime-dependency |
| Git hook triggers | PostToolUse on Bash + opt-in .git/hooks | MCP server with git watch | MCP is out of scope per PROJECT.md; adds runtime dependency |
| Settings patching | Inline Node.js in install.sh | Separate JS patcher script | Breaks single-file install pattern; no practical benefit |
| Multi-council synthesis | Defer (out of scope) | Cross-council router that runs all councils | PROJECT.md explicitly defers this; synthesis quality requires separate phase |
| Agent teams | Not used for council pattern | CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS | Experimental flag, higher token cost, inter-agent messaging not needed — council advisors must NOT communicate before synthesis (anchoring prevention) |

---

## What NOT to Use

### Agent Teams (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`)

The council pattern requires advisors to run in parallel WITHOUT seeing each other's output before synthesis. Agent teams are explicitly designed for teammates that communicate with each other and share a task list. This is the opposite of what councils need. Using agent teams would enable anchoring, which is the single most important thing the council architecture prevents. The existing Task-tool parallel spawn pattern is the correct mechanism.

**Use agent teams for:** tasks requiring inter-agent debate and convergence.
**Use parallel Task tool calls for:** tasks requiring independent parallel analysis and centralized synthesis.

### `context: fork` on Council Orchestrators

`context: fork` isolates the skill into a forked subagent with no access to the main conversation history. Council orchestrators need to read the user's decision question from the conversation. Forking breaks this. `context: fork` is only appropriate for self-contained research tasks like PR summarization.

### MCP Server for Orchestration

PROJECT.md explicitly excludes MCP for this milestone. Beyond the scope constraint: an MCP server would add a Node.js runtime dependency with a build step, breaking the zero-compiled-code constraint. The SKILL.md approach is simpler, more portable, and sufficient.

### Per-Council Shared Advisors (Re-skinned Prompts)

Do not create one set of 5 advisors and vary them by domain via system prompt injection. The "Contrarian" in a code context (finds race conditions, API design flaws) is a different expert from the "Contrarian" in a strategy context (challenges market assumptions, pricing logic). Write domain-specific experts, not domain-agnostic personas with domain wrappers.

### Automatic Council Dispatch (No Confirm)

The router should never auto-dispatch to a council without user confirmation. Auto-dispatch would trigger full 5-agent runs on ambiguous questions, wasting tokens and producing irrelevant analyses. The suggest-and-confirm pattern keeps user intent in the loop.

---

## Configuration Files Affected

| File | Change |
|------|--------|
| `install.sh` | Extend SKILLS, PERSONAS, HOOKS arrays; add `--with-git-hooks` flag; extend `patch_settings_install` for git trigger |
| `~/.claude/settings.json` | New PostToolUse hook entry for git trigger (appended by install.sh) |
| `hooks/council-git-trigger.js` | New: PostToolUse handler for git commit events |
| `skills/council-router/SKILL.md` | New: router/classifier skill |
| `skills/council-strategy/SKILL.md` | New: strategy council orchestrator |
| `skills/council-design/SKILL.md` | New: design council orchestrator |
| `skills/council-research/SKILL.md` | New: research council orchestrator |
| `skills/council-review/SKILL.md` | New: code review council orchestrator |
| `agents/strategy-*.md` (x5) | New: strategy council advisor personas |
| `agents/design-*.md` (x5) | New: design council advisor personas |
| `agents/research-*.md` (x5) | New: research council advisor personas |
| `agents/review-*.md` (x5) | New: review council advisor personas |
| `.claude-plugin/plugin.json` | Version bump (0.4.0 → next semver) |

---

## Key Frontmatter Patterns Reference

### SKILL.md for council orchestrator:
```yaml
---
name: council-{domain}
description: [one-line trigger description with explicit trigger phrases]
disable-model-invocation: true
allowed-tools: [none needed — Task tool calls handled by runtime]
---
```

### Agent .md for advisor persona:
```yaml
---
name: {council}-{role}
description: [When Claude should delegate to this advisor as a standalone]
tools: Read, Grep, Glob, WebSearch, WebFetch
---
```

### Hook in settings.json (PostToolUse git trigger):
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "if": "Bash(git commit *)",
            "command": "node \"~/.claude/hooks/council-git-trigger.js\""
          }
        ]
      }
    ]
  }
}
```

---

## Confidence Assessment

| Area | Confidence | Source |
|------|------------|--------|
| SKILL.md frontmatter fields | HIGH | Verified against code.claude.com/docs/en/skills |
| Agent frontmatter fields | HIGH | Verified against code.claude.com/docs/en/sub-agents |
| Hook event types and payload format | HIGH | Verified against code.claude.com/docs/en/hooks |
| `disable-model-invocation` behavior | HIGH | Verified: removes skill from Claude's context, prevents auto-invocation |
| `context: fork` behavior | HIGH | Verified: isolates to subagent, loses conversation history |
| PostToolUse Bash git trigger | HIGH | Verified in hooks docs |
| Agent teams anti-recommendation | HIGH | Verified: teams designed for inter-agent comms, opposite of anchoring-prevention need |
| Plugin hooks.json format | HIGH | Verified against code.claude.com/docs/en/plugins |
| Task tool rename (was "Task", now "Agent") | HIGH | Verified in sub-agents docs: "In version 2.1.63, the Task tool was renamed to Agent. Existing Task(...) references still work as aliases." |
| Git hook integration for terminal-invoked git | MEDIUM | Docs confirm no native git-lifecycle hooks; PostToolUse is Claude-operation-only; traditional .git/hooks needed for universal coverage |

---

## Sources

- [Skills documentation](https://code.claude.com/docs/en/skills) — Frontmatter reference, `disable-model-invocation`, `context: fork`, `$ARGUMENTS`, inline shell execution
- [Sub-agents documentation](https://code.claude.com/docs/en/sub-agents) — Agent frontmatter fields, tool restrictions, `Task` → `Agent` rename, parallel invocation patterns
- [Hooks documentation](https://code.claude.com/docs/en/hooks) — All hook events including PostToolUse, FileChanged, SubagentStart/Stop, JSON payload format, exit code behavior, `if` conditional syntax
- [Plugins documentation](https://code.claude.com/docs/en/plugins) — Plugin structure, hooks.json format, plugin vs standalone tradeoffs
- [Agent Teams documentation](https://code.claude.com/docs/en/agent-teams) — Architecture comparison (subagents vs teams), SendMessage, why NOT to use for council pattern
- Existing `install.sh` — Idempotent installer pattern, settings.json patching via Node.js heredoc
- Existing `hooks/council-check-update.js` — SessionStart hook pattern, cache-based debouncing
- Existing `skills/council-code/SKILL.md` — Parallel Task tool invocation pattern, chairman synthesis structure
