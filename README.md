# water park

Cross-cloud IAM and security your whole org manages by PR. Built with
[chant](https://intentius.io/chant).

One resource type per file. Folder structure is the index. A central repo owns
the guardrails and anyone can PR their way to the access they need. Drift is
watched, break-glass is gated and self-revoking, and app-team repos reference
the central layer with typed imports instead of remote-state reads.

This repo is in the planning phase. See [docs/plan.md](docs/plan.md) for the
design, [docs/positioning.md](docs/positioning.md) for positioning and
audience, [docs/landscape.md](docs/landscape.md) for the survey it rests on,
[docs/pr-automation.md](docs/pr-automation.md) for the PR story, and
[docs/issues.md](docs/issues.md) for the draft issue breakdown.
