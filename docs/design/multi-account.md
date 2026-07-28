# Design: multi-account AWS (open question 4)

Gates A6. Not settled. Multi-account via Organizations is the default
shape; single-account is the degenerate case.

## What has to be modeled

- **The org layer**: SCPs, RCPs, declarative policies, OUs. Applied from
  the management account (or a delegated admin). Org-scoped, not
  account-scoped.
- **Identity Center**: one instance per org, in the management or
  delegated-admin account. Permission sets are org resources; access is a
  three-way assignment (principal × permission set × account).
- **Per-account resources**: boundaries, workload roles, SGs — stamped
  into many accounts, same definition.

## The modeling question

Accounts as environments, components, or instances?

- *Environments* (`chant build --env prod-payments`) — fits per-account
  param sets, but accounts aren't lifecycle stages; smells wrong.
- *Components* — one component per account gives dependency ordering
  (org layer → accounts) and per-account apply jobs from generated CI.
  Doesn't scale to dozens of accounts as hand-written component files.
- *Instances* — the loomster multi-instance convention; fits "same stamp,
  many accounts."

Lean: **hybrid.** The org layer is one component (management-account
credential tier). Account stamps are one component definition fanned out
over an account list (a typed account registry in `src/baseline/accounts.ts`
— which may itself be reference-existing for Control Tower / org-formation
shops). Whether chant's component model fans a component over a list today
or needs a seam is a spike — may produce a chant issue.

## To decide

1. The account registry shape, and adopting existing accounts vs vending
   new ones (account vending is org-formation / Control Tower territory —
   coexist, don't compete; water park references accounts, it does not
   create them. Confirm this scope line.)
2. Credential mechanics for the org tier (delegated admin account,
   separate OIDC role, separate gate) — threads into threat-model.md
   tier 3.
3. What Floci can emulate here. Organizations/Identity Center emulation
   likely doesn't exist — check; if absent, the local path covers account
   stamps only and the org layer validates by synth + proof checks, not
   local apply. May produce a Floci issue.
4. Region: Identity Center and org policies are global-ish; SG/network
   stamps are regional. Where region enters the naming scheme.

## Current lean

Org layer = one gated component, management credentials, applied rarely.
Accounts = registry-driven fan-out of a stamp component. Identity Center
assignments generated from principals × registry. Account vending out of
scope.
