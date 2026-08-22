---
title: "Wristbands expire at close"
id: "I9"
shift: 9
weight: 9
subtitle: "federation trust, short-lived everything"
summary: "federation trust, short-lived everything"
today: "Declare the trust anchors (CI OIDC, k8s service accounts, SPIFFE) in one typed form under `src/trust/`, with the strictest lint and drift severity in the repo. An estate of federated short-lived credentials has almost nothing to rotate; a loose trust condition is a standing backdoor."
done_when: "A workload principal's subject synthesizes its AWS trust; a wildcard subject fails lint; a hand-edited trust policy is flagged within one cycle."
clock_in: "shift 6"
rule: "Secret rotation is cheap (handbook X); named secrets (V)."
properties: ["X", "V"]
closes: ["P12"]
---

## Steps

1. Declare the CI OIDC anchor the plan and apply roles already use; it is an instance of this layer, not a special case.
2. A workload principal declares a subject; its AWS leg synthesizes the trust policy.
3. A wildcard subject fails lint. Hand-edit a trust policy in the console: flagged within one cycle.
4. The sandbox exception: an untrusted co-hire is never a federation subject (decision 15); the verb service outside it is. Rotate the few static secrets (break-glass signing material) on a policy window (A17).

## Self-paced

Floci's IAM and STS cover the synthesis and the read-back; the OIDC provider itself is a real-account thing.

## With the shift lead

Real.

## Back office

[workload identity](../../docs/design/workload-identity.md); decision 13; [issues](../../docs/issues.md) A17, A18.
