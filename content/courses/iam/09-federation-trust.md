---
title: "Federation trust"
id: "I9"
lesson: 9
weight: 9
summary: "Trust policies are declared resources with the strictest checks."
# skill. a directory in this repo with a SKILL.md that drives the lesson. empty renders nothing
skill: ""
# card. empty renders as TODO
goal: ""
done_when: ""
restart_from: "lesson 6"
properties: ["X", "V"]
closes: ["P12"]
# media. provider is youtube, vimeo, file or todo
video:
  provider: todo
  title: ""
  length: ""
# activity. kind is hands-on, watch-along or discuss
activity:
  kind: hands-on
  time: "30 min"
  needs: []
  solo: true
  live: true
---

## Context

- Trust for CI OIDC, Kubernetes service accounts and SPIFFE is the `assume_role_policy` of each role plus `aws_iam_openid_connect_provider` resources under `access/identity/`, issuer and audience pinned and no wildcard `sub` claim. These carry the strictest checks and the highest drift severity in the repo. The repo never operates an issuer. Roles Anywhere is one paragraph, the option for a fleet with an existing PKI (decision 39).
- Credentials are short-lived everywhere. The rotation check for the few static secrets that remain runs on the same weekday schedule as the watch, so one cron drives both and lesson 13 teaches the schedule once.
- The agent sandbox is never a federation subject (decision 15).

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

- [Workload identity](../../docs/design/workload-identity.md)
- Decision 13
- [Issues](https://github.com/INTENTIUS/waterpark/blob/main/project/archive/issues.md) A17 and A18
