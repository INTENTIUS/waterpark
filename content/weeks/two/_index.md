---
title: "Week two: the access desk"
kicker: "Week two"
weight: 2
summary: "Build splashdown/access from nothing with your co-hire, then put the co-hire on the desk and on night rounds. Org IAM as the job; the propose loop as the way it's done."
---

**The two-minute talk.** You're on the access desk. [splashdown](../../docs/demo-org/) runs a dozen parks and sells tickets online, so it carries SOC 2 and PCI, and every team's AWS access goes through one repo: `splashdown/access`. One resource type per file, folder structure as the index, anyone PRs their way to the access they need. It works because finding a resource is a path lookup, the PR diff is the blast radius, and git blame is the audit trail. The worst version of this was a write GUI. The [ten house rules](../../docs/principles/) are that lesson made firm; the [decisions ledger](../../docs/decisions/) is the why, and it's text on purpose: if the reason the fence is this ARN isn't written down, a new hire (either kind) has no way in.

Fifteen shifts build the repo from nothing: keys on hooks, who works here, the whistle, the practice pool, the fence, one gate in, the ropes, other teams' rides, wristbands that expire, breaking the glass, last day of the season. Then the co-hire takes the desk (a request in words becomes a one-file PR; the merge is the approval) and the night rounds (findings become capped burndown PRs). Each shift names the [prescription](../../docs/prescriptions/) it closes.

Self-paced is the practice pool: Floci, no account, and each shift says what the pool can't show. With the [shift lead](../../docs/demo/) it's real sandbox accounts from checkpoints.
