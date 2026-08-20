# water park

AWS IAM and security your whole org manages by PR. Built on
[chant](https://intentius.io/chant), with Terraform/OpenTofu as a
supported authoring backend behind a common change manifest.

AWS first, deliberately: it is where orgs centralize and where the
verification APIs live. GCP, Azure and Kubernetes are act two, gated on
persona equivalence.

One resource type per file. Folder structure is the index. A central repo
owns the guardrails and anyone can PR their way to the access they need.
The reviewer approves a rendered change manifest, not a text diff. Drift
is watched, break-glass is gated and self-revoking, and app-team repos
reference the central layer with typed imports instead of remote-state
reads.

This repo is in the planning phase.

- [docs/plan.md](docs/plan.md) — the design, open questions, terms
- [docs/positioning.md](docs/positioning.md) — positioning and audience
- [docs/landscape.md](docs/landscape.md) — the survey it rests on
- [docs/upstream.md](docs/upstream.md) — what it consumes from chant and
  Fountain
- [docs/pr-automation.md](docs/pr-automation.md) — the PR and manifest
  story
- [docs/threat-model.md](docs/threat-model.md) — threat and credential
  model
- [docs/decisions.md](docs/decisions.md) — pinned decisions
- [docs/demo-org.md](docs/demo-org.md) — flume, the canonical demo org
- [docs/design/](docs/design/) — in-progress designs (personas,
  multi-account, break-glass, guardrail rollout, workload identity, the
  agentic layer, [delegation](docs/design/delegation.md))
- [docs/issues.md](docs/issues.md) — issue breakdown
