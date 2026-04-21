# Security Policy

## Scope

`council-code` is a Claude Code plugin consisting entirely of Markdown persona definitions and a skill orchestrator. It ships **no executable code, no network calls, and no credential handling**.

The plugin runs inside Claude Code and only invokes capabilities Claude Code already has (reading files, running subagents, using user-granted tools).

## What to report

Please report:

- Prompt-injection vectors in the persona files that could be exploited when the council is invoked on untrusted code.
- Persona prompts that could be manipulated into generating harmful output (credential exfiltration instructions, destructive commands, etc.).
- Any accidental inclusion of secrets, tokens, or PII in the repo history.
- Misleading install instructions that could lead users to execute untrusted code.

## What is out of scope

- General Claude Code harness issues — report those to [Anthropic](https://github.com/anthropics/claude-code/issues).
- Claude model behavior independent of this plugin's prompts.

## How to report

Email: open a private GitHub security advisory at
<https://github.com/btiknas/council-code/security/advisories/new>

Or contact the maintainer via the email on the GitHub profile.

Please do **not** open a public issue for security reports.

## Response

Best-effort response within 7 days. This is a personal-project plugin, not a commercial product — response times depend on maintainer availability.
