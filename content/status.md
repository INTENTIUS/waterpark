---
title: "Status"
summary: "What is checked by machinery on every push, and what is only written down."
---

This page says what is checked by machinery on every push and what is only
written down. It wins any disagreement with the rest of the site.

## Checked on every push

[`.github/workflows/hugo.yml`](https://github.com/INTENTIUS/waterpark/blob/main/.github/workflows/hugo.yml)
runs these on every push to `main`.

| Check | Job |
|---|---|
| The Hugo build succeeds | `build` |
| The Hugo build fails on any warning | `build` |
| Every internal link in the rendered site resolves | `build` |
| Every relative link in the markdown sources resolves | `build` |
| The site deploys to GitHub Pages | `deploy` |
| The site container image builds and pushes to `ghcr.io/intentius/waterpark` | `image` |

The runner image compose pulls, `ghcr.io/intentius/waterpark-runner`, is
not built by this workflow.

## Verified by hand, dated

| Date | What |
|---|---|
| 2026-08-23 | `just up`, then `just register`, then `just runner`. The runner came up connected and listed online. |
| 2026-08-23, 2026-08-24 | The start skill walked end to end, an agent playing the student. |

## Written, not yet verified

- All 26 lesson bodies (11 Fountain, 15 IAM) are skeletons with TODO
  markers, except Fountain lesson 1. `just todos` counts 181 today.
- The reference access repo does not exist yet. The IAM lessons describe
  a repo nobody has cloned.
- The AWS desk is a design doc, not code.
- Whether Floci supports enough of IAM for `terraform plan` and
  `-detailed-exitcode` to behave, and whether it honors the
  `iam:PermissionsBoundary` condition on `CreateRole`, is unverified.

The phases that close these gaps are in
[project/plan.md](https://github.com/INTENTIUS/waterpark/blob/main/project/plan.md).
