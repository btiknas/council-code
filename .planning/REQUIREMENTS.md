# Requirements: Council Code — Multi-Council Decision Platform

**Defined:** 2026-04-23
**Core Value:** Independent, parallel multi-perspective analysis that catches blind spots, fatal flaws, and missed opportunities before decisions become costly mistakes.

## v1 Requirements

Requirements for initial release. Each maps to roadmap phases.

### Foundation

- [ ] **FOUND-01**: Existing agent files renamed to council-prefixed names (e.g. `contrarian.md` → `code-contrarian.md`) to prevent namespace collision across councils
- [ ] **FOUND-02**: Inline settings.json patcher extracted to standalone reusable script that all councils share
- [ ] **FOUND-03**: All council orchestrator SKILL.md files include `disable-model-invocation: true` frontmatter to prevent auto-loading into context
- [ ] **FOUND-04**: Existing `/council-code` and `/council` triggers continue to work identically after refactor

### Router

- [ ] **ROUT-01**: User can invoke a router skill that classifies their question and suggests the most appropriate council
- [ ] **ROUT-02**: Router always presents suggestion with reasoning and waits for user confirmation before dispatching (never auto-dispatch)
- [ ] **ROUT-03**: Each council SKILL.md has domain-specific trigger phrases in its description frontmatter for natural language detection

### Council: Strategy

- [ ] **STRT-01**: 5 domain-native advisor personas for business/product decisions (not re-skinned code advisors)
- [ ] **STRT-02**: Each advisor has a unique output format contract appropriate to strategy domain
- [ ] **STRT-03**: Chairman synthesis uses strategy-specific success criteria (viability, market fit, risk/reward)
- [ ] **STRT-04**: User can invoke individual strategy advisors without running full council

### Council: Design

- [ ] **DSGN-01**: 5 domain-native advisor personas for UI/UX decisions (not re-skinned code advisors)
- [ ] **DSGN-02**: Each advisor has a unique output format contract appropriate to design domain
- [ ] **DSGN-03**: Chairman synthesis uses design-specific success criteria (usability, accessibility, visual coherence)
- [ ] **DSGN-04**: User can invoke individual design advisors without running full council

### Council: Research

- [ ] **RSCH-01**: 5 domain-native advisor personas for technical research evaluation
- [ ] **RSCH-02**: Each advisor has a unique output format contract appropriate to research domain
- [ ] **RSCH-03**: Chairman synthesis uses research-specific success criteria (rigor, applicability, confidence)
- [ ] **RSCH-04**: User can invoke individual research advisors without running full council

### Council: Review

- [ ] **REVW-01**: 5 domain-native advisor personas for multi-perspective PR/code review
- [ ] **REVW-02**: Each advisor has a unique output format contract appropriate to review domain
- [ ] **REVW-03**: Chairman synthesis uses review-specific success criteria (correctness, maintainability, risk)
- [ ] **REVW-04**: User can invoke individual review advisors without running full council

### Git Automation

- [ ] **AUTO-01**: PostToolUse hook triggers council-review automatically when Claude executes `git commit`
- [ ] **AUTO-02**: Git hook trigger is opt-in and async (non-blocking — user is not forced to wait)
- [ ] **AUTO-03**: Traditional `.git/hooks/pre-commit` available via `--with-git-hooks` install flag for terminal-invoked commits
- [ ] **AUTO-04**: Hook outputs a suggestion to run council-review, not a blocking gate

### Installation

- [ ] **INST-01**: Single `./install.sh` installs all councils, router, and hooks in one command
- [ ] **INST-02**: `./install.sh --uninstall` cleanly removes all components including new councils
- [ ] **INST-03**: Install is backward-compatible — upgrading from code-only install to multi-council preserves existing setup

## v2 Requirements

Deferred to future release. Tracked but not in current roadmap.

### Enhanced Routing

- **ROUT-04**: Single advisor "office hours" mode — router picks one most relevant advisor for a quick, cheap opinion
- **ROUT-05**: Split routing — router can identify cross-domain questions and suggest running two councils sequentially

### Quality of Life

- **QOL-01**: Statusline badge showing count of installed councils
- **QOL-02**: `/council-help` skill listing all available councils and their advisors
- **QOL-03**: Council invocation history (last 5 council runs, accessible via command)

## Out of Scope

| Feature | Reason |
|---------|--------|
| MCP server wrapper | Adds compiled build step; pure-Markdown architecture is zero-maintenance |
| Cross-council synthesis | Synthesis-of-syntheses is too abstract to act on; extreme token cost (25+ agents) |
| Cost-aware advisor skipping | Breaks covering-set property; dropped advisor = invisible class of mistakes |
| À la carte installation | Adds install complexity; router needs all councils available |
| Web UI / visualization | CLI tool; structured markdown output is the UI |
| Persistent session memory | Councils are single-turn decision tools, not conversation partners |
| 6+ advisors per council | Dilutes synthesis tractability; 5 is proven ceiling; split into sub-councils instead |
| Auto-dispatch (no confirmation) | Wrong council = 5 useless agent runs; destroys trust |
| Streaming partial advisor outputs | Destroys parallel independence; partial outputs anchor later advisors |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| FOUND-01 | Phase 1 | Pending |
| FOUND-02 | Phase 1 | Pending |
| FOUND-03 | Phase 1 | Pending |
| FOUND-04 | Phase 1 | Pending |
| STRT-01 | Phase 2 | Pending |
| STRT-02 | Phase 2 | Pending |
| STRT-03 | Phase 2 | Pending |
| STRT-04 | Phase 2 | Pending |
| ROUT-01 | Phase 3 | Pending |
| ROUT-02 | Phase 3 | Pending |
| ROUT-03 | Phase 3 | Pending |
| DSGN-01 | Phase 4 | Pending |
| DSGN-02 | Phase 4 | Pending |
| DSGN-03 | Phase 4 | Pending |
| DSGN-04 | Phase 4 | Pending |
| RSCH-01 | Phase 5 | Pending |
| RSCH-02 | Phase 5 | Pending |
| RSCH-03 | Phase 5 | Pending |
| RSCH-04 | Phase 5 | Pending |
| REVW-01 | Phase 6 | Pending |
| REVW-02 | Phase 6 | Pending |
| REVW-03 | Phase 6 | Pending |
| REVW-04 | Phase 6 | Pending |
| AUTO-01 | Phase 7 | Pending |
| AUTO-02 | Phase 7 | Pending |
| AUTO-03 | Phase 7 | Pending |
| AUTO-04 | Phase 7 | Pending |
| INST-01 | Phase 8 | Pending |
| INST-02 | Phase 8 | Pending |
| INST-03 | Phase 8 | Pending |

**Coverage:**
- v1 requirements: 30 total
- Mapped to phases: 30
- Unmapped: 0 ✓

---
*Requirements defined: 2026-04-23*
*Last updated: 2026-04-23 after initial definition*
