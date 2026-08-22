---
title: "Design: workload identity and federation trust (SPIFFE seam)"
---

Surveyed 2026-07-28. Informs personas item 4 and the threat-model
credential tiers.

## The split

water park manages authorization objects; SPIFFE/SPIRE manages
authentication — how a workload proves it is `payments-api` without a
static key. Complementary, with one seam: **federation trust config**.
JWT-SVID through an OIDC provider + role trust policy, X.509-SVID
through IAM Roles Anywhere, GCP WIF pools, Azure federated credentials —
every one a declarable cloud resource, and among the most
security-critical in an org: a loose trust condition is a standing
backdoor. They belong in the estate, lint-checked and drift-watched.

## One mechanism class, three issuers

CI OIDC, Kubernetes service-account tokens, and SPIRE SVIDs are the same
thing: federated short-lived credentials whose trust config is code.
`src/trust/` covers all three with one typed form — issuer, subject
condition, target role/pool. The threat model's own CI credentials are
an instance of this layer, not a special case.

## The sandbox exception: untrusted workloads

The mechanism assumes the workload is trusted code — only then does "the
pod can read the token" imply "the token names the pod." Agent sandboxes
running untrusted code break that premise: assume everything readable
inside is exfiltrated, and a projected SA token is a bearer JWT that
federates from any IP until expiry. Short TTLs shrink the replay window;
they don't close it.

So decision 15: **an untrusted sandbox is never a federation subject.**
It mounts no SA token and holds no cloud credentials. Capabilities
arrive as a conversation-scoped token for a verb API served by trusted
code outside the boundary, which federates normally through this layer.
Residual hardening on the verb service's anchor: source-IP /
VPC-endpoint conditions (a replayed credential fails at STS),
per-conversation `sts:SourceIdentity` for attribution, paging on role
use from an unexpected origin. Sender-constrained tokens (WIMSE) would
close bearer replay properly; cloud STS doesn't support them — a watch
item, not a dependency.

Division of labor: the runtime (Fountain) enforces the boundary —
isolation, token plumbing, egress; water park declares the policy — the
verb service's trust anchor, its role, and the lint on both.

## The cross-cloud upside

For workloads, SPIFFE offers the universal principal name cross-cloud
personas otherwise lack: `spiffe://pepperoni.io/payments/api` is one
identity every cloud's federation config can reference. A workload leaf
file carries an optional SPIFFE ID; each leg compiles to that cloud's
trust for the same ID. The workload half of OrgPrincipal goes
cross-cloud without inventing an equivalence; the human half remains the
hard part of the equivalence unknown.

## Boundary: never operate the issuer

Running SPIRE well is its own product (hence SPIRL/Defakto, Teleport,
Tetrate, Aembit). water park is BYO-issuer: k8s SA tokens and CI OIDC
cover most orgs with zero new infrastructure; SPIRE or a commercial
vendor covers heterogeneous fleets; the declared trust anchor is the
same form either way. Ecosystem is healthy (active repos, hardened helm
chart, IETF WIMSE). Scope line: **Athenz** bundles authn *and* policy —
the one adjacent tool that overlaps rather than complements; a docs
sentence, not an integration.

## To decide

1. The `src/trust/` typed form — one form across the three issuer
   classes, per-cloud serialization.
2. Lint strictness: no wildcard SPIFFE path or `sub` claim, pinned
   issuer/audience; network conditions mandatory for anchors whose
   consumer sits adjacent to an untrusted sandbox.
3. Whether the SPIFFE ID lives on the principal or in the trust layer.
   Lean: on the principal — it is the principal's cross-cloud name.
4. Roles Anywhere vs OIDC as the documented AWS default. Lean: OIDC
   (no CA plumbing); Roles Anywhere noted.
