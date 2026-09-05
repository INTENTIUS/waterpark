---
title: "The estate"
---

The IAM course manages water park's own AWS access. There is no fictional
company. The repo you cloned to take the courses is the repo the courses
put under management, and the names below are the only proper nouns the
course adds to Fountain and water park itself. All of them are canonical.
Use them verbatim.

## Why the course repo is also the estate

water park is a courses repo first. It is also, by lesson 6, a GitOps repo
that owns its own access, and that is the point. A pattern you read about
is an opinion. A pattern the thing you are reading runs on is a
demonstration. Every claim the IAM course makes is checkable against the
repo in front of you.

One honest note about what is real. The site ships from GitHub Pages today
and the sandbox runner image ships from ghcr. The AWS estate below is what
that same infrastructure looks like when it is declared as code and owned
by the repo, and it is what you actually build and deploy. Self-paced you
deploy it to Floci, which runs the AWS APIs in process, so the Terraform is
real, the IAM is real and the account is not. Live you deploy it to a real
sandbox account.

## Accounts

| Account | Purpose |
|---|---|
| `waterpark-mgmt` | management account, org policies, Identity Center |
| `waterpark-security` | audit tooling, Access Analyzer, log archive, the Terraform state bucket |
| `waterpark-prod` | the published site, the runner image, the artifacts bucket |
| `waterpark-dev` | the same shapes with no traffic, where a change lands first |

Solo mode runs one account, because Floci has no Organizations. Every
lesson that needs the multi-account layer says so in its self-paced
section.

## Principals

Humans get Identity Center permission sets. Workloads get IAM roles. There
are no IAM users and no IAM groups (decision 5).

| Principal | Kind | What it is |
|---|---|---|
| `platform` | human | owns the repo and the guardrails, the security reviewers in CODEOWNERS |
| `course-author` | human | writes lessons, reads everything, writes nothing in prod |
| `site-publisher` | workload | builds the site and writes it to the site bucket |
| `runner-builder` | workload | builds the sandbox runner image and pushes it |
| `desk-operator` | workload | the concierge in direct mode, bounded, and nothing in repo mode |

## Resources

| Resource | What it is |
|---|---|
| `waterpark-site` | the bucket the published site is served from |
| `waterpark-artifacts` | build artifacts and the lesson checkpoints |
| `waterpark-runner` | the registry the sandbox runner image is pushed to |

## The satellite

`waterpark-runner` is also a repo of its own, and it is the satellite in
lesson 8. It declares its registry and the `runner-builder` role that
pushes to it, inside a permission boundary the access repo owns. It never
declares a human. This is the pattern working with one satellite; the
access repo works with none.

## Canonical scenarios

These are the source material for the live playlist in
[the live session guide](demo.md).

1. **The PR.** A contributor gives `site-publisher` read access on
   `waterpark-artifacts` by editing one file. Checks pass, the access
   delta renders on the PR, CODEOWNERS approve, merge applies.
2. **The drift.** Someone widens a security group in the console. The
   watch flags it within a cycle and the reconcile PR restores what the
   repo declares.
3. **The bad Friday.** A release breaks the site late on a Friday and the
   on-call needs prod write they do not normally hold. Break-glass grants
   it with a two hour expiry the cloud enforces, revokes it, and leaves
   the whole thing in the audit trail.
4. **The departure.** A course author leaves. Offboard removes every
   reference in one PR and one apply, and the graph shows zero left.
5. **The satellite.** `waterpark-runner` declares its registry and the
   role that pushes to it inside the guardrails. Stripping the boundary is
   refused twice, by the checks at build and by IAM at apply, with nobody
   from platform involved either time.
6. **The request.** A contributor asks the concierge in plain words.
   "site-publisher needs read on waterpark-artifacts." The desk authors the
   one file edit and the requester gets a PR link with the access delta
   rendered, then the applied confirmation with its provenance sha.
   Scenario 1 entered from a sentence. Two variants matter as much. An
   unmapped requester gets a refusal naming the enrollment route and no PR
   (decision 17), and a request that needs the boundary changed gets a
   directed refusal pointing at the platform path.
