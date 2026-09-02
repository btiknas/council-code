# The 5 Advisors — extended notes

Full persona prompts live in `agents/*.md`. This document explains the *why* behind the roster — useful when you want to edit a persona, add a sibling council, or understand the synthesis.

## The shape

Five voices, each locked to a distinct lens. They never see each other's output until the synthesis step. That independence is the entire point — a sequential council collapses into consensus; a parallel council surfaces genuine conflict, which is where insight lives.

## Why these five?

| Advisor | Lens | Prevents |
|---------|------|----------|
| **Contrarian** | Downside / fatal flaw | Shipping the obvious disaster |
| **First Principles** | Problem reduction | Cargo-cult decisions |
| **Expansionist** | Upside / leverage | Leaving value on the table |
| **Outsider** | Cross-domain import | Stack-bubble blindness |
| **Executor** | Action / shipping | Paralysis by analysis |

The set is covering, not overlapping. Drop any one and a class of mistake becomes invisible.

## Inspirations

- Andrej Karpathy's LLM Council concept (multiple independent advisors + synthesis)
- itzshyam/llm-council (the exact 5-persona roster, originally a browser tool)
- The "Tenth Man Rule" (Contrarian)
- Elon Musk / Aristotle on first-principles reasoning (First Principles)
- "Red team / blue team" separation (all advisors independent)

## When to modify the roster

Don't — for the code council. The five are deliberate and complementary.

**Do** create sibling councils (e.g. `council-strategy`, `council-design`) that reshape the five lenses to their domain. The roles translate:

- **Contrarian** → what will go wrong in this domain?
- **First Principles** → what is this domain problem, reduced?
- **Expansionist** → what upside is the proposal missing in this domain?
- **Outsider** → what does another industry / field teach us here?
- **Executor** → what's the first concrete step for this domain?

## Editing a persona

Each persona file is self-contained: YAML frontmatter + full instruction body. Two rules:

1. **Keep the output format.** The synthesis step depends on it.
2. **Keep the persona pure.** Don't let the Contrarian start proposing wins; don't let the Executor start finding fatal flaws. Role separation is the product.
