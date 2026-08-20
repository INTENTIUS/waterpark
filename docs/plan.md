# water park — plan

water park is a **seed**: principles and prescriptions an agent on
Fountain turns into a working org-access repo, live, in front of an
audience (decision 25). The demo is the product right now; its purpose
is showing what Fountain can do, for an ops crowd, with the
highest-stakes payload available — org IAM. The kit the earlier docs
designed is parked, not dead.

## The seed

Three artifacts plus a stage set:

- [principles.md](principles.md) — ten invariants, each pinned by a
  decision.
- [prescriptions.md](prescriptions.md) — the concrete pattern, every
  prescription carrying its conformance check. This is what the agent
  is handed.
- [demo.md](demo.md) — the runbook: beats, checkpoints, honesty lines,
  the ops room's questions.
- [demo-org.md](demo-org.md) — flume, the fictional org the demo
  builds.

The seed test is the quality bar: a fresh Fountain conversation given
only the seed must produce a conforming repo. Every failure is a
seed-writing bug, which keeps the prescriptions honest — a
prescription an agent can't follow is an opinion.

## Why a seed

The pattern was always the value; the kit was one delivery vehicle.
The demo is a better one for now: nothing to install (the install is
the show), no waiting on upstream features (the demo uses what exists
today), and the thesis performs itself — an untrusted author doing
ops-grade work safely is simultaneously the Fountain pitch and
principle 2.

Backends stay first-class end states (decision 23): the principles are
backend-neutral, and chant is the demo toolchain because its
amplifiers are stage-visible — lint failing in the editor, no state
file, Floci deploying with zero credentials.

## The pattern, in one paragraph

The best centralized security config observed in the wild: one
resource type per file, folder structure as the index, anyone PRs
their way to the access they need. It worked because finding a
resource was a path lookup, the PR diff was the blast radius, and git
blame was the audit trail. The worst version was a write GUI. The
lessons are the spec, and the prescriptions are those lessons made
checkable.

## Beyond the demo

The parked kit backlog — tracks A–E, acceptance criteria, filing
order — is retained in [issues.md](issues.md), and the design docs
under [design/](design/) carry the depth behind each prescription.
The kit's four open unknowns are recorded there too: cross-repo refs,
cross-cloud persona equivalence, cross-repo reachability, and the
manifest schema. [upstream.md](upstream.md) tracks what chant and
Fountain ship that the demo can use. Nothing in any of them gates the
demo; un-parking the kit is a decision-25 edit.

## Terms

- **seed** — principles + prescriptions + runbook, the input an agent
  builds from.
- **beat** — one live demo moment with its own checkpoint.
- **principal / persona / grant / estate** — as the prescriptions use
  them: an identity managed as one leaf file; the typed archetype it
  instantiates; one typed access statement (optionally expiring); and
  everything live the repo owns or watches.
- **manifest** — the rendered change set a reviewer approves, bound by
  digest (decision 24).
