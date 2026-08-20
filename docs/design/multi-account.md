# Design: multi-account AWS

Gates A6. Multi-account via Organizations is the default shape;
single-account is the degenerate case.

## What has to be modeled

- **The org layer**: SCPs, RCPs, declarative policies, OUs. Applied from
  the management account (or delegated admin). Org-scoped.
- **Identity Center**: one instance per org. Permission sets are org
  resources; access is a three-way assignment (principal × permission
  set × account).
- **Per-account resources**: boundaries, workload roles, SGs — the same
  definition stamped into many accounts.

## The adopted hybrid

The org layer is one gated component on the management-account
credential tier, applied rarely. Account stamps are one component
definition fanned out over a typed account registry
(`src/baseline/accounts.ts` — itself reference-existing for Control
Tower / org-formation shops). Identity Center assignments are generated
from principals × registry. Account vending is out of scope
(decision 11): water park references accounts, it does not create them.

Rejected shapes: accounts as environments (accounts aren't lifecycle
stages) and hand-written per-account components (doesn't scale to
dozens).

## To decide (A6's first spike)

1. Fan-out mechanics: does chant's component model fan a definition over
   a list today, or is a seam needed? May produce a chant issue.
2. Credential mechanics for the org tier (delegated-admin account,
   separate OIDC role, separate gate) — threat-model tier 3.
3. What Floci can emulate: Organizations/Identity Center emulation
   likely doesn't exist. If absent, the local path covers account stamps
   only and the org layer validates by synth + proof checks. May produce
   a Floci issue.
4. Where region enters the naming scheme (org resources are global-ish,
   network stamps regional).
