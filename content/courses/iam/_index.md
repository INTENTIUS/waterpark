---
title: "The IAM repo"
kicker: "Course 2 · after Fountain"
weight: 2
summary: "Build water park's own access repo from nothing as Terraform, then put the agent on it as the desk and the watcher. Org IAM is the worked example because it exercises the agent side and most of the properties."
video:
  provider: todo
  title: "course intro"
  length: ""
---

## Context

- The estate is water park's own AWS ([the estate](../../docs/estate/)). The repo you cloned to take this course is the repo the course puts under management, which is the point. The pattern is one resource per file, the PR as the write path and blame as the audit trail. The [house rules](../../docs/principles/) and the [decisions ledger](../../docs/decisions/) are the why.
- The repo is Terraform with one resource per file, and Terraform is the applier (decision 31). The checks are `terraform validate` and `tflint`, the proofs are Access Analyzer. The agent app is [the AWS desk](../../docs/aws-desk.md). water park is a pattern rather than a tool, so the pairing of Fountain with Terraform is a course choice, and the design docs describe what changes on a typed backend instead.
- Each lesson names the properties it demonstrates and the [prescription](../../docs/prescriptions/) it closes. Self-paced runs on Floci. Live runs on real sandbox accounts with the [live session guide](../../docs/demo/).

## Intro

{{< todo "course intro, under 250 words" >}}
