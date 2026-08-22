---
title: "Why a repo, and the rules of the house"
number: "I0"
weight: 1
theme: "Accessible Ops III (documentation is law) and IV (one path to prod). The reason a thing is the way it is exists as text, and every change arrives as a diff in one place where someone can say no."
summary: "Accessible Ops III (documentation is law) and IV (one path to prod). The reason a thing is the way it is exists as text, and every change arrives as a diff in one place where someone can say no."
properties: ["III", "IV"]
builds_on: ["F0"]
---

## Outcome

You know splashdown, the ten invariants, and where the "why"
lives (the decisions ledger), before you type anything.

## Steps

1. [demo-org.md](../../docs/demo-org.md): splashdown, its accounts, teams, the six
   canonical scenarios. Use the names verbatim from here on.
2. [principles.md](../../docs/principles.md): ten invariants, each citing a
   decision.
3. [decisions.md](../../docs/decisions.md): skim the ledger; note the rule that
   reversing one means editing the file in the same PR.
4. The one-paragraph pattern in [plan.md](../../docs/plan.md) and the empty box in
   [positioning.md](../../docs/positioning.md): what this is against (a write GUI,
   a broker in the credential path, a new format).

## Done when

You can say which decision forbids an approve button in
chat, and why the answer to "why is the boundary this ARN" must be text in
the repo.

## Solo

Reading.

## Live

Two minutes: the pattern paragraph and principle 1, out loud.

## Depth

[landscape.md](../../docs/landscape.md).
