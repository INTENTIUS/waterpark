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

- [splashdown](../../docs/demo-org/), the fictional water-park operator whose AWS this is; the one-paragraph pattern (one type per file, PR as the write path, blame as the audit trail); the [house rules](../../docs/principles/) and the [decisions ledger](../../docs/decisions/).
- No toolchain: the repo is CloudFormation JSON, one resource per file; the applier is CloudFormation; lint and proofs are Access Analyzer (decision 31). The agent app is [the AWS desk](../../docs/aws-desk.md). chant and Terraform appear in the design docs only.
- Each lesson names the properties it demonstrates and the [prescription](../../docs/prescriptions/) it closes; self-paced on Floci, live on real sandbox accounts ([live session guide](../../docs/demo/)).

## Intro

{{< todo "course intro; under 250 words" >}}
