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
| 2026-09-05 | `just up` on a fresh volume, `just register`, `just runner`. The runner came up online; a real inference credential went in through the web UI. |
| 2026-09-05 | Fountain lesson 1 on the compose stack. `fountain apply -f` created the three objects, the secrets endpoint returned keys with no value field, the conversation replied, and the second apply updated in place. The sandbox had `STAGE=dev`; a prompt naming the shell read it back. Two things did not match the page and are filed as [issue 37](https://github.com/INTENTIUS/waterpark/issues/37): the runtime refuses the manifest's model id and answers on the account default, and the page's prompt does not make the agent read STAGE. |
| 2026-09-05 | Floci as a Terraform target, plan phase 0. Upstream 2.0.1 converged, reported drift and imported, but never returned a role's permissions boundary on read and never populated the `iam:PermissionsBoundary` condition key. A patched build of the `lex00/floci` fork (`ghcr.io/lex00/floci:iam-boundary`) passes all four facts, and the compose stack now pulls it. Both runs are recorded in [project/upstream.md](https://github.com/INTENTIUS/waterpark/blob/main/project/upstream.md). |

## Written, not yet verified

- All 26 lesson bodies (11 Fountain, 15 IAM) are skeletons with TODO
  markers, except Fountain lesson 1. `just todos` counts 181 today.
- The reference access repo does not exist yet. The IAM lessons describe
  a repo nobody has cloned.
- The AWS desk is a design doc, not code.
- Floci as a Terraform target was verified on 2026-09-05 (plan phase 0,
  recorded in
  [project/upstream.md](https://github.com/INTENTIUS/waterpark/blob/main/project/upstream.md)).
  Plan and apply converge, drift reports under `-detailed-exitcode`, and
  `import` blocks work. Upstream 2.0.1 has two gaps, a role's permissions
  boundary is never returned on read and the `iam:PermissionsBoundary`
  condition key is never populated, so the compose stack runs a patched
  fork build, `ghcr.io/lex00/floci:iam-boundary`, on which all four facts
  pass. The self-paced path depends on that image until the fixes are
  upstream.

The phases that close these gaps are in
[project/plan.md](https://github.com/INTENTIUS/waterpark/blob/main/project/plan.md).
