# baseline

One permission boundary for the whole estate, plus the constants later
lessons read from here rather than from a page.

## The boundary

A boundary caps what an identity-based policy can grant, because effective
permissions are the intersection of the two. So this policy is the ceiling
every workload role in the estate sits under, and a role cannot be given more
than it says whatever its own policy claims.

It denies all IAM write, Organizations, Identity Center, the guardrail-path
resources by name and boundary detachment, and it allows the service surface
an app team plausibly needs (decision 36). Splitting it per OU waits until an
OU needs it.

The why travels with the artifact. The policy `description` says what the
boundary is for, and each `Deny` carries a comment beside it saying what it
stops. That is property III standing where it is enforced rather than in a
document somewhere else.

`sandbox = true` emits no policy at all and hands back a null ARN, because
the Sandbox OU carries no boundary and sandboxes exist to be broken
(decision 36).

The cost, named out loud. The boundary is the most-revised object in the
baseline, and tightening it can break an existing role at apply time where
lint will not catch it, so a change to it lands under the warn discipline in
[guardrail-rollout](../../content/docs/design/guardrail-rollout.md).

## The constants

`break_glass_max_ttl_hours` is 2 (decision 37), `watcher_max_open_prs` is
5 (decision 40) and `static_secret_max_age_days` is 90 (decision 39).
Lessons 10, 13 and 9 read them from here, so a student changes one number in
one place and watches the checks move with it. The break-glass TTL is
restated as the rule pack's literal and the persona module's default,
because neither can read this file, and `access/scripts/check` fails when
the three differ.

`forbidden_actions` is what the boundary denies, exported as a list so the
lesson 6 proof checks consume it rather than restating it.
