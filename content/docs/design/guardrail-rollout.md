---
title: "Design: guardrail rollout (the upgrade story)"
---

"Central team upgrades the baseline, everyone inherits" has a mechanism
problem: adding a lint rule is a behavioral breaking change for every
satellite at once. Without a rollout story the satellite pattern dies of
its first upgrade.

## The pieces (adopted; decision 9)

1. **Versioning policy.** The shared module is semver, but severity is
   the real contract. A new rule lands as `warn` in a minor and promotes
   to `error` only in a major, so satellites see warnings for a full
   cycle before anything breaks.
2. **Ratchet baselines.** On promotion, pre-existing violations are
   recorded in a generated, checked-in, shrink-only baseline file, and
   the build fails if it grows. New code meets the new bar immediately
   and old code burns down on the team's schedule, visibly in the
   access-review report. Spike: `tflint` has no first-class baseline, so
   this is a wrapper around its JSON output until it does.
3. **Upgrade propagation.** Satellites pin the module version and a bot
   PR delivers upgrades, which the PR automation plans like any other
   change, so a bump PR shows which new warnings appear.
   Version-inventory reporting lives in the access review.
4. **Emergency rule.** An `error`-on-minor escape hatch for actively
   exploited patterns, requiring a security-team-owned changelog entry.
   Rare by policy.

## To decide

- Baseline-file mechanics, which today means a wrapper around `tflint --format=json`.
- Whether the org policy layer backstops the worst rules — a lint rule
  says "don't," an SCP says "can't"; promoting a guardrail from lint to
  SCP is the strongest rollout form.

C2's AC gains: a shared-module upgrade that adds a rule cannot break a
satellite without a warn cycle first.
