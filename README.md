# water park

A seed for a live demo: what [Fountain](https://github.com/BinaryBourbon/fountain)
can do, shown to an ops crowd, with the scariest payload available —
org IAM. An agent holding zero cloud credentials is handed the
principles and prescriptions in this repo and builds a working AWS
access repo on stage: one resource type per file, PR-only writes,
guardrails failing in the editor, drift caught and reverted,
delegation bounded by IAM itself. Built with
[chant](https://intentius.io/chant); nothing the agent does is
trusted, everything it does is verified.

- [docs/principles.md](docs/principles.md) — the ten invariants
- [docs/prescriptions.md](docs/prescriptions.md) — the checkable
  pattern the agent is handed
- [docs/demo.md](docs/demo.md) — the runbook: beats, checkpoints,
  honesty lines
- [docs/demo-org.md](docs/demo-org.md) — flume, the org the demo
  builds
- [docs/plan.md](docs/plan.md) — the seed strategy
- [docs/decisions.md](docs/decisions.md) — pinned decisions, the
  ledger of why
- [docs/positioning.md](docs/positioning.md) /
  [docs/landscape.md](docs/landscape.md) — why the pattern, and the
  survey it rests on
- [docs/threat-model.md](docs/threat-model.md) — the failure-mode
  story the ops room will ask about
- [docs/upstream.md](docs/upstream.md) — what chant and Fountain ship
  that the demo uses
- [docs/issues.md](docs/issues.md) — the parked kit backlog
  (decision 25)
- [docs/design/](docs/design/) — depth behind the prescriptions
