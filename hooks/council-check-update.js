#!/usr/bin/env node
// council-code — SessionStart update check
//
// Runs a background `git fetch origin main` in the council-code repo,
// compares HEAD vs origin/main, and writes the result to a cache file
// that the statusline reads.
//
// Debounced: skips if the last successful check was < 1 hour ago and
// there was no update pending at that time (we keep probing if there
// IS a pending update so the user sees it stop once they pull).
//
// Silent by design — never prints anything to the session. Errors are
// swallowed into the cache. The statusline decides what the user sees.

const fs = require('fs');
const path = require('path');
const os = require('os');
const { spawn, spawnSync } = require('child_process');

const homeDir = os.homedir();
const cacheDir = path.join(homeDir, '.cache', 'council-code');
const cacheFile = path.join(cacheDir, 'update-check.json');
const DEBOUNCE_MS = 60 * 60 * 1000; // 1 hour

function writeCache(obj) {
  try {
    if (!fs.existsSync(cacheDir)) fs.mkdirSync(cacheDir, { recursive: true });
    fs.writeFileSync(cacheFile, JSON.stringify({ ...obj, checked_at: Date.now() }, null, 2));
  } catch (e) { /* silent */ }
}

function readCache() {
  try { return JSON.parse(fs.readFileSync(cacheFile, 'utf8')); }
  catch (e) { return null; }
}

// Locate the repo by resolving the skill symlink.
function findRepoDir() {
  const link = path.join(homeDir, '.claude', 'skills', 'council-update');
  try {
    const st = fs.lstatSync(link);
    if (st.isSymbolicLink()) {
      const target = fs.realpathSync(link);
      // target = .../<repo>/skills/council-update → repo root is two up
      const repo = path.resolve(target, '..', '..');
      if (fs.existsSync(path.join(repo, '.git'))) return repo;
    } else if (st.isDirectory()) {
      // Copy-mode install — no symlink to follow. Cannot auto-update.
      return null;
    }
  } catch (e) { /* not installed */ }
  return null;
}

function gitOutput(repo, args) {
  const r = spawnSync('git', ['-C', repo, ...args], { encoding: 'utf8', timeout: 15000 });
  if (r.status !== 0) return null;
  return r.stdout.trim();
}

const repo = findRepoDir();
if (!repo) {
  writeCache({ install_mode: 'unknown_or_copy', update_available: false });
  process.exit(0);
}

// Debounce: only re-fetch if last check is old OR last check saw an update.
const prev = readCache();
if (prev && prev.checked_at && (Date.now() - prev.checked_at) < DEBOUNCE_MS && !prev.update_available) {
  process.exit(0);
}

// Detach the network call so SessionStart returns immediately.
const workerPath = path.join(__dirname, 'council-check-update-worker.js');
try {
  const child = spawn(process.execPath, [workerPath, repo, cacheFile], {
    stdio: 'ignore',
    windowsHide: true,
    detached: true,
  });
  child.unref();
} catch (e) {
  writeCache({ install_mode: 'symlink', update_available: false, error: String(e.message || e) });
}
