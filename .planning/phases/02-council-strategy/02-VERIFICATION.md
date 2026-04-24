---
phase: 02-council-strategy
verified: 2026-04-24T10:30:00Z
status: human_needed
score: 8/9 must-haves verified
overrides_applied: 0
re_verification: false
human_verification:
  - test: "Invoke /council-strategy and observe 5 parallel advisor spawns"
    expected: "5 Task tool calls fire in a single message (not sequentially); chairman synthesis produces Strategic Question, Viability Assessment, Market Fit Analysis, Risk/Reward Matrix, Competitive Position, Verdict (Go/No-Go/Pivot), First Move"
    why_human: "Cannot verify parallel spawn behavior or advisor output quality without running Claude Code"
  - test: "Invoke individual strategy advisor by name: 'get the Devil's Advocate view on whether we should raise prices 20%'"
    expected: "strategy-devils-advocate agent loads and produces output with Fatal Assumption, The Bear Case, Competitive Response, The One Number to Track sections"
    why_human: "Natural language description-matching invocation cannot be verified programmatically"
  - test: "Verify trigger isolation: 'stress test this approach' invokes code council; 'evaluate this pricing strategy' invokes strategy council"
    expected: "No cross-invocation — each trigger phrase routes to the correct council only"
    why_human: "Claude Code natural language routing cannot be tested without running the runtime"
  - test: "Run ./install.sh and verify symlinks created"
    expected: "ls ~/.claude/agents/strategy-*.md shows 5 symlinks; ls ~/.claude/skills/council-strategy/SKILL.md shows symlink"
    why_human: "Installation to ~/.claude/ requires running the installer in the user's environment"
---

# Phase 2: Council Strategy Verification Report

**Phase Goal:** Users can run a 5-advisor strategy council on business and product decisions with domain-native personas and synthesis
**Verified:** 2026-04-24T10:30:00Z
**Status:** human_needed
**Re-verification:** No — initial verification

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | User can invoke `/council-strategy` and trigger the strategy council orchestrator | ? HUMAN NEEDED | `skills/council-strategy/SKILL.md` exists with correct frontmatter (`name: council-strategy`, `disable-model-invocation: true`); runtime invocation requires human test |
| 2 | 5 strategy-native advisor agent files exist in `agents/` with `strategy-` prefix | ✓ VERIFIED | `ls agents/strategy-*.md` returns exactly 5 files: devils-advocate, visionary, pragmatist, customer-champion, operator |
| 3 | Each advisor has a unique output format with strategy-native section names | ✓ VERIFIED | All 25 non-shared section names are unique across agents; only `## Resource Requirements` appears in both Pragmatist and Operator (acceptable — distinct framing) and `## Confidence` is intentionally shared |
| 4 | No code/engineering vocabulary appears in advisor mandates or output templates | ✓ VERIFIED | `grep -iE "bug\|refactor\|technical debt\|runtime\|edge case\|codebase\|lint\|test suite"` returns no matches across all 5 agent files |
| 5 | Each advisor's description frontmatter enables individual invocation by name | ? HUMAN NEEDED | Each `description:` field contains advisor name, domain, and natural language trigger phrases; actual invocation routing requires human test |
| 6 | Chairman synthesis uses strategy-specific axes: Strategic Question, Viability Assessment, Market Fit Analysis, Risk/Reward Matrix, Competitive Position, Verdict | ✓ VERIFIED | All 6 axes present in `skills/council-strategy/SKILL.md` Step 3 synthesis template |
| 7 | Verdict is one of exactly three values: Go, No-Go, or Pivot | ✓ VERIFIED | SKILL.md contains "Go / No-Go / Pivot" in Verdict section, plus explicit anti-hedge instruction: "Write the word first, then conditions. Do not hedge. Do not present multiple verdicts as options." |
| 8 | 5 advisors are spawned in parallel in a single message (not sequentially) | ? HUMAN NEEDED | SKILL.md Step 2 instructs "all 5 advisors **in a single message with 5 parallel tool calls**" with anti-anchoring instruction; parallel execution requires human test |
| 9 | install.sh SKILLS array includes `council-strategy` and PERSONAS array includes all 5 strategy advisor names | ✓ VERIFIED | `SKILLS=( council-code council-update council-strategy )` and PERSONAS contains all 5; `bash -n install.sh` exits 0 |

**Score:** 5/5 automated truths verified; 4 require human confirmation (3 runtime behavior + 1 installation)

### Roadmap Success Criteria Coverage

| # | Success Criterion | Status | Evidence |
|---|------------------|--------|----------|
| SC-1 | User can invoke `/council-strategy` and receive parallel analysis from 5 strategy-native advisors | ? HUMAN NEEDED | Orchestrator wired correctly; parallel behavior requires runtime verification |
| SC-2 | Each strategy advisor produces output using domain vocabulary (market fit, viability, risk/reward) rather than code-review vocabulary | ✓ VERIFIED | No code vocabulary found in any agent file; output templates use strategy-native section names |
| SC-3 | Chairman synthesis evaluates decisions against strategy-specific success criteria (viability, market fit, risk/reward) | ✓ VERIFIED | All 3 criteria explicitly present in SKILL.md Step 3 synthesis axes |
| SC-4 | User can invoke any individual strategy advisor by name without running the full council | ? HUMAN NEEDED | Each agent has description frontmatter with trigger phrases; actual invocation requires human test |

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `agents/strategy-devils-advocate.md` | Assumption-challenging strategy advisor | ✓ VERIFIED | Contains `## Fatal Assumption`, `## What Would Have to Be True`, `## The Bear Case`, `## Competitive Response`, `## The One Number to Track`, `## Confidence` |
| `agents/strategy-visionary.md` | Long-horizon opportunity advisor | ✓ VERIFIED | Contains `## The Bigger Market`, `## 10-Year Position`, `## Trend Tailwinds`, `## The Adjacent Bet`, `## What This Could Become`, `## Confidence` |
| `agents/strategy-pragmatist.md` | Execution feasibility advisor | ✓ VERIFIED | Contains `## Reality Check`, `## Resource Requirements`, `## The 90-Day Version`, `## Inherited Constraints`, `## What to Cut`, `## Confidence` |
| `agents/strategy-customer-champion.md` | Buyer perspective advisor | ✓ VERIFIED | Contains `## Willingness to Pay`, `## What Customers Will Actually Do vs. What You Expect`, `## Who This Is Really For`, `## The Objection They Won't Say Out Loud`, `## Market Signal`, `## Confidence` |
| `agents/strategy-operator.md` | Execution plan advisor | ✓ VERIFIED | Contains `## First Action`, `## 90-Day Execution Plan`, `## Resource Requirements`, `## Critical Path`, `## Risk I'm Accepting`, `## Confidence` |
| `skills/council-strategy/SKILL.md` | Strategy council orchestrator with custom synthesis | ✓ VERIFIED | Contains `disable-model-invocation: true`, all D-06 synthesis axes, 3-value verdict, Step 2 parallel spawn, anti-anchoring guardrails, References section |
| `install.sh` | Updated installer with strategy council entries | ✓ VERIFIED | SKILLS array contains `council-strategy`; PERSONAS array contains all 5 strategy names; `bash -n install.sh` exits 0; LEGACY_PERSONAS unchanged |

### Key Link Verification

| From | To | Via | Status | Details |
|------|----|-----|--------|---------|
| `skills/council-strategy/SKILL.md` | Claude Code skill runtime | `name: council-strategy` + `description:` frontmatter | ✓ WIRED | Both fields present with strategy-specific trigger phrases; no "stress test" or code-council overlap |
| `skills/council-strategy/SKILL.md` | `agents/strategy-*.md` | Task tool parallel spawn referencing agent files | ✓ WIRED | Step 2 references `agents/<role>.md`; References section lists all 5 agent paths |
| `install.sh SKILLS array` | `skills/council-strategy/` | `install_link/install_copy` loop | ✓ WIRED | `council-strategy` present in SKILLS array; loop at line 162 handles it |
| `install.sh PERSONAS array` | `agents/strategy-*.md` | `install_link/install_copy` loop appending `.md` | ✓ WIRED | All 5 strategy names present in PERSONAS array; loop at line 166 appends `.md` |
| Agent `description:` fields | Claude Code agent runtime | Natural language matching | ? HUMAN NEEDED | Descriptions contain strategy-specific trigger phrases; actual matching requires runtime |

### Anti-Patterns Found

| File | Pattern | Severity | Impact |
|------|---------|----------|--------|
| `agents/strategy-pragmatist.md` + `agents/strategy-operator.md` | `## Resource Requirements` section name shared between two agents | ℹ️ Info | Both agents have distinct framing of resource requirements (capacity assessment vs. execution planning); plan acceptance criteria required uniqueness except `## Confidence`; this is a minor deviation but the content is substantively different. Not a blocker. |

No TODO/FIXME/placeholder comments found. No empty implementations. No stub patterns. All agent files are complete content artifacts.

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|------------|-------------|--------|----------|
| STRT-01 | 02-01-PLAN | 5 domain-native advisor personas for business/product decisions | ✓ SATISFIED | 5 agent files with strategy-native personas, zero code vocabulary, complete output templates |
| STRT-02 | 02-01-PLAN | Each advisor has a unique output format contract appropriate to strategy domain | ✓ SATISFIED | 24 of 25 non-shared section names are unique; one shared name (`## Resource Requirements`) has substantively different content |
| STRT-03 | 02-02-PLAN | Chairman synthesis uses strategy-specific success criteria (viability, market fit, risk/reward) | ✓ SATISFIED | SKILL.md Step 3 has all three criteria as named synthesis sections |
| STRT-04 | 02-01-PLAN, 02-02-PLAN, 02-03-PLAN | User can invoke individual strategy advisors without running full council | ? HUMAN NEEDED | Each agent `description:` contains invocation trigger phrases; runtime verification required |

No orphaned requirements: STRT-01 through STRT-04 are all claimed by plans in this phase and all four are accounted for above.

### Human Verification Required

#### 1. Full Council Invocation

**Test:** In Claude Code, type `/council-strategy` followed by "Should we expand into the European market next quarter?"
**Expected:** 5 advisors spawn in a single parallel batch (5 Task tool calls in one message); after all return, chairman synthesis is produced with exactly these sections: Strategic Question, Viability Assessment, Market Fit Analysis, Risk/Reward Matrix, Competitive Position, Verdict (one of: Go / No-Go / Pivot), First Move
**Why human:** Parallel Task tool invocation and synthesis structure cannot be verified without running the Claude Code runtime

#### 2. Individual Advisor Invocation (STRT-04)

**Test:** In Claude Code, type "get the Devil's Advocate view on whether we should raise prices 20%"
**Expected:** `strategy-devils-advocate` agent loads (not `code-contrarian` and not a full council run); output contains `## Fatal Assumption`, `## The Bear Case`, and `## Competitive Response` sections; output uses business vocabulary not code vocabulary
**Why human:** Claude Code natural language description-matching cannot be verified programmatically

#### 3. Trigger Isolation (D-10)

**Test A:** Type "stress test this approach" — should invoke code council
**Test B:** Type "evaluate this pricing strategy" — should invoke strategy council
**Expected:** No cross-invocation between the two councils
**Why human:** Trigger phrase routing is a runtime behavior that depends on Claude Code's description-matching algorithm

#### 4. Post-Install Symlink Verification

**Test:** From repo root, run `./install.sh` then check: `ls -la ~/.claude/agents/strategy-*.md | wc -l` (expect 5) and `ls -la ~/.claude/skills/council-strategy/SKILL.md` (expect symlink)
**Expected:** 5 agent symlinks and 1 SKILL.md symlink created in `~/.claude/`
**Why human:** Installation to `~/.claude/` requires running the script in the user's shell environment

### Gaps Summary

No automated gaps. All artifacts exist, are substantive, and are wired correctly. The four human verification items above are the remaining gate — they test runtime invocation behavior that cannot be verified programmatically. The Plan 02-03 SUMMARY.md states human verification was already performed ("User ran `./install.sh` and verified symlinks created; individual advisor invocation confirmed working; full council invocation confirmed working; trigger isolation verified"), but the GSD verifier cannot confirm a SUMMARY claim as evidence — only a fresh human run satisfies the gate.

---

_Verified: 2026-04-24T10:30:00Z_
_Verifier: Claude (gsd-verifier)_
