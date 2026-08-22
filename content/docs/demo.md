---
title: "Live session guide"
---

Every lesson in [the two courses](../courses/) has a *Live* section. This doc is the
rest: how to run a room, which lessons to string together, what to have
ready, and what to say out loud. Live mode is real: real AWS sandbox
accounts for the scenario, a real repo for the F8 and F9 exercises
(decision 27). Floci is the solo path.

Ops crowds evaluate failure behavior, not features. Lead with blast
radius; the best moments are refusals.

## Before the room

- **Fountain.** A hosted instance with a hosted sandbox provider (Sprites,
  E2B, Daytona) for anything that claims containment. A self-hosted
  runner is trusted mode (F10); do not present it as sandboxed.
  `API_CORS_ORIGINS` and `OAUTH_CLIENTS` set for any app you will show.
- **Accounts.** For IAM: a sandbox org with the splashdown account set
  (demo-org.md), the org-tier credential on the facilitator's machine
  only, the plan/apply roles from I6 already built if the playlist starts
  past it.
- **Checkpoints.** One tag per IAM lesson (`I1` … `I15`) cut from the
  reference build; a failed lesson restarts from its checkpoint, never
  from scratch. Live agents fail on stage; plan for it.
- **Recorded runs.** The Access Analyzer verdict (I6) and the double
  refusal (I8) recorded once, in case the room's network is the thing
  that fails.

## Session formats

**Twenty minutes.** F3 (the denied `curl`), I3 (the red squiggle), I8 from
checkpoint (the double refusal), I12 (the ask). Four refusals and one PR.

**Sixty minutes.** F0, F3, F8, F9, then I3, I4, I7, I8, I12 from
checkpoints. Close with F11.

**Half day.** F0–F9 with the room following in solo mode, then I0–I8 live;
I12 and I13 as the finale; I15 if there is time.

## The IAM playlist, beat by beat

1. **Blast radius first** (F3, I12's Environment). The manifest on screen:
   sandboxed compute, default-deny egress to two named hosts, no cloud
   credentials. "Now watch it build your IAM repo anyway."
2. **Scaffold** (I1 from checkpoint `I0`). The teammate is handed the
   lessons and builds the layout. The scaffold is a PR the facilitator
   reviews and merges; say that this is the one place the room has to
   trust a human, and it is the same human who would have written the
   lint by hand.
3. **The red squiggle** (I3). A wildcard action fails before save.
4. **Deploy** (I4). Real account. Read a role back.
5. **Drift** (I7). Console edit; the watch fires; one PR, owned change
   only.
6. **The double refusal** (I8). Lint at build; IAM at apply. No human in
   either.
7. **The ask** (I12). "tickets-api needs read on the receipts bucket."
   One-file PR, access delta rendered, proof passed, opened by the
   concierge, merged by a CODEOWNER in the room.
8. **Closers.** The watcher's `run now` (I13); the transcript plus git
   blame as the audit trail; the export bundle (I15).

## Honesty lines, said out loud

- In beat 2 the agent writes the guardrails it will later be checked by.
  The review of that PR is where trust enters; after it, nothing the agent
  does is trusted and everything is verified.
- In beats 4 and 7 an apply happens. In production the apply is a gated
  job on a protected branch (I6); on stage the facilitator's credential
  does it, and the agent never holds it.
- The concierge holds a code-host token scoped to open PRs and nothing
  else; merge rights are grant rights, and it has none.
- Fountain has no approval gate in the loop (F11). The gate is the PR.
- Organizations and Identity Center exist only on the live path; solo
  learners never see the human half deploy.

## Questions the room will ask

- *"What if a merged change bricks the pipeline that fixes IAM?"*
  Recovery is designed thinnest; cloud-side expiry bounds break-glass;
  pipeline self-rescue is an open item (issues.md).
- *"Does this page me?"* SG and trust-anchor drift is page-worthy, the
  rest is PR-worthy; routing is open.
- *"It's noon on the hottest Saturday of the year and I need access."* I10: cloud-side TTL, no broker
  in the credential path; routine off-hours latency is a real trade and
  the answer is CODEOWNERS coverage.
- *"Why is the agent safe?"* It isn't. Nothing it does is trusted,
  everything it does is verified, and it holds nothing worth stealing.
- *"Can I run this on my own hardware?"* Yes (F10), and then it is not
  sandboxed; choose which scenarios that is fine for.

## Prep backlog

1. Reference build of splashdown/access; checkpoints tagged per lesson.
2. The seed test: a fresh teammate given the lessons produces a conforming
   repo; every failure is a lesson-writing bug.
3. Recorded runs for I6 and I8.
4. Floci verification for I8's solo path (plan.md, what is next).
