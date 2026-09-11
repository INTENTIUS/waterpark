// A Fountain client, small enough to read in one sitting.
//
// It calls the API with fetch and a bearer key, the way fountain-team and
// dns-desk do. There is no SDK and no build step, so what runs in the browser
// is what is in this file.
//
// Two things the instance has to be told about a page on another origin.
// API_CORS_ORIGINS has to admit this page's origin, and OAUTH_CLIENTS has to
// name this client and its exact redirect URI. The class stack's compose file
// sets both for http://localhost:1313.

export const CLIENT_ID = "aws-desk";

export class Fountain {
  constructor(baseUrl, apiKey) {
    this.baseUrl = (baseUrl || "").replace(/\/+$/, "");
    this.apiKey = apiKey || "";
  }

  async request(method, path, body) {
    const response = await fetch(this.baseUrl + path, {
      method,
      headers: {
        Authorization: `Bearer ${this.apiKey}`,
        ...(body ? { "Content-Type": "application/json" } : {}),
      },
      ...(body ? { body: JSON.stringify(body) } : {}),
    });
    if (!response.ok) {
      let detail = "";
      try {
        detail = JSON.stringify(await response.json());
      } catch {
        detail = await response.text().catch(() => "");
      }
      const error = new Error(`${method} ${path} ${response.status} ${detail}`.trim());
      error.status = response.status;
      throw error;
    }
    if (response.status === 204) return null;
    return response.json();
  }

  me() {
    return this.request("GET", "/api/auth/me");
  }

  // The roster. One row per teammate, each with its agent and its one thread.
  async team() {
    const body = await this.request("GET", "/api/team");
    return body.data || body;
  }

  message(agentId, prompt) {
    return this.request("POST", `/api/team/${agentId}/messages`, { prompt });
  }

  async turns(conversationId) {
    const body = await this.request("GET", `/api/conversations/${conversationId}/turns`);
    return body.data || body;
  }

  // The log feed, paged to the end. `blocks=true` means the server hands back
  // the runtime's output already parsed, so this page never learns a dialect.
  async events(conversationId, { streams = "acp,stdout", limit = 500 } = {}) {
    const all = [];
    let after = null;
    for (;;) {
      const query = new URLSearchParams({ blocks: "true", streams, limit: String(limit) });
      if (after !== null) query.set("after", String(after));
      const body = await this.request(
        "GET",
        `/api/conversations/${conversationId}/events?${query}`,
      );
      all.push(...(body.data || []));
      if (!body.meta || !body.meta.has_more) return all;
      after = body.meta.next_cursor;
    }
  }

  // One SSE connection for every teammate. EventSource cannot carry a bearer
  // key, so this reads the stream out of fetch by hand. onEvent gets each
  // parsed payload; the loop ends when the caller aborts.
  async stream(onEvent, signal) {
    const url = `${this.baseUrl}/api/team/stream?blocks=true`;
    const response = await fetch(url, {
      headers: { Authorization: `Bearer ${this.apiKey}`, Accept: "text/event-stream" },
      signal,
    });
    if (!response.ok || !response.body) throw new Error(`stream ${response.status}`);

    const reader = response.body.getReader();
    const decoder = new TextDecoder();
    let buffer = "";
    for (;;) {
      const { done, value } = await reader.read();
      if (done) return;
      buffer += decoder.decode(value, { stream: true });
      const frames = buffer.split("\n\n");
      buffer = frames.pop() || "";
      for (const frame of frames) {
        const data = frame
          .split("\n")
          .filter((line) => line.startsWith("data:"))
          .map((line) => line.slice(5).trim())
          .join("");
        if (!data) continue;
        try {
          onEvent(JSON.parse(data));
        } catch {
          // A heartbeat or a comment. Nothing to route.
        }
      }
    }
  }
}

// Sign in with Fountain. OAuth 2.0 authorization code with PKCE, as a public
// client. The token that comes back is an API key, and signing out revokes it.

function randomString(bytes = 32) {
  const raw = crypto.getRandomValues(new Uint8Array(bytes));
  return base64url(raw.buffer);
}

function base64url(buffer) {
  const bytes = new Uint8Array(buffer);
  let binary = "";
  for (const byte of bytes) binary += String.fromCharCode(byte);
  return btoa(binary).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

async function challenge(verifier) {
  const digest = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(verifier));
  return base64url(digest);
}

export function redirectUri() {
  return window.location.origin + window.location.pathname;
}

export async function signIn(baseUrl) {
  const verifier = randomString();
  const state = randomString(16);
  sessionStorage.setItem("desk:pkce", JSON.stringify({ verifier, state, baseUrl }));
  const query = new URLSearchParams({
    client_id: CLIENT_ID,
    redirect_uri: redirectUri(),
    code_challenge: await challenge(verifier),
    code_challenge_method: "S256",
    state,
  });
  window.location.assign(`${baseUrl.replace(/\/+$/, "")}/oauth/authorize?${query}`);
}

// Called on load. Returns an api key when this load is the redirect back from
// the consent page, and null otherwise.
export async function completeSignIn() {
  const params = new URLSearchParams(window.location.search);
  const code = params.get("code");
  if (!code) return null;

  const pending = JSON.parse(sessionStorage.getItem("desk:pkce") || "null");
  sessionStorage.removeItem("desk:pkce");
  history.replaceState({}, "", redirectUri());
  if (!pending) throw new Error("this page did not start that sign-in");
  if (pending.state !== params.get("state")) throw new Error("the state did not match");

  const response = await fetch(`${pending.baseUrl.replace(/\/+$/, "")}/api/oauth/token`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      grant_type: "authorization_code",
      code,
      code_verifier: pending.verifier,
      client_id: CLIENT_ID,
      redirect_uri: redirectUri(),
    }),
  });
  if (!response.ok) throw new Error(`sign-in failed, ${response.status}`);
  const token = await response.json();
  return { apiKey: token.access_token, baseUrl: pending.baseUrl };
}

export async function signOut(fountain) {
  try {
    await fountain.request("POST", "/api/oauth/revoke");
  } catch {
    // An already dead key is a fine outcome for a sign-out.
  }
}
