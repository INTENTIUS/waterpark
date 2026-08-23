---
title: "Driving an agent from an app"
id: "F7"
lesson: 7
weight: 7
summary: "An app drives a teammate through fenced blocks and the team stream."
# card. empty renders as TODO
goal: ""
done_when: ""
restart_from: "lesson 5"
properties: ["IX"]
# media. provider is youtube, vimeo, file or todo
video:
  provider: todo
  title: ""
  length: ""
# activity. kind is hands-on, watch-along or discuss
activity:
  kind: hands-on
  time: "45 min"
  needs: []
  solo: true
  live: true
---

## Context

- The app and the agent share fenced blocks parsed out of replies. The blocks are defined in one file and pinned in the prompt in another.
- The conversation is the record. The app rebuilds its view from turns and blocks on load and reads one SSE stream while live.
- Sign in with Fountain uses OAuth code with PKCE and yields an API key. The server needs `API_CORS_ORIGINS` and `OAUTH_CLIENTS`.
- dns-desk and Mend carry the client code to copy.

## Watch

{{< todo "Video script or link. Optional." >}}

## Do

{{< todo "Numbered steps. Imperative. One job." >}}

1. {{< todo >}}
2. {{< todo >}}
3. {{< todo >}}

## Self-paced

{{< todo "What Floci or your own machine can and cannot show." >}}

## Live

{{< todo "What the room sees. Timing. The line to say." >}}

## Further reading

- dns-desk README
- Mend README
