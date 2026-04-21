#!/usr/bin/env node
// council-code — statusline
//
// Reads the update-check cache and renders:
//   [⬆ /council-update │] <model> │ <dir>     (standalone)
// If a delegate statusline was configured at install time, its output
// is appended at the end:
//   [⬆ /council-update │] <delegate's full output>
//
// The delegate command is stored in ~/.claude/hooks/council-statusline-next.txt
// by install.sh, which preserves whatever statusLine was set before
// (e.g. GSD's). If that file is missing or empty, we render a minimal
// standalone statusline so things still look sane without GSD.
//
// Claude Code invokes this with a JSON payload on stdin. We buffer it,
// then pipe the SAME JSON to the delegate so it sees what it expects.

const fs = require('fs');
const path = require('path');
const os = require('os');
const { spawnSync } = require('child_process');

const homeDir = os.homedir();
const cacheFile = path.join(homeDir, '.cache', 'council-code', 'update-check.json');
const delegateFile = path.join(homeDir, '.claude', 'hooks', 'council-statusline-next.txt');

let input = '';
const stdinTimeout = setTimeout(() => { render(''); process.exit(0); }, 3000);
process.stdin.setEncoding('utf8');
process.stdin.on('data', chunk => input += chunk);
process.stdin.on('end', () => {
  clearTimeout(stdinTimeout);
  render(input);
});

function render(stdinJson) {
  const prefix = councilBadge();

  const delegateOutput = runDelegate(stdinJson);
  if (delegateOutput !== null) {
    // Delegate is authoritative for model/dir/context — show its output.
    process.stdout.write(prefix + delegateOutput);
    return;
  }

  // Standalone fallback.
  let model = 'Claude';
  let dir = process.cwd();
  try {
    const data = JSON.parse(stdinJson);
    model = data?.model?.display_name || model;
    dir = data?.workspace?.current_dir || data?.cwd || dir;
  } catch (e) { /* ignore */ }
  const dirname = path.basename(dir);
  process.stdout.write(`${prefix}\x1b[2m${model}\x1b[0m │ \x1b[2m${dirname}\x1b[0m`);
}

function councilBadge() {
  try {
    const cache = JSON.parse(fs.readFileSync(cacheFile, 'utf8'));
    if (cache.update_available) {
      return '\x1b[33m⬆ /council-update\x1b[0m │ ';
    }
    if (cache.local_ahead) {
      return '\x1b[2m✱ council-code dev\x1b[0m │ ';
    }
  } catch (e) { /* no cache yet */ }
  return '';
}

function runDelegate(stdinJson) {
  let cmd;
  try {
    cmd = fs.readFileSync(delegateFile, 'utf8').trim();
  } catch (e) {
    return null;
  }
  if (!cmd) return null;

  // Run through the shell so the saved command (which may include quotes,
  // args, env) behaves exactly as it would if Claude Code invoked it directly.
  const r = spawnSync(cmd, {
    input: stdinJson,
    shell: true,
    encoding: 'utf8',
    timeout: 5000,
  });
  if (r.status !== 0 && !r.stdout) return null;
  return r.stdout || '';
}
