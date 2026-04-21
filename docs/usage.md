# Usage examples

## Example 1 — Architecture decision

**You:**
> /council Should we extract the billing logic from our Django monolith into a separate service? We're at ~200k LOC, the billing module is ~15k LOC, and ops is frustrated with deploy coupling.

**What happens:**

1. The skill extracts the decision prompt + reads relevant context (billing module structure, deploy config).
2. All 5 advisors spawn in parallel:
   - **Contrarian** argues the extraction will create a distributed-transaction nightmare and that deploy coupling is cheaper to fix.
   - **First Principles** reduces the problem: "this is about blast-radius isolation and ownership, not about services."
   - **Expansionist** points out billing-as-a-platform could serve 3 other internal consumers the team forgot about.
   - **Outsider** imports from banking: "you don't need microservices, you need a ledger."
   - **Executor** picks a direction: "start with a module boundary + CI split, defer network split 6 months."
3. Chairman synthesis names the 3-way clash (Contrarian vs. Expansionist vs. Executor), the blind spot (everyone missed the ledger framing), a recommendation, and the first action.

## Example 2 — Library choice

**You:**
> Have the council review: we're picking between Prisma, Drizzle, and raw SQL for a new service. Team has TypeScript experience but no DB-migrations pain yet.

**Expected shape of output:**

- Contrarian: "Drizzle is young, Prisma's schema.prisma is a second source of truth that will diverge, raw SQL will cost you migration tooling you'll rebuild badly."
- First Principles: "You need: type safety, migrations, a query builder. Rank the three on each."
- Expansionist: "Whatever you pick becomes a platform capability for 3 more services — pick for reuse, not this one service."
- Outsider: "What do non-Node shops do here? They mostly use SQL + codegen. Is that an option?"
- Executor: "Pick Drizzle, ship the first migration this week, accept the young-lib risk."

## Example 3 — Debug hypothesis

**You:**
> /council Our p99 latency spiked 4x yesterday at 14:00. No deploy. Traffic was normal. I suspect a bad query plan but can't prove it.

The council is useful here because debugging bias is strong — the Contrarian forces you to consider "it's not a query plan," the First Principles reframes to "what signals would distinguish plan-flip from GC from upstream latency," the Executor picks which one to verify first.

## Invoking a single persona

You can skip the council and call one advisor:

> Have the Contrarian look at my PR before I push it.

> Get a First Principles take on why my auth layer feels bloated.

That invokes the persona as a subagent without the synthesis overhead.

## Tips

- Give the council *your decision*, not a vague question. "Should we X or Y?" beats "thoughts on auth?"
- Include constraints (budget, timeline, team experience, existing tech) — advisors will ignore unstated constraints.
- If the synthesis feels muddled, the decision prompt was probably fuzzy. Re-run with a sharper one.
