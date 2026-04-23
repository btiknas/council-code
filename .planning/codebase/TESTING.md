# Testing — council-code

**Mapped:** 2026-04-23

## Current State

**No automated tests exist.** This is a prompt-engineering project — the "code" is Markdown instructions interpreted by Claude Code's runtime.

## Testing Approach

Testing is currently **manual and observational:**
1. Run `/council-code` with a decision prompt
2. Verify 5 advisors spawn in parallel
3. Verify each advisor produces output matching its output format template
4. Verify synthesis contains required sections
5. Verify no advisor references another advisor's output (independence check)

## What Could Be Tested

| Area | Testable? | How |
|------|-----------|-----|
| Hook JS (update check) | Yes | Unit tests with mock `git` responses |
| Hook JS (statusline) | Yes | Unit tests with mock cache file + stdin |
| install.sh | Yes | Integration test in Docker (symlink/copy/uninstall) |
| Agent output format | Partial | Regex validation against expected section headers |
| Advisor independence | No | Requires running actual Claude inference |

## CI/CD

- No CI pipeline configured
- No GitHub Actions workflows
- Releases are tagged via version bump in `plugin.json`
