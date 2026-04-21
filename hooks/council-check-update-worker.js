#!/usr/bin/env node
// Background worker: fetches origin/main and writes update status to cache.
// Invoked (detached) by council-check-update.js.

const fs = require('fs');
const { spawnSync } = require('child_process');

const [, , repo, cacheFile] = process.argv;
if (!repo || !cacheFile) process.exit(0);

function git(args) {
  const r = spawnSync('git', ['-C', repo, ...args], { encoding: 'utf8', timeout: 30000 });
  return r.status === 0 ? r.stdout.trim() : null;
}

function writeCache(obj) {
  try {
    fs.writeFileSync(cacheFile, JSON.stringify({ ...obj, checked_at: Date.now() }, null, 2));
  } catch (e) { /* silent */ }
}

// Sanity: is this actually the council-code repo?
const remote = git(['remote', 'get-url', 'origin']);
if (!remote || !/btiknas\/council-code/.test(remote)) {
  writeCache({ install_mode: 'wrong_remote', update_available: false });
  process.exit(0);
}

// Fetch. A failure here (offline, auth) is not the user's problem —
// we just mark the cache stale and move on.
const fetched = spawnSync('git', ['-C', repo, 'fetch', '--quiet', 'origin', 'main'], { timeout: 30000 });
if (fetched.status !== 0) {
  writeCache({ install_mode: 'symlink', update_available: false, fetch_failed: true });
  process.exit(0);
}

const local = git(['rev-parse', 'HEAD']);
const remoteSha = git(['rev-parse', 'origin/main']);
const behind = parseInt(git(['rev-list', '--count', 'HEAD..origin/main']) || '0', 10);
const ahead = parseInt(git(['rev-list', '--count', 'origin/main..HEAD']) || '0', 10);

writeCache({
  install_mode: 'symlink',
  update_available: behind > 0 && ahead === 0,
  local_ahead: ahead > 0,
  behind,
  ahead,
  local,
  remote: remoteSha,
});
