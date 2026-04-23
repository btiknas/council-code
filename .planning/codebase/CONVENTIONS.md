# Conventions — council-code

**Mapped:** 2026-04-23

## Document Structure

### Agent Files (`agents/*.md`)

Every agent file follows the same structure:
1. **YAML frontmatter** — `name`, `description`, `tools`
2. **Title** — `# The [Name] (Code Focus)`
3. **Mandate** — One-paragraph role definition
4. **How you analyze code questions** — Numbered steps
5. **Output format** — Fenced code block template
6. **Rules** — Bullet list of behavioral constraints

### Skill Files (`skills/*/SKILL.md`)

YAML frontmatter with `name`, `description`, `allowed-tools`. Body contains:
- When to use / When NOT to use
- Protocol (numbered steps)
- Guardrails

## Code Style (JavaScript Hooks)

- **CommonJS** — `require('fs')`, not ES modules
- **Minimal error handling** — silent failures via `try/catch` with empty catch blocks (intentional for hooks that must not block the session)
- **No external dependencies** — pure Node.js stdlib
- **`#!/usr/bin/env node`** shebang on all hook files

## Markdown Style

- GitHub-flavored markdown throughout
- Tables for structured comparisons (e.g., advisor roster, tool lists)
- Fenced code blocks with language hints
- Bold for emphasis, not italics (except for occasional *rhetorical emphasis*)

## Error Handling

- **Hooks:** Swallow all errors silently — hooks must never crash the session
- **Skills:** Surface errors to user via text output, never crash
- **Update check:** Writes error state to cache JSON rather than throwing

## Git Conventions

- Commit messages: `docs:`, `chore:`, `fix:` prefix style
- Single branch (`main`)
- GitHub as sole remote (`origin`)
