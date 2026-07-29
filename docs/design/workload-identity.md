# Design: workload identity and federation trust (SPIFFE seam)

Surveyed 2026-07-28 (repo pulses via the GitHub API). Not settled; informs
personas item 4 and the threat-model credential tiers.

## The split

water park manages authorization objects — roles, policies, permission
sets. SPIFFE/SPIRE manages authentication — how a workload proves it is
`payments-api` without holding a static key. Complementary, with exactly
one seam: **federation trust config**. A SPIFFE-identified workload
reaches AWS via JWT-SVID through an OIDC provider + role trust policy, or
X.509-SVID through IAM Roles Anywhere; GCP has workload identity
federation pools; Azure has federated credentials. Every one of those
trust anchors is a declarable cloud resource — and among the most
security-critical config in an org, since a loose trust condition is a
standing backdoor. They belong in the estate: lint-checked (no wildcard
SPIFFE paths, no unpinned issuers), drift-watched like everything else.

## One mechanism class, three issuers

CI OIDC (GitHub/GitLab), Kubernetes service-account tokens (IRSA, GKE
WIF), and SPIRE SVIDs are the same shape: federated short-lived
credentials whose trust config is code. A future `src/trust/` layer
covers all three with one typed form — issuer, subject condition, target
role/pool. The threat model's own CI credentials (tiers 1–2) are an
instance of this layer, not a special case.

## The open-question-9 upside

For workloads, SPIFFE offers the universal principal name cross-cloud
personas otherwise lack: `spiffe://flume.io/payments/api` is one identity
that AWS, GCP, and Azure federation configs all reference. A workload
principal's leaf file can carry an optional SPIFFE ID; each cloud leg
compiles to that cloud's federation trust for the same ID. The workload
half of OrgPrincipal goes cross-cloud without inventing an equivalence —
the clouds already trust external identities; water park declares the
agreements. The human half (permission sets etc.) remains the hard part
of question 9.

## Boundary: never operate the issuer

Running SPIRE well (server HA, upstream CA, attestation policy) is its
own product — that's why SPIRL/Defakto, Teleport Workload Identity,
Tetrate, and Aembit exist. water park is BYO-issuer: k8s SA tokens and CI
OIDC cover most orgs with zero new infrastructure; SPIRE or a commercial
SPIFFE vendor covers heterogeneous/off-cloud fleets; water park treats
them identically because the declared trust anchor is the same shape.

Ecosystem health (checked 2026-07-28): spiffe/spire and spiffe/spiffe
active (2.5k/1.8k stars), hardened helm chart maintained, IETF WIMSE
formalizing federation, Istio identity is SPIFFE underneath. Scope line:
**Athenz** bundles authn *and* RBAC/policy — the one adjacent tool that
overlaps water park's authorization territory rather than complementing
it; a docs sentence, not an integration.

## To decide

1. `src/trust/` typed form — one shape across CI OIDC / k8s / SPIFFE
   issuers, per-cloud serialization (AWS OIDC provider + trust policy,
   Roles Anywhere profile, GCP WIF pool, Azure federated credential).
2. Lint rules: subject-condition strictness (no wildcard SPIFFE path or
   `sub` claim, pinned issuer/audience), and which are warn vs error.
3. Whether the SPIFFE ID lives on the principal (leaf file field) or in
   the trust layer referencing the principal. Lean: on the principal —
   it is the principal's cross-cloud name.
4. Roles Anywhere (X.509) vs OIDC path as the documented default for
   AWS. Lean: OIDC (simpler, no CA plumbing); Roles Anywhere noted.
