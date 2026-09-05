Taken 2026-08-22 against the then-current structure (two courses, 26
lesson skeletons, the AWS desk design). It predates the 2026-08-25
reframe, which removed the fictional company and moved the IAM course to
Terraform (decisions 31, 32), so read its property table as still valid
and its toolchain references as stale.
Two questions: does the material demonstrate the fourteen properties, and
what does a learner actually meet. Times are estimates for a learner,
self-paced and live, with build effort per phase at the end.

## Coverage against Accessible Ops

| Property | Lessons | Strength | Gap / fix |
|---|---|---|---|
| I Honor the lower layer | I1, I15 | strong: the repo is the platform's own format | tag I4 (read a role back; the file predicted it) |
| II The same check, left of the commit | I3 | single but central | tag I6 (the PR job runs the identical checks); F-side has no lesson where editor check = agent check except I3 step 4 |
| III Documentation is law | F1 | weak: one tag, on the manifest | no lesson shows the *why* living in the repo (decisions ledger, `Description` on the boundary, rationale next to a grant). Add a short IAM lesson or a step in I5; tag I2 once `expires` and rationale are fields |
| IV One path to prod | F8, I6 | strong | — |
| V Named secrets, least privilege | F4, I2, I9, I12 | strong | — |
| VI Bounded blast radius | F3, F4, I5, I8 | strong | tag F10 as the counterexample (a runner has no bound) |
| VII Reversible before risky | I10 | single | tag I14 (a plan that replaces rather than updates is the risky case that waits). I4 no longer qualifies: Terraform has no automatic rollback |
| VIII Escalate the judgment | F8, F11, I10, I12, I14 | strong | — |
| IX Attributable | I6, I11, I12 | medium | tag F5 (one thread per agent) and F7 (the conversation is the record); CloudTrail `sts:SourceIdentity` appears in the desk doc but in no lesson; add to I12 |
| X Secret rotation is cheap | I9 | single | tag F4 (revoke by removing the vault) |
| XI The live system is the truth | I4, I7 | medium, and now contested: Terraform keeps a state file | tag F8 (re-read before apply is this property on the agent side); decision 32 names the cost and I4 teaches it |
| XII Adopt in place | I15 | single, literal | fine |
| XIII Manage only what you declare | F9, I7, I11, I13 | strong | — |
| XIV Verify the artifact | I6, I14 | medium: digest yes, signature/provenance no | nothing signs anything. Either a lesson on provenance for the assembled template (OIDC-attested build, attestation checked before `deploy`) or state the gap on I14 |

Untagged lessons: F2 (lifecycle), F5, F6, F7, F10. F5/F7/F10 take tags
from the table; F2 and F6 are mechanics and can stay untagged if the
courses index stops saying "every lesson names the properties it
demonstrates" (it does; change the sentence or tag them).

Net: the IAM course covers the spec well; the Fountain course covers V, VI,
VIII, XIII and leans on the IAM course for the rest, which is right for a
runtime. The real holes are III (the why as text) and XIV (provenance),
which are exactly the two properties a JSON-in-a-repo approach makes easy
to skip.

## Experience

Walked as a first-time visitor on the live site.

**Home.** Three good sentences and a video placeholder that takes a
screen's height. No "start here": the two course cards are equal weight
and nothing says take Fountain first. No setup page: what you need
(Fountain instance, inference key, a repo, Floci or an account) is buried
in the Fountain course context. *Fix:* a Start here card above the
courses (setup, 10 minutes), smaller placeholder, course 1 marked first.

**Courses index.** Redundant with home; one sentence. *Fix:* either a
real page (the two courses, the setup, the playlists) or drop the nav
item and link the course pages directly.

**Course page.** Intro TODO, then a flat list of lessons with id, title,
summary, property tags. Missing: time per lesson, whether it needs an
account, and a total. *Fix:* show `activity.time` and a needs-account
marker on each row; a total at the top.

**Lesson page.** The card works: four labelled rows, property links out
to the spec. Problems: "Restart from" is unexplained the first time;
the video placeholder renders even when there will never be a video;
"Back office" as a heading means nothing to a newcomer; the Do steps are
followed by Self-paced and Live, so the learner reads the mode notes
after doing the steps. *Fix:* one-line legend under the card on first
visit (or a tooltip), hide the video block unless `provider` is set,
rename Back office to "Further reading", and move the mode note (one
line: "self-paced on Floci / live on a real account") into the card.

**Navigation.** "The propose loop" is in the nav before the learner has
any idea what it is; the back office is a large, kit-era doc set with
its own vocabulary (water park meaning the kit, F/I ids, chant). *Fix:*
move the propose loop under the Fountain course (it is lesson 8's
depth), label the back office as "design docs (the reasoning, not the
course)", and keep it out of the top nav.

**Solo vs live.** The distinction is explained nowhere up front; each
lesson has both sections. *Fix:* the Start here page says it once.

**Mobile and accessibility.** Fine: relative units, card collapses to one
column, iframes titled, links underlined on hover only (slightly weak
affordance in body text).

**Back office for contributors.** The page model is good; the plan's
tables still describe chant; prescriptions' checks are LSP/chant
specific. A contributor writing lesson I3 from the back office gets the
wrong toolchain. *Fix:* phase 7 in [plan](plan.md).

## Time per section, learner

Self-paced assumes Floci or a self-hosted Fountain and no prior setup
beyond the Start here page (30–60 minutes once). Live assumes a
facilitator at a checkpoint and the room watching or following.

| Lesson | Self-paced | Live |
|---|---|---|
| F1 Four primitives | 20 | 10 |
| F2 The sandbox lifecycle | 15 (plus the idle wait) | 5 (timeout pre-lowered) |
| F3 The egress allowlist | 15 | 5 |
| F4 Credentials and vaults | 20 | 5 |
| F5 The team | 10 | 5 |
| F6 Schedules | 10 | 5 |
| F7 Driving an agent from an app | 45 | 10 |
| F8 The propose loop, interactive | 45 | 15 |
| F9 The propose loop, ambient | 30 | 10 |
| F10 The self-hosted runner | 30 | 5 |
| F11 No approval gate in Fountain | 10 | 5 |
| **Fountain course** | **~4 h 10** | **~1 h 20** |
| I1 One resource type per file | 30 | 10 |
| I2 Personas and principals | 25 | 10 |
| I3 Guardrails in the editor | 30 | 10 |
| I4 Deploy to Floci | 20 | 10 |
| I5 The permission boundary | 30 | 10 |
| I6 One path to prod | 60 | 15 |
| I7 Drift | 25 | 10 |
| I8 Delegation and the double refusal | 30 | 10 |
| I9 Federation trust | 30 | 10 |
| I10 Break-glass | 30 | 10 |
| I11 Offboard and the access review | 25 | 10 |
| I12 The concierge | 45 | 15 |
| I13 The watcher | 30 | 10 |
| I14 Approve the change, not the diff | 20 | 10 |
| I15 Adopt in place | 20 | 10 |
| **IAM course** | **~7 h 30** | **~2 h 40** |

About twelve hours self-paced end to end, which is a two-weekend course;
four hours live, which is the half-day format in the
[live session guide](../content/docs/demo.md). The 20- and 60-minute live formats pick
from F3, F8, I3, I6, I7, I8, I12.

## Effort per phase, builder

| Phase | Effort |
|---|---|
| 0 Verify the ground | 1–2 days |
| 1 Reference access repo | 2–3 weeks |
| 2 Fountain course, runtime half | 3–5 days |
| 3 AWS desk v0 + F7–F9 | 2–3 weeks |
| 4 IAM bodies + desk v1 | 2–3 weeks |
| 5 Live layer | 1 week |
| 6 Media | 1–2 weeks |
| 7 Polish and back office | 1 week |

Roughly a quarter of one person's time, with phases 1 and 3 the long
poles and the only ones that need real code.
