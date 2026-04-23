# Roadmap: Council Code — Multi-Council Decision Platform

## Overview

Eight phases that extend the proven single-council code advisor into a five-council decision platform. The work begins with foundational namespace and installer refactoring (non-negotiable pre-conditions), then builds each new council as an independently verifiable delivery, adds a router once multiple councils exist, layers in git automation after council-review is stable, and finishes with a unified installer that ships the whole system.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [ ] **Phase 1: Foundation** - Agent namespace + installer refactor (pre-conditions for all new councils)
- [ ] **Phase 2: Council Strategy** - First new council proving the multi-council pattern end-to-end
- [ ] **Phase 3: Router** - Smart council classifier with suggest-and-confirm dispatch
- [ ] **Phase 4: Council Design** - UI/UX decision council with domain-native advisor roster
- [ ] **Phase 5: Council Research** - Technical research evaluation council
- [ ] **Phase 6: Council Review** - Multi-perspective PR/code review council
- [ ] **Phase 7: Git Automation** - Opt-in git hook triggers for council-review
- [ ] **Phase 8: Installation** - Unified single-command installer for all councils

## Phase Details

### Phase 1: Foundation
**Goal**: The codebase is safe to extend with new councils — no namespace collisions, no install fragility, backward compatibility preserved
**Depends on**: Nothing (first phase)
**Requirements**: FOUND-01, FOUND-02, FOUND-03, FOUND-04
**Success Criteria** (what must be TRUE):
  1. Existing `/council-code` and `/council` triggers invoke the code council identically to before the rename
  2. All code council agent files carry `code-` prefix (e.g., `code-contrarian.md`) and no bare-name files remain in the agents directory
  3. Settings.json patching is performed by a standalone `hooks/patch-settings.js` script callable by any council installer, not inline in install.sh
  4. All council SKILL.md orchestrators include `disable-model-invocation: true` frontmatter and do not auto-load into context
**Plans**: TBD

### Phase 2: Council Strategy
**Goal**: Users can run a 5-advisor strategy council on business and product decisions with domain-native personas and synthesis
**Depends on**: Phase 1
**Requirements**: STRT-01, STRT-02, STRT-03, STRT-04
**Success Criteria** (what must be TRUE):
  1. User can invoke `/council-strategy` and receive parallel analysis from 5 strategy-native advisors (not re-skinned code personas)
  2. Each strategy advisor produces output using domain vocabulary (market fit, viability, risk/reward) rather than code-review vocabulary
  3. Chairman synthesis evaluates decisions against strategy-specific success criteria (viability, market fit, risk/reward)
  4. User can invoke any individual strategy advisor by name without running the full council
**Plans**: TBD

### Phase 3: Router
**Goal**: Users can ask any question and receive an intelligent council suggestion with reasoning, without being auto-dispatched to the wrong council
**Depends on**: Phase 2
**Requirements**: ROUT-01, ROUT-02, ROUT-03
**Success Criteria** (what must be TRUE):
  1. User can invoke the router skill and receive a specific council recommendation with reasoning for why that council fits
  2. Router always presents its suggestion and waits for user confirmation before dispatching — never auto-runs a council
  3. Each council SKILL.md carries domain-specific trigger phrases in its description frontmatter so Claude Code can surface the right council naturally
**Plans**: TBD

### Phase 4: Council Design
**Goal**: Users can run a 5-advisor design council on UI/UX decisions with domain-native personas and synthesis
**Depends on**: Phase 3
**Requirements**: DSGN-01, DSGN-02, DSGN-03, DSGN-04
**Success Criteria** (what must be TRUE):
  1. User can invoke `/council-design` and receive parallel analysis from 5 design-native advisors (not re-skinned code personas)
  2. Each design advisor produces output using domain vocabulary (usability, accessibility, visual coherence) rather than code-review vocabulary
  3. Chairman synthesis evaluates decisions against design-specific success criteria (usability, accessibility, visual coherence)
  4. User can invoke any individual design advisor by name without running the full council
**Plans**: TBD
**UI hint**: yes

### Phase 5: Council Research
**Goal**: Users can run a 5-advisor research council on technical evaluation decisions with domain-native personas and synthesis
**Depends on**: Phase 4
**Requirements**: RSCH-01, RSCH-02, RSCH-03, RSCH-04
**Success Criteria** (what must be TRUE):
  1. User can invoke `/council-research` and receive parallel analysis from 5 research-native advisors (not re-skinned code personas)
  2. Each research advisor produces output using domain vocabulary (rigor, applicability, confidence) rather than code-review vocabulary
  3. Chairman synthesis evaluates decisions against research-specific success criteria (rigor, applicability, confidence)
  4. User can invoke any individual research advisor by name without running the full council
**Plans**: TBD

### Phase 6: Council Review
**Goal**: Users can run a 5-advisor code review council on PRs and code changes with domain-native review personas and synthesis
**Depends on**: Phase 5
**Requirements**: REVW-01, REVW-02, REVW-03, REVW-04
**Success Criteria** (what must be TRUE):
  1. User can invoke `/council-review` and receive parallel analysis from 5 review-native advisors (security, performance, readability, test coverage, architecture)
  2. Each review advisor produces output using domain vocabulary (correctness, maintainability, risk) rather than generic code vocabulary
  3. Chairman synthesis evaluates code changes against review-specific success criteria (correctness, maintainability, risk)
  4. User can invoke any individual review advisor by name without running the full council
**Plans**: TBD

### Phase 7: Git Automation
**Goal**: Users who opt in receive a non-blocking suggestion to run council-review automatically when Claude commits code
**Depends on**: Phase 6
**Requirements**: AUTO-01, AUTO-02, AUTO-03, AUTO-04
**Success Criteria** (what must be TRUE):
  1. When Claude executes `git commit`, a PostToolUse hook fires and surfaces a suggestion to run council-review — it does not block the commit or auto-run the council
  2. The git hook trigger is disabled by default and must be explicitly enabled; teams that do not opt in see no behavior change
  3. Users who prefer terminal-invoked commits can install a traditional `.git/hooks/pre-commit` via `--with-git-hooks` flag in install.sh
  4. Hook output is always a suggestion, never a blocking gate — committing always succeeds regardless of hook output
**Plans**: TBD

### Phase 8: Installation
**Goal**: Users can install the complete multi-council system in one command and uninstall it cleanly
**Depends on**: Phase 7
**Requirements**: INST-01, INST-02, INST-03
**Success Criteria** (what must be TRUE):
  1. Running `./install.sh` installs all councils, the router, all agent files, and all hooks in a single command with no manual steps
  2. Running `./install.sh --uninstall` cleanly removes all installed components including councils added in this milestone
  3. Users upgrading from a code-only install retain their existing setup — the upgrade is non-destructive and preserves existing council-code configuration
**Plans**: TBD

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Foundation | 0/TBD | Not started | - |
| 2. Council Strategy | 0/TBD | Not started | - |
| 3. Router | 0/TBD | Not started | - |
| 4. Council Design | 0/TBD | Not started | - |
| 5. Council Research | 0/TBD | Not started | - |
| 6. Council Review | 0/TBD | Not started | - |
| 7. Git Automation | 0/TBD | Not started | - |
| 8. Installation | 0/TBD | Not started | - |
