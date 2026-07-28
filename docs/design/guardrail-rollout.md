# Design: guardrail rollout (the upgrade story)

Positioning claims "central team upgrades the baseline, everyone
inherits." The context package is the mechanism, but the claim has a
mechanism problem: **adding a lint rule is a behavioral breaking change
for every satellite at once.** A new rule that fails existing code turns
every satellite's next CI run red simultaneously. Without a rollout story
the satellite pattern dies of its first upgrade.

## The pieces

1. **Versioning policy.** The context package is semver, but severity is
   the real contract: a new rule lands as `warn` in a minor release and is
   promoted to `error` only in a major. Satellites see warnings for a full
   cycle before anything breaks.
2. **Ratchet baselines.** When a rule promotes to error, pre-existing
   violations are recorded in a per-repo baseline file (generated, checked
   in, shrink-only — a lint rule fails the build if the baseline grows).
   New code meets the new bar immediately; old code is burned down on the
   team's schedule and the burn-down is visible in the access-review
   report. Needs a spike: does chant's lint engine support a
   suppression-baseline seam, or is this a chant issue?
3. **Upgrade propagation.** Satellites pin the package; a bot PR
   (renovate/dependabot-class) delivers upgrades, and the PR automation
   plans it like any change — a context-package bump PR shows which new
   warnings appear. The central team can see adoption lag by satellite
   version (*open*: where that inventory lives — probably the
   access-review Op, since satellites are part of the estate).
4. **Emergency rule.** Some rules can't wait a major (an actively
   exploited pattern). An `error`-on-minor escape hatch exists but
   requires a security-team-owned changelog entry stating why. Rare by
   policy.

## To decide

- Baseline-file mechanics (chant lint seam or kit-local wrapper).
- Whether the org policy layer (SCPs) should backstop the worst rules —
  a lint rule says "don't," an SCP says "can't"; promoting a guardrail
  from lint to SCP is the strongest form of rollout and belongs in the
  same doc trail.
- Version-inventory reporting.

## Current lean

warn-minor / error-major, ratchet baselines, bot-PR propagation, SCP
backstop for the handful of rules that warrant it. C2's AC gains: "a
context-package upgrade that adds a rule cannot break a satellite without
a warn cycle first."
