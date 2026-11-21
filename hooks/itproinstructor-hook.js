#!/usr/bin/env node
'use strict';
/*
 * ITproinstructor persona hooks.
 *
 *   node itproinstructor-hook.js prompt  [dataDir]   UserPromptSubmit
 *   node itproinstructor-hook.js stop    [dataDir]   Stop
 *   node itproinstructor-hook.js session [dataDir]   SessionStart (matcher: compact)
 *
 * Claude Code sends the hook input as JSON on stdin. Text this script prints on stdout
 * for UserPromptSubmit and SessionStart is added to Claude's context. For Stop it prints
 * a JSON decision.
 *
 * The script prints nothing and exits 0 unless the itproinstructor persona is active in
 * the session, so every other persona and every session without a persona is unaffected.
 * It never exits 2 and never blocks a prompt. Any error ends in a silent exit 0.
 *
 * Why it exists: the rules that only apply to some messages are kept out of the persona
 * file. This script reads the user's message, works out which of those rules it triggers,
 * and gives Claude that rule's text the first time and only its number after that.
 * Rule text is read from skills/persona/references/itproinstructor/procedures.md, so there
 * is one copy of each rule.
 */

const fs = require('fs');
const os = require('os');
const path = require('path');

const MODE = process.argv[2] || 'prompt';
const PLUGIN_ROOT = path.resolve(__dirname, '..');
const PERSONA_DIR = path.join(PLUGIN_ROOT, 'skills', 'persona', 'personas');
const PERSONA_FILE = path.join(PERSONA_DIR, 'itproinstructor.md');
const RULES_FILE = path.join(PLUGIN_ROOT, 'skills', 'persona', 'references', 'itproinstructor', 'procedures.md');
const NAME = 'itproinstructor';
const TAG = '[itpro-hook]';
const MAX_SCAN_BYTES = 50 * 1024 * 1024;

// ---------- state ----------

function dataDir() {
  let d = process.argv[3];
  if (!d || d.indexOf('${') !== -1) d = process.env.CLAUDE_PLUGIN_DATA;
  if (!d) d = path.join(os.tmpdir(), 'claude-persona-plugin');
  d = path.join(d, NAME);
  fs.mkdirSync(d, { recursive: true });
  return d;
}

function statePath(sessionId) {
  const safe = String(sessionId || 'no-session').replace(/[^A-Za-z0-9_-]/g, '_').slice(0, 100);
  return path.join(dataDir(), safe + '.json');
}

function loadState(sessionId) {
  const blank = { active: false, offset: 0, transcript: '', delivered: [], struggle: 0, offered12: false, compactNote: false };
  try {
    return Object.assign(blank, JSON.parse(fs.readFileSync(statePath(sessionId), 'utf8')));
  } catch (e) {
    return blank;
  }
}

function saveState(sessionId, state) {
  try {
    fs.writeFileSync(statePath(sessionId), JSON.stringify(state));
  } catch (e) { /* state is best effort */ }
}

// Remove state files not touched for 30 days. Runs on activation only.
function pruneState() {
  try {
    const dir = dataDir();
    const cutoff = Date.now() - 30 * 24 * 60 * 60 * 1000;
    for (const f of fs.readdirSync(dir)) {
      if (!f.endsWith('.json')) continue;
      const p = path.join(dir, f);
      if (fs.statSync(p).mtimeMs < cutoff) fs.unlinkSync(p);
    }
  } catch (e) { /* best effort */ }
}

// ---------- is the persona active? ----------

// The persona skills make Claude say "Persona activated: **<name>**." and
// "Persona deactivated." Only Claude's own replies count: the same words also sit inside
// the skill text, which is in the transcript as a user-side entry.
const MARKER = /Persona activated: \*\*([a-z0-9-]+)\*\*|Persona deactivated\./g;

function assistantText(entry) {
  if (!entry || entry.type !== 'assistant' || !entry.message) return '';
  const c = entry.message.content;
  if (typeof c === 'string') return c;
  if (!Array.isArray(c)) return '';
  return c.filter(b => b && b.type === 'text' && typeof b.text === 'string').map(b => b.text).join('\n');
}

// Reads only the part of the transcript added since the last call.
function scanTranscript(state, transcriptPath) {
  if (!transcriptPath) return;
  let size;
  try { size = fs.statSync(transcriptPath).size; } catch (e) { return; }
  if (state.transcript !== transcriptPath || state.offset > size) {
    state.transcript = transcriptPath;
    state.offset = 0;
  }
  let start = state.offset;
  if (size - start > MAX_SCAN_BYTES) start = size - MAX_SCAN_BYTES;
  if (size <= start) return;
  const buf = Buffer.alloc(size - start);
  const fd = fs.openSync(transcriptPath, 'r');
  try { fs.readSync(fd, buf, 0, buf.length, start); } finally { fs.closeSync(fd); }
  const lastNewline = buf.lastIndexOf(0x0a);
  if (lastNewline === -1) return;               // no complete line yet
  state.offset = start + lastNewline + 1;
  const lines = buf.slice(0, lastNewline).toString('utf8').split('\n');
  for (const line of lines) {
    if (line.indexOf('Persona ') === -1) continue;
    let entry;
    try { entry = JSON.parse(line); } catch (e) { continue; }
    const text = assistantText(entry);
    if (!text) continue;
    let m;
    MARKER.lastIndex = 0;
    while ((m = MARKER.exec(text)) !== null) {
      state.active = m[1] === NAME;
    }
  }
}

// The typed line reaches the hook before Claude answers it, so the transcript cannot
// show this activation yet. Returns 'on', 'off' or null (no change).
function typedCommand(prompt) {
  const m = prompt.trim().match(/^\/persona(?::([a-z0-9-]+))?(?:\s+([\s\S]*))?$/i);
  if (!m) return { isCommand: false, change: null };
  const skill = (m[1] || '').toLowerCase();
  if (skill === NAME) return { isCommand: true, change: 'on' };
  if (skill && skill !== 'persona') return { isCommand: true, change: null };
  const arg = (m[2] || '').trim().toLowerCase();
  const first = arg.split(/\s+/)[0] || '';
  if (['off', 'deactivate', 'reset'].includes(first)) return { isCommand: true, change: 'off' };
  if (['', 'help', 'list', 'ref', 'create', 'edit', 'delete', 'remove', 'spawn', 'multi'].includes(first)) {
    return { isCommand: true, change: null };
  }
  // "/persona <name>": same matching as the persona skill - exact, then one partial match.
  const wanted = arg.replace(/\s+/g, '-');
  let names = [];
  try { names = fs.readdirSync(PERSONA_DIR).filter(f => f.endsWith('.md')).map(f => f.slice(0, -3)); } catch (e) { /* none */ }
  let resolved = names.includes(wanted) ? wanted : null;
  if (!resolved) {
    const partial = names.filter(n => n.indexOf(wanted) !== -1);
    if (partial.length === 1) resolved = partial[0];
  }
  if (!resolved) return { isCommand: true, change: null };
  return { isCommand: true, change: resolved === NAME ? 'on' : 'off' };
}

// ---------- rule text ----------

function ruleSections() {
  const sections = {};
  let text;
  try { text = fs.readFileSync(RULES_FILE, 'utf8'); } catch (e) { return sections; }
  let key = null;
  for (const line of text.split(/\r?\n/)) {
    const h = line.match(/^## (.+?)\s*$/);
    if (h) { key = /^(rule-\d+|questions-[a-z]+)$/.test(h[1]) ? h[1] : null; continue; }
    if (key) sections[key] = (sections[key] || '') + line + '\n';
  }
  for (const k of Object.keys(sections)) sections[k] = sections[k].trim();
  return sections;
}

// ---------- routing: "if he says this, then this rule" ----------

const RX = {
  recall: /\bwhat (was|were|is) (that|the) (command|cmdlet|script|one)\b|\bthe (one|command|script) we used\b|\bagain\?\s*$/,
  confirm: /\bwill (this|that|it) work\b|^\s*(will|would|can|could|does|do|is|are|should|did|has|have)\b[^?\n]{0,300}\?\s*$/,
  howto: /\bhow (do|can|should|would|could) (i|we|you)\b|\bhow to\b|\bstep[- ]by[- ]step\b|\bwalk me through\b|\bshow me how\b/,
  // Weaker signs of a how-to. Ignored when the message is a reported sequence (rule 7).
  howtoWeak: /\bset(ting)? ?up\b|\binstall\b|\bconfigure\b|\bfix\b/,
  command: /\b(commands?|cmdlets?|scripts?|powershell|pwsh|one-?liner|cmd|bash|terminal)\b/,
  seq: /\b(then|after|afterwards|now|since|when i|once i|i (ran|did|installed|updated|changed|rebooted|restarted|tried|clicked|opened|joined|moved|deleted|removed|upgraded|enabled|disabled|added))\b/,
  result: /\b(broke|broken|stopped|fail(ed|s|ing)?|errors?|won'?t|can'?t|cannot|doesn'?t|isn'?t|not working|no longer|crash(ed|es|ing)?|blue ?screen|bsod|black screen|froze|frozen|hangs?|timed? ?out|denied|refused|unreachable|keeps)\b/,
  missing: /\b(that thing|the same (error|issue|problem|thing)|same as (before|last time)|like last time|like before|as before|the other day|you know (the|what)|remember when|from (last|the other) (time|chat))\b/,
  version: /\b(versions?|builds?|kb\d{6,}|updates?|updated|upgrade|release|latest|newest|install)\b/,
  lookup: /\bkb\d{6,}\b|\b0x[0-9a-f]{8}\b|\bevent id\b|\berror code\b|\b\d{5}\.\d{3,5}\b/,
  security: /\b(secur|harden|audit|pen ?test|vulnerab|exploit|malware)\w*|\bscan my\b/,
  vault: /\b(vault|hand-?off)\b|\b(write|save|add|put) (it|this|that) (to|in|into)\b/,
  explain: /\b(explain|what is|what'?s an?|what are|what does|difference between|why does|why is)\b/,
  struggle: /\b(that'?s not what i (asked|said|meant|wanted)|not what i (asked|said|meant|wanted)|i already (said|told)|i (just )?told you|you'?re not listening|wrong again|still wrong)\b/,
  stuck: /\b(stuck|that'?s not what i see|i don'?t see (that|it)|it'?s not there|didn'?t work)\b/
};

const PROBLEM = [
  ['network', /\b(dns|dhcp|ip|ping|network|wi-?fi|ethernet|vlan|router|switch|gateway|internet|nslookup|firewall|vpn|subnet|adapter)\b/g],
  ['ad', /\b(gpo|group policy|gpupdate|gpresult|active directory|domain|kerberos|ldap|domain controller)\b/g],
  ['os', /\b(windows update|updates?|updated|kb\d+|upgrade|patch|cumulative|rollback|boot)\b/g],
  ['terminal', /\b(scripts?|commands?|powershell|pwsh|cmd|terminal|cmdlets?|exit code|syntax|module|scheduled task)\b/g],
  ['hardware', /\b(blue ?screen|bsod|black screen|crash(ed|es|ing)?|power|shut ?down|overheat\w*|fan|ram|ssd|disk|drive|gpu|battery|froze|frozen)\b/g]
];

// One-line applications of rules that are already in the persona file. Given once.
const HINT = {
  confirm: 'Confirm question: answer yes or no, then ask if he wants to see the proof.',
  explain: 'Explain simply, assuming no prior knowledge. Define each term the first time it appears.',
  lookup: 'He named a KB, error code, event ID or build: look up that exact item and its known issues before answering.',
  security: 'Security check: read references/itproinstructor/security-checks.md first. His own systems only, to find and fix.',
  vault: 'Vault write: write it without asking first. Mark anything he has not said or confirmed as "not confirmed". Keep only current information.',
  stuck: 'He is stuck on a step: stop the block and work on that step. Compare what he saw with what the step said should be on screen.',
  seqfacts: 'Before choosing the three questions, if you have a shell on his Windows machine, run collect-windows-facts.ps1 and do not ask for anything it reports. Do not ask for output he already pasted.'
};

function route(prompt, state) {
  const p = prompt.toLowerCase();
  const rules = new Set();
  const hints = [];
  let questions = null;

  if (RX.recall.test(p)) rules.add(11);
  const sequence = RX.seq.test(p) && RX.result.test(p);
  if (RX.howto.test(p) || (!sequence && RX.howtoWeak.test(p))) { rules.add(4); rules.add(5); }
  if (RX.command.test(p)) rules.add(5);
  if (sequence) {
    rules.add(7);
    hints.push('seqfacts');
    let best = 0;
    for (const [name, rx] of PROBLEM) {
      const n = (p.match(rx) || []).length;
      if (n > best) { best = n; questions = name; }
    }
  }
  if (RX.missing.test(p)) rules.add(9);
  if (RX.version.test(p)) rules.add(10);
  if (RX.struggle.test(p)) {
    state.struggle += 1;
    if (state.struggle >= 2 && !state.offered12) { rules.add(12); state.offered12 = true; state.why12 = 'b'; }
  }
  if (RX.confirm.test(p) && !rules.has(11)) hints.push('confirm');
  for (const k of ['explain', 'lookup', 'security', 'vault', 'stuck']) if (RX[k].test(p)) hints.push(k);
  return { rules: Array.from(rules).sort((a, b) => a - b), hints, questions };
}

function buildPromptContext(prompt, state) {
  const r = route(prompt, state);
  const sections = ruleSections();
  const out = [];
  const list = r.rules.length ? r.rules.join(', ') : 'none';
  out.push(`${TAG} ITproinstructor active. Rules 1, 2, 3, 6, 8 apply. Triggered by this message: ${list}.`);

  if (state.compactNote) {
    out.push('This session was compacted, so it is a long session that uses a lot of context. If he is also using the persona in different projects, that is rule 12 situation (a).');
    state.compactNote = false;
  }
  for (const n of r.rules) {
    const key = 'rule-' + n;
    if (state.delivered.includes(key) || !sections[key]) continue;
    out.push(sections[key]);
    state.delivered.push(key);
  }
  if (r.rules.includes(12) && state.why12 === 'b') {
    out.push('Rule 12 trigger: he has corrected the persona two or more times in this session - situation (b). Offer it once, after the questions for the current task.');
    state.why12 = '';
  }
  if (r.questions) {
    const key = 'questions-' + r.questions;
    if (sections[key] && !state.delivered.includes(key)) {
      out.push('Default three questions for this problem type (from research, not his words; swap out any he already answered): ' + sections[key]);
      state.delivered.push(key);
    }
  }
  const seen = [];
  for (const h of r.hints) {
    const key = 'hint-' + h;
    if (state.delivered.includes(key)) { seen.push(h); continue; }
    out.push('- ' + HINT[h]);
    state.delivered.push(key);
  }
  if (seen.length) out.push('Also applies (given earlier): ' + seen.join(', ') + '.');
  return out.join('\n');
}

// ---------- Stop: check the reply against the hard rules ----------

function stripQuoted(text) {
  return text
    .replace(/```[\s\S]*?```/g, ' ')            // code blocks
    .replace(/`[^`\n]*`/g, ' ')                 // inline code
    .replace(/^\s*>.*$/gm, ' ')                 // quoted lines
    .replace(/"[^"\n]{0,300}"/g, ' ')           // "quoted"
    .replace(/“[^”\n]{0,300}”/g, ' '); // curly quoted
}

function checkReply(reply) {
  const problems = [];
  const text = stripQuoted(reply);
  const hedge = text.match(/\b(I think|most likely|probably|inferred)\b/i);
  if (hedge) {
    problems.push(`Rule 2: the reply uses "${hedge[1]}". Replace it with what was actually seen and the circumstances required to get that result, or with "I don't know" if you looked and found no evidence either way.`);
  }
  let run = 0, longest = 0;
  for (const line of text.split('\n')) {
    const m = line.match(/^\s*(\d{1,2})[.)]\s/);
    if (m) {
      const n = parseInt(m[1], 10);
      run = (n === run + 1) ? n : (n === 1 ? 1 : 0);
      if (run > longest) longest = run;
    }
    // Text between items does not reset the count: a list that keeps counting up is one list.
  }
  if (longest > 8) {
    problems.push(`Rule 4: the reply has a numbered list of ${longest} items. If these are steps for him to follow, give at most 8, then ask if he is ready for the next steps or ran into a problem. If the list is not steps for him to follow, answer only: "Checked: not a step list."`);
  }
  return problems;
}

// ---------- main ----------

function readStdin() {
  return new Promise(resolve => {
    let data = '';
    if (process.stdin.isTTY) { resolve(''); return; }
    process.stdin.setEncoding('utf8');
    process.stdin.on('data', c => { data += c; });
    process.stdin.on('end', () => resolve(data));
    process.stdin.on('error', () => resolve(data));
  });
}

async function main() {
  let input = {};
  try { input = JSON.parse((await readStdin()) || '{}'); } catch (e) { input = {}; }
  const sessionId = input.session_id;
  const state = loadState(sessionId);

  if (MODE === 'prompt') {
    const prompt = typeof input.prompt === 'string' ? input.prompt : '';
    scanTranscript(state, input.transcript_path);
    const cmd = typedCommand(prompt);
    if (cmd.change === 'on') {
      pruneState();
      state.active = true;
      state.delivered = [];
      state.struggle = 0;
      state.offered12 = false;
      saveState(sessionId, state);
      process.stdout.write(`${TAG} Hooks are running in this session. After this message each of his messages comes with one ${TAG} line naming the rules it triggers; do not read procedures.md or recognition.md for rule text. Load your tools now, as the persona file's "On activation" block says.\n`);
      return;
    }
    if (cmd.change === 'off') state.active = false;
    if (cmd.isCommand || !state.active || prompt.trim() === '') { saveState(sessionId, state); return; }
    const context = buildPromptContext(prompt, state);
    saveState(sessionId, state);
    process.stdout.write(context + '\n');
    return;
  }

  if (MODE === 'session') {
    if (!state.active) return;
    state.delivered = [];
    state.compactNote = true;
    saveState(sessionId, state);
    let persona = '';
    try { persona = fs.readFileSync(PERSONA_FILE, 'utf8'); } catch (e) { /* fall through */ }
    if (persona) {
      process.stdout.write(`${TAG} The conversation was compacted. The ITproinstructor persona is still active. Its file follows; re-apply it to every reply.\n\n${persona}\n`);
    } else {
      process.stdout.write(`${TAG} The conversation was compacted. The ITproinstructor persona is still active. Read skills/persona/personas/itproinstructor.md again before the next reply.\n`);
    }
    return;
  }

  if (MODE === 'stop') {
    if (!state.active || input.stop_hook_active) return;   // never block twice in a row
    const reply = typeof input.last_assistant_message === 'string' ? input.last_assistant_message : '';
    if (!reply) return;
    const problems = checkReply(reply);
    if (!problems.length) return;
    process.stdout.write(JSON.stringify({
      decision: 'block',
      reason: `${TAG} The reply breaks the persona's rules. Send the corrected reply now, and only the corrected reply.\n- ` + problems.join('\n- ')
    }) + '\n');
  }
}

main().catch(() => {}).finally(() => { process.exitCode = 0; });
