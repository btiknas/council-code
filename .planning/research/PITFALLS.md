# Domain Pitfalls — Multi-Council Decision System

**Domain:** Multi-agent advisory/council system (Claude Code plugin)
**Researched:** 2026-04-23
**Confidence:** HIGH — sourced from existing codebase analysis, Claude Code official plugin docs, and first-principles reasoning from the system's own design constraints

---

## Critical Pitfalls

Mistakes that cause rewrites, silent degradation, or broken backward compatibility.

---

### Pitfall 1: Advisor Persona Contamination via Shared Agent Namespace

**What goes wrong:** When `council-strategy`, `council-design`, and `council-code` all install agent files into `~/.claude/agents/`, persona files from different councils collide. An `executor.md` intended for code decisions gets invoked in a strategy council session, or a design council's `critic.md` fires when the code council summons its Contrarian.

**Why it happens:** Claude Code's agent auto-discovery scans `~/.claude/agents/` as a flat namespace. The existing code council installs `contrarian.md`, `executor.md`, etc. without a council-specific prefix. If `council-strategy` also defines an `executor.md`, the second install silently overwrites the first. Worse, the orchestrator's prompt says "your role: see agents/executor.md" — but which executor fires depends on whichever file landed last.

**Consequences:**
- Code council gets a "strategy executor" persona focused on market timing instead of Monday-morning shipping
- Design council gets code-focused advisors that don't understand visual hierarchy or user flows
- Bugs are silent — the wrong persona still returns output; the synthesis just quietly degrades
- Uninstalling council-strategy destroys the code council's personas too

**Warning signs:**
- Advisor responses feel "off domain" — a code Executor starts talking about market fit
- `/council-code` output shifts vocabulary after adding a second council
- `ls ~/.claude/agents/` shows fewer files than expected after multi-council install

**Prevention:**
- **Namespace all agent files**: prefix with council slug — `code-contrarian.md`, `strategy-executor.md`, `design-critic.md`. Never install bare names like `contrarian.md` shared across councils.
- **Alternatively**: keep council-specific agents inside each skill's directory (`skills/council-strategy/agents/`) and reference them by path in the orchestrator brief, not by global agent name
- **Update the existing council-code personas** to use `code-` prefix before adding any new councils, to break the collision before it can happen

**Phase:** Must be addressed in the first new council added (council-strategy or council-router). Retrofitting later means a coordinated rename that touches install.sh, all SKILL.md orchestrators, and agent frontmatter simultaneously.

---

### Pitfall 2: Router Misfires That Waste Full Council Runs

**What goes wrong:** The router council is designed to classify the question and suggest which council to run. If its classification prompt is too broad or ambiguous, it misfires in predictable ways:
- Code questions with business implications ("should we rewrite the billing service?") route to council-strategy instead of council-code
- Questions about system design ("how should we structure our API?") are ambiguous between council-code and council-design
- Any question containing words like "should we" or "what's the best" triggers a strategy routing when it's actually a technical question

**Why it happens:** LLM classifiers operating on natural language alone over-index on surface keywords. "Should we adopt GraphQL?" sounds strategic, but is fundamentally a technical architecture question. The router's framing directly shapes where it draws domain boundaries, and those boundaries won't match the user's mental model without explicit disambiguation rules.

**Consequences:**
- User gets strategy advisors on a code question and gets market-framing advice on a `git rebase` decision
- Full council run wasted (5 subagent calls + synthesis) before user realizes it routed wrong
- User loses trust in the router and stops using it, defeating its purpose
- Worst case: user asked to confirm routing and always overrides, making the router purely friction

**Warning signs:**
- Router frequently routes technical-with-context questions to council-strategy
- Users override the router's suggestion more than 30% of the time (visible in session transcripts)
- Router cannot classify "should we refactor this module before adding the new feature?" cleanly

**Prevention:**
- Build the router classifier around **problem type** (What is being decided? Code structure vs. product direction vs. visual design), not surface phrasing
- Require the router to show its reasoning before the suggestion: "I'm reading this as a code architecture question because X" — users can correct bad reasoning, not just bad labels
- Define explicit overlap rules in the router prompt: "When a question involves both code and strategy, default to council-code unless the core uncertainty is about product/market direction"
- Test the router against 10 real questions from `docs/usage.md` before releasing it

**Phase:** Router design must lock in domain boundary definitions before any council persona files are written. Blurry boundaries in the router create blurry personas — if you don't know when council-strategy applies, you can't write a clean strategy Executor.

---

### Pitfall 3: install.sh Complexity Explosion — Settings.json Corruption on Multi-Council Install

**What goes wrong:** The existing `install.sh` contains an inline Node.js script that patches `~/.claude/settings.json`. It handles: statusLine wrapping, SessionStart hook appending, and delegation chain preservation. With 4+ councils, the install script must now wire multiple skills, multiple persona sets, and potentially multiple hooks — all idempotently, all without clobbering each other or other plugins (GSD).

The current script is already the most fragile part of the codebase (documented in CONCERNS.md). At 4 councils, the inline Node script grows to handle: detecting which councils are already installed, skipping already-wired hooks, managing the delegation chain for multiple statusline contributors, and uninstalling individual councils without breaking others.

**Why it happens:** The `settings.json` patching uses string matching to detect existing entries (`includes('council-check-update.js')`). As hook count grows, the detection logic multiplies. The "monorepo single install" constraint (all councils install together) means one script handles all edge cases at once.

**Consequences:**
- Concurrent or repeated installs corrupt `settings.json` — all hooks stop firing
- A failed install leaves a partial state: some personas installed, settings not patched
- Uninstalling council-strategy when council-code was installed first requires the script to know install order, which it doesn't track
- Backup files accumulate (`settings.json.bak.1234567890`) without cleanup

**Warning signs:**
- install.sh already has >100 lines of inline Node.js (it does)
- The "fragile areas" section of CONCERNS.md flags this explicitly
- Any new council requires reading and modifying the full inline script

**Prevention:**
- Extract the settings.json patching to a standalone script (`hooks/patch-settings.js`) that takes council-name as an argument, rather than baking all logic into install.sh
- Use a registry file (`~/.claude/council-registry.json`) that records which councils are installed, so uninstall/idempotency logic can query state rather than parse the settings.json
- Keep install.sh as thin orchestration: call `patch-settings.js --install council-code`, `patch-settings.js --install council-strategy`, etc.
- Each council registers/deregisters itself atomically

**Phase:** Refactor the install architecture before adding the second council. The cost of refactoring after 4 councils are wired is proportionally higher — each added council increases the complexity of the legacy code that must be migrated.

---

### Pitfall 4: Synthesis Quality Degrades With Roster Mismatch, Not Advisor Count

**What goes wrong:** The insight that 5 is the right advisor count is correct, but it's misunderstood as "any 5 advisors work." What actually makes synthesis tractable is that the 5 roles have **non-overlapping mandates and non-overlapping output formats**. When building new councils, developers tend to re-skin the code advisors with domain vocabulary without restructuring the underlying mandate.

For example: a strategy council built by renaming the code Contrarian to "Market Skeptic" but keeping its output format (`## Fatal Flaw`, `## Hidden Risks`) will produce synthesis that reads like a code review of a business idea — the framework fights the domain.

**Why it happens:** It's faster to copy-paste `agents/contrarian.md`, change a few nouns, and call it done. The output format template from the code council feels like it "works" because Claude is capable. But the synthesis chairman is trained against the code council's output format. A strategy council advisor that produces `## Fatal Flaw [Severity: Critical]` for a pricing decision is applying the wrong rubric.

**Consequences:**
- Strategy council gives code-style recommendations ("load test this business model") rather than strategy-style ones ("validate this assumption before the decision point")
- Chairman synthesis struggles to find "clashes" when all 5 advisors share the same output vocabulary
- Users find the non-code councils less useful and revert to council-code for everything
- The "domain-specific" value proposition is not realized

**Warning signs:**
- New council advisor files have >50% copied verbatim from code council personas
- All advisor output formats use the same severity labels and section headers
- Chairman synthesis for a design question mentions "performance bottlenecks" and "race conditions"

**Prevention:**
- Before writing any new council persona, define the **domain-specific output contract** first: what does a useful analysis look like in this domain? A strategy Contrarian's output should mention assumptions, market conditions, and timeline risks — not severity labels
- Write one complete advisor for the new council as a spec before writing the rest
- The chairman synthesis prompt must be domain-aware — `council-strategy`'s synthesis template should use strategy vocabulary (assumptions, risks, alternatives, bet size) not code vocabulary (fatal flaw, hidden coupling, abstraction)
- Test synthesis quality with a real question before locking in the roster

**Phase:** Council design phase. Each council's persona set must be designed from first principles for its domain, not adapted from code council templates. This is more work upfront but prevents the silent degradation pattern.

---

## Moderate Pitfalls

---

### Pitfall 5: Router Becomes a Friction Point Instead of an Accelerant

**What goes wrong:** The router is designed as "suggest + confirm" — it analyzes the problem, recommends a council, then waits for user confirmation. This is the right design for avoiding autoruns. But if the confirm step is poorly framed, it becomes a mandatory extra interaction that slows down users who already know which council they want.

**Why it happens:** Users who invoke `/council-code` directly don't hit the router. Users who invoke `/council` (the generic trigger) do. If the router's confirm prompt is verbose or requires a full response, experienced users will train themselves to always use the specific command and never use the router.

**Prevention:**
- Router confirmation must be a single-key choice: "Strategy (s), Design (d), Code (c), or type a command to skip routing"
- The router must be bypassable — users who already know their council should be able to say "use council-strategy" and have the router stand down
- Track router suggestion accuracy in usage docs so it can be improved over time

**Phase:** Router UX design phase. Settle the confirmation interaction before writing the router classifier.

---

### Pitfall 6: Git Hook Auto-Council Triggering Inappropriately

**What goes wrong:** Git hook triggers (auto-council on commit, PR, file change) sound useful but have a high noise-to-signal risk. A `pre-push` hook that runs `council-review` on every push will fire on WIP commits, documentation changes, and trivial fixes — training users to dismiss it. Once dismissed behavior is learned, it's very hard to rebuild trust in the hook.

**Why it happens:** Git hooks don't understand intent. A `post-commit` hook sees a commit, not "a commit worth reviewing." Granularity requires either file-pattern filtering (only trigger on `src/**`) or size thresholds (only trigger on diffs > 50 lines) — both of which are fragile heuristics.

**Consequences:**
- Hook fires on `git commit -m "fix typo"` and runs 5 subagents — 30 seconds, user cancels, learns to skip
- Hooks that run full council in `pre-push` block the push until 5 agents complete — severe UX degradation
- False positives train users to bypass the hook

**Prevention:**
- Git hooks should be **opt-in per-project** via a `.council-hooks` config file, not installed globally
- Hooks should run council-review **asynchronously** and display results as a statusline notification, not blocking the push
- Start with file-size thresholds + explicit file patterns (no auto-trigger on test files, docs, or config changes)
- The hook MVP should be: detect large diffs, display a suggestion "council-review available" — not autorun

**Phase:** Git hooks phase. Design as opt-in from the start; making an always-on hook opt-out after release requires a breaking change to the install.

---

### Pitfall 7: Agent Description Field Not Tuned Per Council — Auto-Trigger Misfires

**What goes wrong:** Claude Code uses the `description` field in agent frontmatter to decide when to auto-trigger an agent. If two councils share similar description text ("Use this agent when analyzing a decision..."), Claude may invoke a design council agent inside a code council session, or vice versa.

This is documented in Claude Code's own troubleshooting guide: "When an agent triggers in wrong scenarios, revise the examples to exclusively depict correct triggering conditions."

**Why it happens:** Description fields are often the last thing written and the first thing copy-pasted. Each council's advisors need description examples that distinguish them from other councils' similarly-named advisors.

**Prevention:**
- Each new council's advisor descriptions must include explicit negative examples: "Do NOT use this agent for code architecture questions — use council-code advisors instead"
- Run Claude Code with verbose logging after installing a new council and verify no cross-council agent triggers on a known code-council question

**Phase:** Per council, during advisor authoring.

---

## Technical Debt Patterns

Patterns that don't break things today but create compounding maintenance cost.

---

### Pattern 1: Skill Orchestrators That Duplicate Logic

Each `council-X/SKILL.md` will share the same orchestration skeleton: extract decision prompt, spawn advisors in parallel, synthesize. If this skeleton is copy-pasted into each council's SKILL.md, any improvement to the orchestration pattern (better parallel spawn instructions, improved synthesis format) must be applied to all councils.

**Prevention:** Define a shared "Council Protocol" section that all SKILL.md files reference by inclusion or explicit copy-with-attribution. When improving one council's orchestration, update all of them in the same PR. Document this in CLAUDE.md.

---

### Pattern 2: Personas That Drift From Their Mandate Over Time

The code council's existing constraint — "keep the persona pure, don't let the Contrarian start proposing wins" — applies equally to all councils. Persona files tend to accumulate qualifications and exceptions over time ("unless the proposal is clearly good, in which case..."). Each exception erodes role separation and degrades synthesis quality.

**Prevention:** Each advisor file should have a "What I do NOT do" section as part of its mandate. Review personas every milestone transition for mandate drift.

---

### Pattern 3: Backward Compatibility Assumptions Baked Into Agent Filenames

The existing code council uses bare agent names (`contrarian.md`, `executor.md`). Renaming these to namespaced forms (`code-contrarian.md`) breaks any user who references them by name in a custom prompt or scripts against the agent files directly. The rename is necessary (see Pitfall 1) but is a one-time breaking change that must be done with a migration guide.

**Prevention:** Version the rename in a single commit with a MIGRATION.md note. Run the uninstall + reinstall to pick up new names. Document in README under "Upgrading."

---

## Performance Traps

### Trap 1: Token Budget Blow-Up From Deeply Contextualized Advisor Briefs

When the orchestrator collects context to pass to advisors, it reads relevant files. For the code council this is manageable — a few source files. For council-review on a large PR, the brief can include full file contents + diff + CLAUDE.md + constraints. Multiplied by 5 advisors, this is 5x the token budget for identical context.

**Prevention:** Brief context should be the **minimal shared context** all advisors need. File contents that only one advisor will use should be passed to that advisor only, not all 5. The orchestrator's "gather context" step must be disciplined — bias toward small, targeted context rather than comprehensive context.

---

### Trap 2: Sequential Advisor Spawn (Even Accidentally)

The parallel spawn constraint is the most important architectural invariant in the system. It's possible to accidentally violate it by: using `await` before each Task call in a loop, using a `for...of` over advisors, or structuring the orchestrator to verify each advisor before spawning the next.

The SKILL.md explicitly warns: "Do not let advisors anchor on each other. Spawn all 5 in one parallel batch. Never sequential — that contaminates the later advisors."

Any new council SKILL.md must enforce this with the same explicit instruction. The risk is that a developer building council-strategy under time pressure writes the orchestrator sequentially "just for testing" and ships it.

**Prevention:** The integration test for any new council must verify that all advisor task calls appear in a single message (same turn). If sequential spawning is detected in testing, the council is considered broken regardless of output quality.

---

## "Looks Done But Isn't" Checklist

These states look complete but have a hidden failure lurking.

| Symptom | Actual State | Detection |
|---------|--------------|-----------|
| New council produces good output on test questions | Personas borrowed from code council with domain vocabulary swapped — degrades on edge cases | Test with a question that requires domain-specific synthesis, not just vocabulary |
| install.sh completes without error | settings.json patching succeeded, but delegation chain for statusline was silently dropped | Run GSD alongside council-code, check that statusline still shows GSD content after multi-council install |
| Router suggests correct council 90% of the time | The 10% failure rate is on the highest-value questions — cross-domain decisions where the wrong council gives confident wrong advice | Test router specifically against ambiguous cross-domain questions, not just clean examples |
| All 5 advisors return output | One advisor consistently returns shorter, less specific output because its context brief was truncated or its mandate is ambiguous | Read all 5 advisor outputs and check for substance equality — not just non-empty response |
| Uninstall of one council succeeds | Shared agent files (if not namespaced) were also removed, silently breaking the remaining council | After uninstalling council-strategy, run a council-code session and verify all 5 advisors respond correctly |
| Git pre-push hook is installed | Hook fires but is slow enough to cause timeout — users see a hanging git push and kill the process | Measure full council-review wall-clock time. If >30 seconds, the hook must be async or it will be bypassed |
| Router confirm is "one quick question" | Confirm requires a full user response, not a keypress — adds one full conversational turn to every council invocation | Time the router interaction end-to-end. Measure turns required, not just words |

---

## Phase-Specific Warnings

| Phase Topic | Likely Pitfall | Mitigation |
|-------------|---------------|------------|
| Agent namespacing | Pitfall 1 — Persona collision across councils | Rename existing code council agents to `code-` prefix before any new council ships |
| Router classifier | Pitfall 2 — Keyword-based routing misfires | Define domain boundaries before writing classifier; test against ambiguous real questions |
| Multi-council install.sh | Pitfall 3 — Settings.json corruption | Extract settings patching to a standalone script with registry tracking |
| council-strategy personas | Pitfall 4 — Code-council output format applied to strategy domain | Write domain output contract first; use strategy-specific synthesis template |
| council-design personas | Pitfall 4 (repeated) — Design-specific vocabulary and rubrics | Design advisors' output contracts around visual/UX decision vocabulary, not code vocabulary |
| council-review (PR) | Pitfall 6 — Git hook noise trains users to ignore | Design hook as async + opt-in; avoid blocking pre-push |
| All new councils | Pitfall 7 — Agent description auto-trigger misfires | Include explicit "when NOT to trigger" examples in every advisor description |
| All new council SKILL.md | Performance Trap 2 — Sequential advisor spawn | Require parallel spawn verification in integration review; no exceptions |

---

## Sources

- `/Users/D052192/src/council-code/.planning/codebase/CONCERNS.md` — Fragile areas, known technical debt (HIGH confidence — current codebase state)
- `/Users/D052192/src/council-code/.planning/codebase/ARCHITECTURE.md` — Component boundaries and design decisions (HIGH confidence)
- `/Users/D052192/src/council-code/install.sh` — Settings.json patching implementation, install complexity analysis (HIGH confidence — direct inspection)
- `/Users/D052192/src/council-code/skills/council-code/SKILL.md` — Parallel spawn guardrails, synthesis requirements (HIGH confidence)
- `/Users/D052192/src/council-code/docs/personas.md` — Roster design principles, persona mandate purity requirements (HIGH confidence)
- Context7 `/anthropics/claude-code` — Agent description triggering, debugging trigger mismatches, parallel hook execution model (HIGH confidence — official docs)
- Context7 `/anthropics/claude-code` — Plugin conflicts via naming, auto-discovery failure modes, settings merge behavior (HIGH confidence — official docs)
