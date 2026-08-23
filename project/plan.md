water park is an educational site: short lessons that teach how to run an
agent against real infrastructure safely, on [Fountain](https://github.com/BinaryBourbon/fountain),
using the [Accessible Ops](https://accessibleops.net) properties as the
themes. The basis is one loop, abstracted from the Fountain apps Mend,
Rounds and dns-desk ([the propose loop](../content/propose-loop.md)), applied to a use case. Every
lesson can be run alone or conducted live with a group (decision 26).
The lessons are in two parts: **foundations**, which teach Fountain and
the propose loop, and **the scenario**, org IAM at splashdown, which applies them
to a problem an ops crowd recognizes. IAM is one example of the loop,
and it does not need to hit every property.

## The propose loop, in one paragraph

A target the agent does not control; a deterministic read (an audit with
findings by fix-confidence, or a request with the current state); an
operator that can read and nothing more; a plan rendered as a diff; a
verify before propose; a propose step held by something that is not the
operator (the human's browser, a server with policy, a PR); rules
enforced where the write happens; the conversation or the code host as
record; refusals as outcomes. Interactive or ambient, audit- or
request-driven: four forms, three existing apps. On IAM the concierge is
in the desk's form, the watcher is Rounds, and Mend runs on the access repo
as-is. [the propose loop](../content/propose-loop.md) has the tables.

## How a lesson is built

One theme, one outcome, under thirty minutes alone, under twenty with a
facilitator. Each lesson file carries the same sections:

- **Theme** — the Accessible Ops property (or Fountain concept) it teaches,
  in one sentence.
- **Outcome** — what exists at the end that did not at the start.
- **Builds on** — the lessons it assumes, by number.
- **Steps** — the walkthrough. Runnable by hand, with your own agent, or by
  a Fountain teammate; the steps do not care which author did them (that
  is the thesis, not a convenience).
- **Done when** — the check. For IAM lessons this is the conformance check
  from [prescriptions.md](../content/docs/prescriptions.md); for foundations it is an API
  call or a page state you can see.
- **Solo** — how it runs free and alone (Floci, your own machine, no
  accounts beyond Fountain).
- **Live** — how a facilitator runs it with a room (real AWS, real zones,
  a checkpoint to restart from, the honesty lines to say out loud).
- **Depth** — the design docs and decisions behind it.

On the site the lessons live in two **courses** ([courses/](../content/courses/):
`fountain/` is F1–F11, `iam/` is I1–I15); F0 and I0 are the course intros,
IA is [the appendix](../content/docs/appendix.md). The courses are about the Accessible Ops
properties (decision 26); course 2 is plain CloudFormation JSON with CloudFormation as the applier
(decision 31), which the tables below, written for chant, do not reflect
in their source columns; [the AWS desk](../content/docs/aws-desk.md) is the agent app. Each lesson page's front matter is its card: goal,
done when, restart from, properties, prescriptions closed. The F/I ids
below are the lesson ids.
The stubs there are the spec for each lesson; bodies are written against
the upstream versions pinned in [upstream.md](upstream.md).

## Part I — foundations: Fountain

| # | Lesson | Theme | Done when |
|---|---|---|---|
| F0 | The newest hire | An agent is a new engineer on day one: it reads what is written, uses the paths you give it, touches what its credentials allow (Accessible Ops, about) | You can say which of the fourteen properties the next scenario will lean on |
| F1 | Four primitives | Environment, Vault, Agent, Conversation; nothing else exists | `fountain apply -f` a three-file manifest; a conversation answers |
| F2 | An agent gets a computer | A conversation is a sandbox: provisioning, suspend at idle, destroy at the ceiling, memory on disk | You watch a sandbox suspend and wake with its memory intact |
| F3 | What the sandbox can reach | `networking_type: limited` is a default-deny allowlist; env vars merge environment then vault, vault wins | An agent with an empty allowlist cannot `curl` anything; one with a vault sees the override |
| F4 | Named credentials, one per blast radius | Accessible Ops V and VI: a vault binds to one conversation; a shared environment holds no secret an agent reading untrusted input should hold (Mend's credential table) | Two agents, two vaults, neither can read the other's token |
| F5 | The team | A teammate is a conversation on `fountain:team`; one thread each; the roster and the stream | A teammate answers on `/team`; `/api/team/stream` shows the turn |
| F6 | Schedules | A cron that runs a teammate with a prompt; `run now`; the schedule event | A teammate runs on a schedule and its conversation shows the run |
| F7 | Talking to an agent from an app | Protocol blocks parsed out of replies; the conversation as system of record; Sign in with Fountain; `API_CORS_ORIGINS` and `OAUTH_CLIENTS` (dns-desk, Mend) | A static page signs in, starts a teammate, renders one fenced block it asked for |
| F8 | The propose loop, interactive: Mend and the desk | The parts of the loop with a human as the propose step; audit-driven (Mend) and request-driven (dns-desk); Accessible Ops IV and VIII | The parts table filled for both, and the one part that differs |
| F9 | The propose loop, ambient: Rounds | Same loop, nobody watching: schedule, reconcile against own past work, cap, server as propose, declines stick; which rules live in the server | The rules table with an enforcement column for your own ambient operator |
| F10 | Your own machine | The self-hosted runner: trusted mode, no isolation, no egress policy, state that stays (ADR 0022) | A runner serves a sandbox; you can say what F3 no longer guarantees on it |
| F11 | What Fountain will not do for you | No approval gate in the loop (ADR 0016 is proposed, unbuilt); the gate lives where the write lands; the audit trail is retrospective | You can point at the gate in each scenario and say why it is not in Fountain |

## Part II — the scenario: IAM at splashdown

Builds [splashdown/access](../content/docs/demo-org.md) from nothing to a conforming
access repo with a concierge and a watcher. chant is the toolchain
(decision 23: backends are end states; the course teaches on chant).
Solo mode deploys to Floci; live mode deploys to real sandbox accounts
(decision 27).

| # | Lesson | Theme (Accessible Ops) | Closes | Builds on | Source |
|---|---|---|---|---|---|
| I0 | Why a repo, and the rules of the house | III documentation is law; IV one path to prod | — | F0 | [positioning](archive/positioning.md), [landscape](archive/landscape.md), [principles](../content/docs/principles.md), [decisions](../content/docs/decisions.md) |
| I1 | One type per file, the path is the index | I honor the lower layer | P1, P2 | F1 | A1, A2 |
| I2 | Personas and principals | V named secrets, least privilege | P2, P3 | I1 | A4, A5, [design/personas](../content/docs/design/personas.md) |
| I3 | The red squiggle | II the same check, left of the commit; Mend as-is on the access repo | P4 | I2, F8 | A3 |
| I4 | Deploy with no account | XI the live system is the truth (no state file; read back from live) | P6 (part) | I3, F3 | A13 |
| I5 | The boundary | VI bounded blast radius | P7 | I4 | A6, A7, decision 12, [design/multi-account](../content/docs/design/multi-account.md) |
| I6 | One path to prod | IV one path to prod; IX attributable; XIV verify the artifact | P5, P6, P7 | I5 | A20, A3b, A12, A17, [threat-model](../content/docs/threat-model.md) |
| I7 | Drift | XI the live system is the truth; XIII manage only what you declare; Rounds' rules | P11 | I6, F9 | A8, decision 28 |
| I8 | Delegation and the double refusal | VI bounded blast radius | P8, P10 | I5 | C2, C3, C6, [design/delegation](../content/docs/design/delegation.md), [design/guardrail-rollout](../content/docs/design/guardrail-rollout.md) |
| I9 | Federation trust, short-lived everything | X secret rotation is cheap; V | P12 | I6 | A17, A18, [design/workload-identity](../content/docs/design/workload-identity.md) |
| I10 | Break-glass | VII reversible before risky; VIII escalate the judgment | P9 | I6 | A9, [design/break-glass](../content/docs/design/break-glass.md) |
| I11 | Offboard and the access review | IX attributable; XIII | — | I7 | A10, A11 |
| I12 | The concierge | V, VIII, IX — the desk's form on IAM: estate on screen, request in words, plan as the access delta, propose is a PR | P13 | F4, F7, F8, I6 | D0, D1, [design/agentic](../content/docs/design/agentic.md), [propose loop](../content/propose-loop.md) |
| I13 | The watcher | XIII — Rounds' form on IAM: Rounds as-is for the lint tier, the same form over the IAM projections | — | F6, F9, I7, I12 | D3, [propose loop](../content/propose-loop.md) |
| I14 | Approve the change, not the diff | VIII; XIV | P3 | I6 | [pr-automation](archive/pr-automation.md), decisions 23, 24; gated on chant items 1, 2, 9 |
| I15 | Walk away | I honor the lower layer; XII adopt in place | — | I6 | A21, A14 |
| IA | Appendix: the org layer; the Terraform backend; cross-cloud; the threat model in full | — | — | — | A19, E, B, [threat-model](../content/docs/threat-model.md) |

I14 is last among the numbered lessons because it waits on chant work
that has not landed; I15 can run on a thin estate and should be written
early, since it is the test of decision 2.

## Coverage

The scenario touches every Accessible Ops property except III in depth
(the repo's decisions ledger is the worked example) and XII beyond
reference-existing. Mend, Rounds and dns-desk appear throughout as the
loop's worked references, in F8 and F9 and wherever an IAM lesson
instantiates a part of the loop; they are not separate tracks.

## Modes

**Solo, free.** Your own machine, your own agent (or a Fountain instance
you run; `docker compose up`), Floci for AWS, a GitHub repo you own. No
cloud account. Each lesson's *Solo* section names what Floci cannot show
and where the solo path stops short of the live one.

**Live, with a group.** A facilitator drives from checkpoints; the room
follows along in solo mode or watches. Real AWS sandbox accounts for the
scenario (the proofs, the IAM-side refusals, Organizations and Identity
Center all real) and a real repo for the F8 and F9 exercises. The
facilitator guide is [demo.md](../content/docs/demo.md): session formats, playlists,
checkpoints, honesty lines.

## The pattern, in one paragraph

The best centralized security config observed in the wild: one resource
type per file, folder structure as the index, anyone PRs their way to the
access they need. It worked because finding a resource was a path lookup,
the PR diff was the blast radius, and git blame was the audit trail. The
worst version was a write GUI. The IAM scenario is those lessons made
checkable ([prescriptions.md](../content/docs/prescriptions.md)); the foundations are what
makes an agent safe to hand them to.

## What is next: the phases

Measured 2026-08-22: 26 lesson pages, 182 TODO chips, every card empty; the
reference repo and the AWS desk do not exist; five Fountain lessons carry no
property tag (F2, F5, F6, F7, F10); II, III, VII, X, XII each have one
lesson. Definition of done for a lesson: card filled; Do steps run on a
fresh machine (Floci or a Fountain instance) by someone other than the
author; Self-paced says what the solo path cannot show; Live has the
timing and the line; properties tagged; zero TODO chips.

0. **Verify the ground.** Floci: changesets, `detect-stack-drift`, resource
   import, and `iam:PermissionsBoundary` on `CreateRole` under enforcement
   (I4, I7, I8, I14, I15 solo paths hinge on these). Pin Fountain's
   canonical location and version. Record one Access Analyzer run. Decide
   media hosting (static files vs. YouTube). Output: [upstream](upstream.md)
   updated; each lesson's Self-paced bullet marked runs / recorded / live-only.
1. **The reference repo.** Build `splashdown/access` for real as plain
   CloudFormation JSON: layout, `assemble`, the JSON Schemas, `proofs`,
   `render-delta`, generated CODEOWNERS, the apply workflow with the digest
   check, the Floci local path; cut a checkpoint tag per IAM lesson. Without
   it the IAM lessons are fiction. Its own repo; the lessons clone it.
2. **Fountain course, the runtime half (F1–F6, F10, F11).** Depends only on
   a Fountain instance. Write the cards and steps, verify live, tag or
   explicitly un-tag properties on F2/F5/F6/F7/F10.
3. **The AWS desk v0, direct mode against Floci.** The page (Stacks,
   Activity), `spec.ts` / `protocol.ts`, `aws-state` / `aws-plan` /
   `aws-result`. Then F7–F9 (the protocol, the loop interactive, the watch).
4. **IAM course bodies.** I1–I11 from the reference repo checkpoints; then
   the desk v1 (repo mode, the watch, the digest job) and I12–I15.
5. **The live layer.** Rewrite the [live session guide](../content/docs/demo.md) as
   playlists over lessons (20 / 60 / half-day); checkpoint drills; recorded
   runs; the solo path walked end to end on a clean machine.
6. **Media.** Script the Watch sections; record the two course intros and
   the five marquee lessons (egress denial, guardrail in the editor, the
   double refusal, drift, the desk request); fill the `video:` blocks.
7. **Polish and back office.** The tables in this doc and
   [prescriptions](../content/docs/prescriptions.md) restated for the CloudFormation path;
   [issues](archive/issues.md) mapped to it; the home video; an Education link on
   accessibleops.net pointing here; the appendix written or retired.

Order is by dependency: 0 gates 1, 3, 4; 1 gates 4; 3 gates F7–F9 and
I12–I13. Phase 2 can start today.

## Terms

- **lesson** — one theme, one outcome, one check; runs solo or live.
- **scenario** — the track of lessons that applies the loop to one ops
  problem; IAM at splashdown is the one the course carries.
- **checkpoint** — the tagged state a lesson starts from; a live session
  restarts from it, never from scratch.
- **principal / persona / grant / estate** — as the prescriptions use
  them: an identity managed as one leaf file; the typed archetype it
  instantiates; one typed access statement (optionally expiring); and
  everything live the repo owns or watches.
- **manifest** — the rendered change set a reviewer approves, bound by
  digest (decision 24).
- **kit** — the IAM access-repo product the kit-era docs designed; now the
  IAM scenario's backlog ([issues.md](archive/issues.md)).
