# water park

Cross-cloud IAM and security your whole org manages by PR. Built with
[chant](https://intentius.io/chant).

One resource type per file. Folder structure is the index. A central repo owns
the guardrails and anyone can PR their way to the access they need. Drift is
watched, break-glass is gated and self-revoking, and app-team repos reference
the central layer with typed imports instead of remote-state reads.

This repo is in the planning phase.

- [docs/plan.md](docs/plan.md) — the design, open questions, terms
- [docs/positioning.md](docs/positioning.md) — positioning and audience
- [docs/landscape.md](docs/landscape.md) — the survey it rests on
- [docs/pr-automation.md](docs/pr-automation.md) — the PR automation story
- [docs/threat-model.md](docs/threat-model.md) — threat and credential model
- [docs/decisions.md](docs/decisions.md) — pinned decisions
- [docs/demo-org.md](docs/demo-org.md) — flume, the canonical demo org
- [docs/design/](docs/design/) — in-progress designs for the gating
  questions (personas, multi-account, break-glass, guardrail rollout)
- [docs/issues.md](docs/issues.md) — draft issue breakdown, not yet filed
