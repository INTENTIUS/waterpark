// The AWS desk, as a page.
//
// It holds no state a server could lose. Everything on screen is derived from
// the conversation, which is the system of record, plus the settings in this
// browser's localStorage. Reload it and the same view comes back out of the
// same turns.

import { Fountain, signIn, completeSignIn, signOut } from "./fountain.js";
import { parseBlocks, stripBlocks, approval } from "./protocol.js";

const SETTINGS = "desk:settings";
const defaults = { baseUrl: "http://localhost:4000", agent: "aws-desk" };

const state = {
  settings: { ...defaults },
  apiKey: "",
  fountain: null,
  teammate: null,
  turns: [],
  blocksByTurn: new Map(),
  toolsByTurn: new Map(),
  busy: false,
  abort: null,
};

const $ = (id) => document.getElementById(id);
const el = (tag, className, text) => {
  const node = document.createElement(tag);
  if (className) node.className = className;
  if (text !== undefined) node.textContent = text;
  return node;
};

// ── settings ────────────────────────────────────────────────────────────────

function loadSettings() {
  try {
    Object.assign(state.settings, JSON.parse(localStorage.getItem(SETTINGS) || "{}"));
  } catch {
    // A browser with no storage still gets the defaults.
  }
  state.apiKey = localStorage.getItem("desk:key") || "";
}

function saveSettings() {
  localStorage.setItem(SETTINGS, JSON.stringify(state.settings));
  if (state.apiKey) localStorage.setItem("desk:key", state.apiKey);
  else localStorage.removeItem("desk:key");
}

// ── connect ─────────────────────────────────────────────────────────────────

async function connect() {
  status("connecting");
  state.fountain = new Fountain(state.settings.baseUrl, state.apiKey);

  const me = await state.fountain.me();
  const roster = await state.fountain.team();
  const wanted = state.settings.agent;
  state.teammate = roster.find(
    (row) => row.agent?.name === wanted || row.name === wanted || row.agent_id === wanted,
  );
  if (!state.teammate) {
    throw new Error(
      `no teammate named ${wanted} on this team. The roster holds ${
        roster.map((row) => row.agent?.name || row.name).join(", ") || "nobody"
      }.`,
    );
  }

  status(`signed in as ${me.email || me.id}, talking to ${wanted}`);
  document.body.dataset.connected = "true";
  await reload();
  follow();
}

function conversationId() {
  return state.teammate?.conversation?.id || state.teammate?.conversation_id;
}

// Rebuild everything from the conversation. This is the whole load path, and
// it is also what runs when a turn ends.
async function reload() {
  const id = conversationId();
  if (!id) return;
  const [turns, events] = await Promise.all([
    state.fountain.turns(id),
    state.fountain.events(id),
  ]);

  state.turns = turns;
  state.blocksByTurn = new Map();
  state.toolsByTurn = new Map();

  const textByTurn = new Map();
  for (const event of events) {
    if (!event.turn_id || !event.blocks) continue;
    for (const block of event.blocks) {
      if (block.kind === "text") {
        textByTurn.set(event.turn_id, (textByTurn.get(event.turn_id) || "") + (block.body || ""));
      } else if (block.kind === "tool_use") {
        const tools = state.toolsByTurn.get(event.turn_id) || [];
        tools.push(block.summary || block.name || "a tool");
        state.toolsByTurn.set(event.turn_id, tools);
      }
    }
  }

  for (const [turnId, text] of textByTurn) {
    state.blocksByTurn.set(turnId, { text, blocks: parseBlocks(text) });
  }

  render();
}

// One connection for every teammate. A turn that starts or ends on our
// teammate is the only thing this page acts on.
//
// Fountain closes an idle stream after a minute, so this reattaches rather
// than going quiet. A reattach reloads the conversation first, because
// whatever happened while the socket was down is in the turns either way.
async function follow() {
  state.abort?.abort();
  const abort = new AbortController();
  state.abort = abort;
  const id = conversationId();

  while (!abort.signal.aborted) {
    try {
      await state.fountain.stream((event) => {
        if (event.conversation_id !== id) return;
        if (event.stage === "turn" && event.state === "started") {
          setBusy(true);
          // The turn exists now, so this is when what you typed appears.
          reload().catch(fail);
        }
        if (event.stage === "turn" && ["done", "failed", "interrupted"].includes(event.state)) {
          setBusy(false);
          reload().catch(fail);
        }
      }, abort.signal);
    } catch (error) {
      if (abort.signal.aborted || error.name === "AbortError") return;
      status(`stream dropped, ${error.message}. Reattaching.`);
      await new Promise((resume) => setTimeout(resume, 2000));
    }
    if (abort.signal.aborted) return;
    await new Promise((resume) => setTimeout(resume, 1000));
    if (abort.signal.aborted) return;
    await reload().catch(fail);
  }
}

// ── render ──────────────────────────────────────────────────────────────────

function render() {
  renderEstate();
  renderActivity();
}

function latest(name) {
  for (let i = state.turns.length - 1; i >= 0; i -= 1) {
    const parsed = state.blocksByTurn.get(state.turns[i].id);
    const block = parsed?.blocks.filter((b) => b.name === name).pop();
    if (block?.data) return block.data;
  }
  return null;
}

function renderEstate() {
  const pane = $("estate");
  pane.replaceChildren();
  const estate = latest("aws-state");
  if (!estate) {
    pane.append(el("p", "empty", "No estate read yet. Ask the desk what the estate holds."));
    return;
  }

  const head = el("div", "estate-head");
  head.append(el("span", "workspace", estate.workspace || "?"));
  // The account is a fact the account gave up. Where the desk reached it from
  // is not, and cannot be, because Fountain scrubs the desk's own environment
  // values out of what it records. See desk/PROMPT.md.
  head.append(el("span", "meta", estate.account || "?"));
  head.append(el("span", "meta", `read ${estate.fetched_at || "?"}`));
  if (estate.complete === false) head.append(el("span", "warn", "partial read"));
  pane.append(head);

  const search = el("input", "search");
  search.placeholder = "who can reach…";
  pane.append(search);

  const list = el("ul", "resources");
  for (const resource of estate.resources || []) {
    const row = el("li", "resource");
    row.append(el("div", "resource-name", resource.name || resource.address));
    row.append(el("div", "resource-type", resource.type || ""));
    if (resource.id) row.append(el("div", "resource-id", resource.id));
    for (const grant of resource.grants || []) row.append(el("div", "grant", grant));
    row.dataset.text = JSON.stringify(resource).toLowerCase();
    list.append(row);
  }
  pane.append(list);

  search.addEventListener("input", () => {
    const needle = search.value.trim().toLowerCase();
    for (const row of list.children) {
      row.hidden = needle !== "" && !row.dataset.text.includes(needle);
    }
  });
}

function renderActivity() {
  const pane = $("activity");
  pane.replaceChildren();
  if (!state.turns.length) {
    pane.append(el("p", "empty", "Nothing yet. Ask for access in plain words."));
    return;
  }

  for (const turn of state.turns) {
    pane.append(bubble("you", turn.prompt));

    const parsed = state.blocksByTurn.get(turn.id);
    const tools = state.toolsByTurn.get(turn.id) || [];
    if (tools.length) {
      const line = el("details", "tools");
      line.append(el("summary", null, `${tools.length} commands`));
      const list = el("ul");
      for (const tool of tools) list.append(el("li", null, tool));
      line.append(list);
      pane.append(line);
    }

    if (!parsed) continue;
    const prose = stripBlocks(parsed.text);
    if (prose) pane.append(bubble("desk", prose));
    for (const block of parsed.blocks) pane.append(renderBlock(block));
  }
  pane.scrollTop = pane.scrollHeight;
}

function bubble(who, text) {
  const node = el("div", `bubble ${who}`);
  node.append(el("div", "who", who === "you" ? "you" : "the desk"));
  node.append(el("div", "said", text || ""));
  return node;
}

function renderBlock(block) {
  if (block.error) {
    const broken = el("div", "block broken");
    broken.append(el("div", "block-head", `${block.name}, which did not parse`));
    broken.append(el("pre", null, block.raw));
    return broken;
  }
  if (block.name === "aws-plan") return renderPlan(block.data);
  if (block.name === "aws-result") return renderResult(block.data);
  if (block.name === "aws-state") {
    const node = el("div", "block state-note");
    node.append(
      el("div", "block-head", `read the estate, ${(block.data.resources || []).length} resources`),
    );
    return node;
  }
  return el("div", "block");
}

// A plan reads in the order a reviewer needs it. The access delta first,
// because that is the change. The proofs next. The file diff after that, and
// the typed changes last.
function renderPlan(plan) {
  const node = el("div", "block plan");
  const head = el("div", "block-head");
  head.append(el("span", "plan-id", plan.id || "plan"));
  head.append(el("span", "meta", `${plan.workspace || ""} · ${plan.mode || "direct"}`));
  node.append(head);

  if (plan.delta) {
    node.append(el("div", "label", "access delta"));
    node.append(el("pre", "delta", plan.delta));
  }

  if (plan.proofs?.length) {
    node.append(el("div", "label", "proofs"));
    const list = el("ul", "proofs");
    for (const proof of plan.proofs) {
      const row = el("li", `proof ${String(proof.result || "").toLowerCase()}`);
      row.append(el("span", "verdict", proof.result || "?"));
      row.append(el("span", null, `${proof.check || ""} ${proof.reason || ""}`.trim()));
      list.append(row);
    }
    node.append(list);
  }

  if (plan.diff) {
    const details = el("details", "diff");
    details.append(el("summary", null, (plan.files || []).join(", ") || "the edit"));
    details.append(el("pre", null, plan.diff));
    node.append(details);
  }

  if (plan.changes?.length) {
    const details = el("details", "changes");
    details.append(el("summary", null, `${plan.changes.length} resource changes`));
    const list = el("ul");
    for (const change of plan.changes) {
      list.append(
        el("li", null, `${change.action}${change.replace ? " (replace)" : ""}  ${change.address}`),
      );
    }
    details.append(list);
    node.append(details);
  }

  const foot = el("div", "plan-foot");
  foot.append(el("code", "digest", plan.digest || "no digest"));
  const button = el("button", "approve", `Approve ${plan.id || ""}`.trim());
  button.addEventListener("click", () => send(approval(plan.id)));
  foot.append(button);
  node.append(foot);
  return node;
}

function renderResult(result) {
  const node = el("div", `block result ${result.status || ""}`);
  // A refusal carries no plan id, because nothing was planned.
  const head = [result.plan_id, result.status].filter(Boolean).join(" ");
  node.append(el("div", "block-head", head || "a result"));
  if (result.detail) node.append(el("div", "detail", result.detail));
  return node;
}

// ── talking ─────────────────────────────────────────────────────────────────

async function send(prompt) {
  if (!prompt.trim() || state.busy) return;
  setBusy(true);
  try {
    await state.fountain.message(state.teammate.agent_id || state.teammate.agent?.id, prompt);
    $("prompt").value = "";
    await reload();
  } catch (error) {
    setBusy(false);
    fail(error);
  }
}

function setBusy(busy) {
  state.busy = busy;
  document.body.dataset.busy = busy ? "true" : "false";
  $("send").disabled = busy;
}

function status(text) {
  $("status").textContent = text;
}

function fail(error) {
  status(String(error.message || error));
}

// ── boot ────────────────────────────────────────────────────────────────────

async function boot() {
  loadSettings();

  try {
    const signedIn = await completeSignIn();
    if (signedIn) {
      state.apiKey = signedIn.apiKey;
      state.settings.baseUrl = signedIn.baseUrl;
      saveSettings();
    }
  } catch (error) {
    fail(error);
  }

  $("base-url").value = state.settings.baseUrl;
  $("agent").value = state.settings.agent;
  $("api-key").value = state.apiKey;

  $("settings").addEventListener("submit", (event) => {
    event.preventDefault();
    state.settings.baseUrl = $("base-url").value.trim();
    state.settings.agent = $("agent").value.trim();
    state.apiKey = $("api-key").value.trim();
    saveSettings();
    connect().catch(fail);
  });

  $("signin").addEventListener("click", () => {
    state.settings.baseUrl = $("base-url").value.trim();
    state.settings.agent = $("agent").value.trim();
    saveSettings();
    signIn(state.settings.baseUrl).catch(fail);
  });

  $("signout").addEventListener("click", async () => {
    if (state.fountain) await signOut(state.fountain);
    state.apiKey = "";
    saveSettings();
    window.location.reload();
  });

  $("composer").addEventListener("submit", (event) => {
    event.preventDefault();
    send($("prompt").value);
  });

  if (state.apiKey) connect().catch(fail);
  else status("sign in, or paste an API key");
}

boot();
