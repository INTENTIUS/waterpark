# The demo

**What this shows: Fountain doing ops-grade work safely.** The audience
is ops engineers, and the payload is deliberately the scariest domain —
org IAM — built live by an agent the room is told up front not to
trust. water park is the seed: the agent is handed
[principles.md](principles.md) and [prescriptions.md](prescriptions.md)
and builds flume's access repo on stage. The thesis performed:
principle 2 — trust attaches to compiled checks, never to authors — is
what makes an untrusted agent safe to put in front of your IAM, and
Fountain is what makes it safe to run at all.

Ops crowds evaluate failure behavior, not features. So the demo leads
with blast radius, and its best moments are refusals.

## Setup

- **Fountain Environment, shown before the agent.** The manifest:
  sandboxed compute, default-deny egress allowlist, **no cloud
  credentials anywhere in the sandbox** (principle 7). `fountain apply`
  stands it up. The self-hosted runner is the answer to "we would
  never run this on shared infra."
- **Floci** is the other half of the trick: the whole estate deploys
  to CREATE_COMPLETE with zero cloud credentials and no AWS account on
  stage.
- **flume** ([demo-org.md](demo-org.md)) is the stage set; its
  canonical scenarios are the beats below.
- **Checkpoints.** Every beat has a committed checkpoint (tag per
  beat); a failed beat restarts from its checkpoint, never from
  scratch. Live agents fail on stage; the runbook assumes it.

## The beats

1. **Blast radius first.** Show the Environment manifest. "This agent
   cannot reach a cloud, cannot leave its sandbox except to two hosts,
   and holds no credentials. Now watch it build your IAM repo anyway."
2. **Seed → scaffold.** Paste the seed into a conversation. The agent
   scaffolds flume's repo: layout, lint rules, personas, baseline.
   Live. (Checkpoint covers total stall.)
3. **The editor refusal.** Write a wildcard policy — it fails before
   it's saved, with a fix-it. Machinery, not a tired reviewer
   (prescription 4).
4. **Deploy with no credentials.** The estate reaches CREATE_COMPLETE
   against Floci. No account, no keys, nothing to leak from the
   sandbox.
5. **The drift.** Hand-widen the deployed SG. The watch flags it
   within a cycle; a reconcile PR appears containing only the owned
   change (scenario 2, prescription 11). The system noticed before the
   room did.
6. **The double refusal.** Strip the permission boundary from a
   satellite role: lint refuses at build. Bypass the lint: IAM refuses
   at apply (scenario 5, prescription 8). Two independent layers, no
   human in either. The best thirty seconds of the demo.
7. **The ask.** In the conversation: "payments-api needs read on the
   invoices bucket." A reviewable PR appears with the access delta
   rendered (scenario 6). The punchline for the room: the agent that
   built the repo just used it, and at no point did anyone need to
   trust the agent.
8. **Optional closers.** The audit trail: the Fountain conversation
   transcript plus git blame — everything the agent did, attributable
   and queryable. The walk-away: build the export bundle, delete the
   toolchain, deploy the artifacts with the AWS CLI alone
   (principle 9).

## Honesty lines, said out loud

- The Access Analyzer proof does not run on stage — it needs
  credentials, and by design it never runs where an untrusted author
  can trigger it (prescription 6). Show the rendered verdict from a
  recorded run and say so.
- Organizations/Identity Center are beyond Floci's emulation; the
  demo's estate is roles, policies, and SGs. Say so if asked.
- The fixture proves the seams, not a production estate. The parked
  kit backlog ([issues.md](issues.md)) is what hardening beyond the
  demo looks like.

## Questions the room will ask

- *"What if a merged change bricks the pipeline that fixes IAM?"*
  Honest answer: recovery/rollback is designed thinnest — cloud-side
  expiry bounds break-glass, but pipeline self-rescue is an open item
  in the parked backlog.
- *"Does this page me?"* Severity routing is deliberately open; the
  stance is that SG and trust-anchor drift is page-worthy, the rest is
  PR-worthy.
- *"It's 2am Saturday and I need access."* Break-glass for incidents
  (cloud-side TTL, beat-proof); routine off-hours latency is a real
  trade against JIT brokers, and the answer is CODEOWNERS coverage,
  not a broker in the credential path.
- *"Why is the agent safe?"* It isn't. That's the point — nothing it
  does is trusted, everything it does is verified, and it holds
  nothing worth stealing.

## Demo prep (the only live backlog)

1. The flume fixture estate, checked in and deployable to Floci.
2. The seed test: a fresh Fountain conversation given only
   principles.md + prescriptions.md produces a conforming repo — run
   it until it passes reliably; every failure is a seed-writing bug.
3. Checkpoints recorded per beat; recovery drilled.
4. The recorded proof run for beat 3's honesty line.
