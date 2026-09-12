---
title: "The IAM repo"
kicker: "Course 2 · after Fountain"
weight: 2
summary: "Build water park's own access repo from nothing as Terraform, then put the agent on it as the desk and the watcher. Org IAM is the worked example because it exercises the agent side and most of the properties."
---

## Context

- The estate is water park's own AWS ([the estate](../../docs/estate/)). The repo you cloned to take this course is the repo the course puts under management, which is the point. The pattern is one resource per file, the PR as the write path and blame as the audit trail. The [house rules](../../docs/principles/) and the [decisions ledger](../../docs/decisions/) are the why.
- The repo is Terraform with one resource per file, and Terraform is the applier (decision 31). The checks are `terraform validate` and `tflint`, the proofs are Access Analyzer. The agent app is [the AWS desk](../../docs/aws-desk.md). water park is a pattern rather than a tool, so the pairing of Fountain with Terraform is a course choice, and the design docs describe what changes on a typed backend instead.
- Each lesson names the properties it demonstrates and the [prescription](../../docs/prescriptions/) it closes. Self-paced runs on Floci. Live runs on real sandbox accounts with the [live session guide](../../docs/demo/).

## Intro

Fifteen lessons build an access repo from nothing and then hand it to an
agent.

The first six are the shape. One resource per file and the path as the index,
personas and principals so a leaf file is a call and a list of grants, the
guardrails in the editor that CI runs unchanged, a deploy with no account at
all, the boundary every role stands inside, and one path to prod with a job
that refuses a plan whose digest is not the one a reviewer approved.

Then the parts that only matter once something is live. Drift, where the
account moved and the repo did not. Delegation, where a satellite repo owns
its own files and gets refused twice if it reaches further. Federation, so
nothing holds a static key. Break-glass, where access is granted in a hurry
and expires on its own. Offboarding and the access review, which is the
artifact somebody outside the team will accept.

The last four put the agent on it. The concierge takes a request in plain
words and opens a pull request you can read, and refuses one from somebody the
estate has never heard of. The watcher runs with nobody in the room and files
what it finds under rules that hold when its prompt is ignored. Approve the
change and not the diff is the digest that binds an approval to a change
rather than to a run. And walking away is adopting what already exists without
changing it.

The estate is real, the checks run on every push, and the repo you cloned to
take the course is the repo the course manages.
