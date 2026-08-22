---
title: "Talking to an agent from an app"
number: "F7"
weight: 8
theme: "An app and an agent share a protocol: fenced blocks parsed out of replies, specified in one file and pinned in the agent's prompt in another (\"change one, change both\"). The conversation is the system of record; the app derives its view from turns plus blocks on load and from one SSE connection while live."
summary: "An app and an agent share a protocol: fenced blocks parsed out of replies, specified in one file and pinned in the agent's prompt in another (\"change one, change both\"). The conversation is the system of record; the app derives its view from turns plus blocks on load and from one SSE connection while live."
builds_on: ["F5"]
---

## Outcome

A static page that signs in with Fountain, starts or picks a
teammate, asks for one block, and renders it.

## Steps

1. Server side: `API_CORS_ORIGINS` for the page origin; `OAUTH_CLIENTS`
   with the redirect URI. Sign in with Fountain is OAuth code + PKCE and
   the token is an API key.
2. Copy the client patterns from dns-desk or Mend (`src/lib/oauth.ts`,
   `sse.ts`, `protocol.ts`).
3. Define one block (say ```` ```hello-state ````) in `protocol.ts` and in
   the agent's system prompt in `spec.ts`.
4. Parse it from the transcript on load and from the stream while live.
5. Run the app against the mock server first, then against a real
   instance.

## Done when

Reloading the page rebuilds the same view from the
conversation alone; nothing is stored server-side.

## Solo

`bun run dev` plus a self-hosted Fountain.

## Live

The hello page on screen: send a message, watch the block
render, reload, same view. The desk and Mend are F8's job.

## Depth

dns-desk README (the desk protocol); Mend README (the mend
protocol).
