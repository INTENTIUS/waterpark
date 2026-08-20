# Design: guardrail rollout (the upgrade story)

"Central team upgrades the baseline, everyone inherits" has a mechanism
problem: adding a lint rule is a behavioral breaking change for every
satellite at once. Without a rollout story the satellite pattern dies of
its first upgrade.

## The pieces (adopted; decision 9)

1. **Versioning policy.** The context package is semver, but severity is
   the real contract: a new rule lands as `warn` in a minor and promotes
   to `error` only in a major. Satellites see warnings for a full cycle
   before anything breaks.
2. **Ratchet baselines.** On promotion, pre-existing violations are
   recorded in a generated, checked-in, shrink-only baseline file (the
   build fails if it grows). New code meets the new bar immediately; old
   code burns down on the team's schedule, visibly in the access-review
   report. Spike: does chant's lint engine have a suppression-baseline
   seam, or is this a chant issue?
3. **Upgrade propagation.** Satellites pin the package; a bot PR
   delivers upgrades and the PR automation plans it like any change — a
   bump PR shows which new warnings appear. Version-inventory reporting
   probably lives in the access-review Op.
4. **Emergency rule.** An `error`-on-minor escape hatch for actively
   exploited patterns, requiring a security-team-owned changelog entry.
   Rare by policy.

## To decide

- Baseline-file mechanics (chant lint seam or kit-local wrapper).
- Whether the org policy layer backstops the worst rules — a lint rule
  says "don't," an SCP says "can't"; promoting a guardrail from lint to
  SCP is the strongest rollout form.

C2's AC gains: a context-package upgrade that adds a rule cannot break a
satellite without a warn cycle first.
