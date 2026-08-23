---
title: "The IAM repo"
kicker: "Course 2 · after Fountain"
weight: 2
summary: "Build splashdown/access from nothing as plain CloudFormation JSON, then put the agent on it as the desk and the watcher. Org IAM is the worked example because it exercises the agent side and most of the properties with no toolchain at all."
video:
  provider: todo
  title: "course intro"
  length: ""
---

## Context

- [splashdown](../../docs/demo-org/) is the fictional water-park operator whose AWS this is. The pattern is one resource type per file, the PR as the write path and blame as the audit trail. The [house rules](../../docs/principles/) and the [decisions ledger](../../docs/decisions/) are the why.
- There is no toolchain. The repo is CloudFormation JSON with one resource per file. The applier is CloudFormation. Lint and proofs are Access Analyzer (decision 31). The agent app is [the AWS desk](../../docs/aws-desk.md). chant and Terraform appear in the design docs only.
- Each lesson names the properties it demonstrates and the [prescription](../../docs/prescriptions/) it closes. Self-paced runs on Floci. Live runs on real sandbox accounts with the [live session guide](../../docs/demo/).

## Intro

{{< todo "course intro, under 250 words" >}}
