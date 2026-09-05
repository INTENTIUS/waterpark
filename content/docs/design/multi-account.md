---
title: "Design: multi-account AWS"
---

Gates A6. Multi-account via Organizations is the default;
single-account is the degenerate case.

## What has to be modeled

- **The org layer**: SCPs, RCPs, declarative policies, OUs. Applied from
  the management account (or delegated admin). Org-scoped.
- **Identity Center**: one instance per org. Permission sets are org
  resources; access is a three-way assignment (principal × permission
  set × account).
- **Per-account resources**: boundaries, workload roles and security
  groups, the same definition stamped into many accounts.

## The adopted hybrid

The org layer is one gated workspace on the management-account
credential tier, applied rarely. Account stamps are one module fanned out
over an account registry in `baseline/`, itself adopted rather than
created for Control Tower and org-formation shops. Identity Center
assignments are generated from principals against that registry. Account
vending is out of scope (decision 11), so water park references accounts
and does not create them.

Rejected alternatives: accounts as environments (accounts aren't lifecycle
stages) and hand-written per-account components (doesn't scale to
dozens).

## To decide (A6's first spike)

1. Fan-out mechanics: `for_each` over the registry with a provider alias
   per account is the obvious form. Confirm it stays readable at a dozen
   accounts.
2. Credential mechanics for the org tier (delegated-admin account,
   separate OIDC role, separate gate) — threat-model tier 3.
3. What Floci can emulate: Organizations and Identity Center emulation
   likely does not exist. If absent, the local path covers account stamps
   only and the org layer validates by plan plus proof checks. May
   produce a Floci issue.
4. Where region enters the naming scheme (org resources are global-ish,
   network stamps regional).
