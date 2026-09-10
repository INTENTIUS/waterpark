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
| 2026-09-05 | IAM lessons 1 to 5 written against `checkpoint/i0` to `checkpoint/i5` and taken end to end by an agent playing the student from a fresh clone with only the pages, the skills and the tags. Lessons 3, 4 and 5 passed their done-when as written, 1 and 2 failed on a checkpoint compare that could not be silent. Nineteen stumbles filed and fixed, the changed steps re-run clean. |
| 2026-09-05 | IAM lessons 6 to 8 written against `checkpoint/i5` to `checkpoint/i8` and taken end to end by an agent playing the student from a fresh clone. All three done-whens passed as written and every promised compare was silent. Sixteen stumbles filed, fifteen fixed in text, one left as a script finding. The access workflow's PR job and apply job each ran for real on PR 71 and its merge, the apply job matching the approved plan digest and applying. |
| 2026-09-06 | Fountain lesson 3, the egress allowlist, written and taken end to end by an agent playing the student from a fresh clone. The done-when passed as written. The class stack's runner holds no egress policy, so Fountain refuses a `limited` environment rather than running it open, and the lesson teaches that refusal. It needs no inference key, since the refusal comes before the model is called. |
| 2026-09-10 | IAM lesson 10, break-glass, written against `checkpoint/i9` to `checkpoint/i10` and taken end to end by an agent playing the student from a fresh clone. All five done-when clauses passed as written and the checkpoint compare was silent. A grant with a `granted_at` applies as one policy carrying its `DateLessThan` expiry and tags, the script, the rule pack and `plan` each refuse a three-hour grant, the watch reports the expired leftover with the sweep deliberately unrun, and the revoke puts the file and the account back. Floci evaluates no condition on an allow, so the drill where the access works and then ends is live only, recorded in [project/upstream.md](https://github.com/INTENTIUS/waterpark/blob/main/project/upstream.md). Four stumbles filed, one a missing `terraform init` and three wording, all fixed. |
| 2026-09-10 | IAM lesson 9, federation trust, written against `checkpoint/i8` to `checkpoint/i9` and taken end to end by an agent playing the student from a fresh clone. All five done-when clauses passed as written and the checkpoint compare was silent. `site-publisher` federates through the GitHub Actions anchor with the `github-pages` environment as its exact subject, the two trust rules and their fixtures run in the check stack, a hand-edited trust policy and a widened anchor both page, and the rotation check reads the account for static secrets on the drift cron. Floci's `AssumeRoleWithWebIdentity` mints credentials for a forged token, and the lesson runs that call on purpose. Five stumbles filed, four wording and one a missing apply, all fixed. |
| 2026-09-06 | Fountain lesson 2, the sandbox lifecycle, written and taken end to end by an agent playing the student from a fresh clone. All three done-when clauses passed as written and every command ran unmodified. The class stack now sets Fountain's idle bound to two minutes, so the student watched the sandbox park two minutes and fifty-five seconds after its last turn, wake by reattach onto the same sandbox id with a file still on its disk, and lose the directory on terminate while the transcript stayed. Thirteen stumbles filed, all wording, all fixed. Like lesson 3 it needs no inference key. |

## Written, not yet verified

- 13 of the 26 lesson bodies are skeletons with TODO markers. Written
  and student-run: Fountain lessons 1 to 3, and IAM lessons 1 to 10.
  `just todos` counts 97 today.
- The access repo exists under `access/` for what IAM lessons 1 to 8
  need (layout, personas, the check stack, the Floci deploy, the
  boundary, the PR and apply jobs, drift and reconcile, the satellite and
  the double refusal), tagged `checkpoint/i0` to `checkpoint/i8`. The
  proofs are live only, since Access Analyzer is a stub on Floci, and
  everything lessons 9 onward need is not built.
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
