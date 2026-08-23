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

- Trust for CI OIDC, Kubernetes service accounts and SPIFFE is the `AssumeRolePolicyDocument` of each role plus `AWS::IAM::OIDCProvider` resources. These carry the strictest checks and drift severity. The repo never operates an issuer.
- Credentials are short-lived everywhere. The few static secrets rotate on a policy window.
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
