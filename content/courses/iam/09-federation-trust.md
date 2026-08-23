---
title: "Federation trust"
id: "I9"
lesson: 9
weight: 9
summary: "Trust policies (CI OIDC, k8s service accounts, SPIFFE) as the `AssumeRolePolicyDocument` of each role plus `AWS::IAM::OIDCProvider` resources; strictest checks and drift severity; never operate the issuer."
# card — empty renders as TODO
goal: ""
done_when: ""
restart_from: "lesson 6"
properties: ["X", "V"]
closes: ["P12"]
# media — provider: youtube | vimeo | file | todo
video:
  provider: todo
  title: ""
  length: ""
# activity — kind: hands-on | watch-along | discuss
activity:
  kind: hands-on
  time: "30 min"
  needs: []
  solo: true
  live: true
---

## Context

- Trust policies (CI OIDC, k8s service accounts, SPIFFE) as the `AssumeRolePolicyDocument` of each role plus `AWS::IAM::OIDCProvider` resources; strictest checks and drift severity; never operate the issuer.
- Short-lived everything; the few static secrets rotate on a policy window.
- The agent sandbox is never a federation subject (decision 15).

## Watch

{{< todo "video script or link; optional, drop the section if no video" >}}

## Do

{{< todo "the activity: numbered steps, imperative, one job" >}}

1. {{< todo >}}
2. {{< todo >}}
3. {{< todo >}}

## Self-paced

{{< todo "what Floci / your own machine can and cannot show for this lesson" >}}

## Live

{{< todo "what the room sees; timing; the honesty line" >}}

## Further reading

[workload identity](../../docs/design/workload-identity.md); decision 13; [issues](../../docs/issues.md) A17, A18.
