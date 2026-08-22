---
title: "Federation trust, short-lived everything"
number: "I9"
weight: 10
theme: "Accessible Ops X (secret rotation is cheap) and V. An estate of federated short-lived credentials has almost nothing to rotate; the trust anchors that make that true are the most security-critical resources in it."
summary: "Accessible Ops X (secret rotation is cheap) and V. An estate of federated short-lived credentials has almost nothing to rotate; the trust anchors that make that true are the most security-critical resources in it."
properties: ["X", "V"]
closes: ["P12"]
builds_on: ["I6"]
---

## Outcome

`src/trust/`: one typed form for CI OIDC, k8s service-account
and SPIFFE issuers, serialized to AWS federation trust; strictest lint and
top drift severity; the few static secrets (break-glass signing material)
rotated on a policy window (A17).

## Steps

1. Declare the CI OIDC anchor the plan/apply roles already use; it is an
   instance of this layer, not a special case.
2. A workload principal declares a subject; its AWS leg synthesizes the
   trust policy.
3. A wildcard subject fails lint. Hand-edit a trust policy in the console:
   flagged within one cycle.
4. The sandbox exception: an untrusted agent sandbox is never a federation
   subject (decision 15); the verb service outside it is.

## Done when

Prescription 12.

## Solo

Floci's IAM and STS cover the synthesis and the read-back; the
OIDC provider itself is a real-account thing.

## Live

Real.

## Depth

[design/workload-identity.md](../../docs/design/workload-identity.md);
decision 13; issues A17, A18.
