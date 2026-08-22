---
title: "The radio"
id: "F7"
shift: 7
weight: 7
subtitle: "talking to an agent from an app"
summary: "talking to an agent from an app"
today: "Build the smallest page that talks to a crew member: sign in with Fountain, start or pick a teammate, ask for one fenced block, render it, reload and get the same view back from the conversation alone. The app and the agent share a protocol (blocks parsed out of replies, specified in one file and pinned in the prompt in another) and the conversation is the record."
done_when: "Reloading rebuilds the same view from the conversation; nothing is stored on a server."
clock_in: "shift 5"
rule: "The conversation is the record; the radio only repeats what's on it."
---

## Steps

1. Server side: `API_CORS_ORIGINS` for the page origin; `OAUTH_CLIENTS` with the redirect URI. Sign in with Fountain is OAuth code + PKCE and the token is an API key.
2. Copy the client patterns from dns-desk or Mend (`src/lib/oauth.ts`, `sse.ts`, `protocol.ts`).
3. Define one block (say ```` ```hello-state ````) in `protocol.ts` and in the agent's system prompt in `spec.ts`.
4. Parse it from the transcript on load and from `/api/team/stream` while live.
5. Run the page against the mock server first, then a real instance.

## Self-paced

`bun run dev` plus a self-hosted Fountain.

## With the shift lead

The hello page on screen: send, watch the block render, reload, same view. Mend and the desk are shift 8's job.

## Back office

dns-desk README (the desk protocol); Mend README (the mend protocol).
