---
name: council-update
description: Check for council-code updates on GitHub, show the changelog of new commits, and fast-forward the local repo. Mirrors the /gsd-update flow for the council-code skill.
allowed-tools:
  - Bash
  - AskUserQuestion
---

# council-update

Check `origin/main` for new commits on the `council-code` repo, show what changed, and fast-forward-merge if the user confirms.

## When to use

- User runs `/council-update` or says "update council," "check council for updates," "refresh council-code."
- After a new release has been pushed to `https://github.com/btiknas/council-code`.

## When NOT to use

- User hasn't installed `council-code` yet — point them at the repo's `install.sh` instead.
- Plugin-mode installs — tell the user to run `/plugin update council-code`; this skill only manages the `install.sh` (symlink/copy) install path.

## Protocol

### Step 1 — Locate the repo

The `council-code` installer symlinks this skill into `~/.claude/skills/council-update`. Resolve the symlink to find the repo root, then verify it's a clone of `btiknas/council-code`.

```bash
SKILL_LINK="$HOME/.claude/skills/council-update"
if [ -L "$SKILL_LINK" ]; then
  SKILL_TARGET="$(readlink -f "$SKILL_LINK" 2>/dev/null || readlink "$SKILL_LINK")"
  # target is .../<repo>/skills/council-update → strip two levels
  REPO_DIR="$(cd "$(dirname "$SKILL_TARGET")/.." && pwd)"
else
  REPO_DIR=""
fi

if [ -z "$REPO_DIR" ] || [ ! -d "$REPO_DIR/.git" ]; then
  echo "Repo not found via symlink (maybe installed with --copy)."
  # Fall through to ask the user.
fi

# Verify the remote matches the expected repo
if [ -n "$REPO_DIR" ]; then
  git -C "$REPO_DIR" remote get-url origin 2>/dev/null | grep -q "btiknas/council-code" \
    || { echo "Remote mismatch at $REPO_DIR"; REPO_DIR=""; }
fi
```

If `REPO_DIR` is empty after this, ask the user via `AskUserQuestion` where their `council-code` clone lives, then re-validate.

### Step 2 — Fetch and compare

```bash
git -C "$REPO_DIR" fetch --quiet origin main
LOCAL="$(git -C "$REPO_DIR" rev-parse HEAD)"
REMOTE="$(git -C "$REPO_DIR" rev-parse origin/main)"
BEHIND="$(git -C "$REPO_DIR" rev-list --count HEAD..origin/main)"
AHEAD="$(git -C "$REPO_DIR" rev-list --count origin/main..HEAD)"
```

Interpret:

- `LOCAL == REMOTE` → up to date. Stop, tell the user.
- `BEHIND > 0 && AHEAD == 0` → clean fast-forward possible.
- `AHEAD > 0` → local commits not on remote; do **not** auto-merge. Warn user and stop.
- Working tree dirty (`git status --porcelain`) → warn and stop; ask user to stash/commit first.

### Step 3 — Show the changelog

If a fast-forward is possible, show the user the incoming commits:

```bash
git -C "$REPO_DIR" log --oneline --no-decorate HEAD..origin/main
```

Also surface version bumps by diffing `.claude-plugin/plugin.json`:

```bash
git -C "$REPO_DIR" diff HEAD..origin/main -- .claude-plugin/plugin.json | grep '"version"' || true
```

### Step 4 — Confirm and pull

Use `AskUserQuestion` with options:

- **Update** — run `git -C "$REPO_DIR" pull --ff-only origin main`
- **Skip** — do nothing, exit.

Never use `git pull` without `--ff-only` here. If it refuses (non-ff), report the error and stop — don't rebase or merge without explicit user instruction.

### Step 5 — Post-update

After a successful pull:

1. If the install used `--copy` mode (detect by checking `~/.claude/skills/council-code` — if it's a symlink we're fine; if it's a real directory, the user needs to re-run `install.sh --copy`), warn them.
2. If the persona agents or skill changed, remind: **restart Claude Code** to pick up the new versions.
3. Show a one-line summary: `✓ Updated council-code from <old-sha> to <new-sha> (N commits).`

## Guardrails

- **Never force-push, rebase, or reset.** Only `--ff-only` pulls.
- **Never touch the working tree** if it's dirty — user's in-progress changes win.
- **Never assume the repo path** — always resolve via symlink or ask.
- **Network failures are loud.** If `git fetch` fails, say so and stop — don't try to "update" from stale data.
