# Design: the agentic layer

water park is accidentally the best-case agentic target: everything built
to make a first-time human contributor safe — near-data leaf files,
lint-in-editor, Access Analyzer proofs, CODEOWNERS, gated applies,
ownership, drift watch — is a verification harness that makes untrusted
authors safe. An agent is just another untrusted author.

## The stance

**The agent proposes, the pipeline verifies, humans approve.** Trust
never attaches to the agent; it attaches to the compiled checks, the same
trust model the repo already applies to people. The no-write-GUI decision
is not violated: chat authors the PR, but the PR remains the only write
path.

Hard lines (decision 14):

- The agent never approves, never applies, never signals a Temporal gate.
- The agent holds plan-tier (read-only) credentials only, and its
  identity is itself a water park workload principal via the trust layer
  (A18) — water park manages the access of the agents that author water
  park changes.
- Agent output is untrusted input like any contributor's. The request
  text it consumes is a prompt-injection surface, tolerable precisely
  because the verification stack doesn't care who authored the PR.
- Agent commentary on PRs is labeled commentary; facts, renderings, and
  proofs stay deterministic.

## Runtime: Fountain

[Fountain](https://github.com/BinaryBourbon) (multi-tenant sandboxed
coding-agent platform; Environment/Vault/Agent/Conversation primitives,
REST conversations API, manifest-driven apply) is the standing runtime.
The org defines one Environment: water park checkout, SKILL.md, chant MCP
server, plan-tier credentials, `egress_only` networking. Teams get
conversations against it via the API — the hook for a Slack front-end or
CLI. The reference Environment manifest ships in this repo (D1) so
adopting the concierge is `fountain apply`.

Without Fountain the same works ad hoc: clone the repo, ask your agent —
SKILL.md carries the capability map (A15). Fountain turns that into an
org service with tenancy, sandboxing, and scoped secrets.

## The capability ladder

1. **Q&A** (read-only, zero risk). "Who can reach the invoices bucket?"
   "What would offboarding search-indexer remove?" — answered from the
   graph via chant MCP.
2. **Request → PR.** "payments-api needs read on the invoices bucket" →
   find the leaf file by path convention, one-file typed edit, PR. Lint
   and CheckNoNewAccess run before any human looks.
3. **Explain.** Annotation on drift/reconcile PRs (cross-reference
   CloudTrail: who changed it, when) and reviewer-side commentary on
   human PRs, layered on the deterministic rendering.
4. **Proactive hygiene.** A scheduled agent turns Access Analyzer
   unused-access findings and expiring grants into burndown PRs — the
   least-privilege ratchet as a stream of small reviewable changes.
   Nobody in the landscape does remediation-as-PRs.
5. **Concierge for the Ops.** Break-glass requested conversationally (the
   gate and human approval stay exactly where they are), offboard drafted
   from a departure notice, new-service scaffolding of a satellite from
   the context package.
6. **Migration.** A carve-driven conversation that walks existing
   Terraform IAM into leaf files (with A14).

## Better than asking chant: domain verbs

A generic agent in a water park checkout already has chant MCP (graph,
source/owns/compare, build) and can answer questions by exploring and
author PRs by free-editing files. That's the baseline any chant repo
gets. The refinement is to give the agent **fewer, sharper verbs** — and
the packaging unit for those verbs is exactly custom Ops and lifecycle
projections:

1. **Write side: intent goes through an Op, not free editing.** A
   `wp-request` Op takes structured intent — principal, resource, access
   level, expiry — locates the leaf file by convention, applies the edit
   deterministically, runs lint + CheckNoNewAccess locally, opens the PR.
   The agent's job shrinks to extracting intent from plain language; the
   Op does the authoring. The agent fills in a typed form; the Op writes
   the code. Reproducible, testable, and the diff shape is always the
   same. Same pattern for offboard, break-glass, and satellite
   scaffolding — every ladder level terminates in an existing gated Op or
   a new intent Op, never in ad-hoc agent behavior.
2. **Read side: projections, not graph walks.** "Who can reach X" is a
   graph lens (`chant graph` lens machinery, chant#492); "what drifted,"
   "what expires in 30 days," "what would offboarding remove" are
   lifecycle/change-set projections exposed as typed commands. The
   access-review Op (A11) additionally emits a queryable index artifact
   (principal → reachable resources, expiries, last-changed) so Q&A reads
   a precomputed answer — fast, consistent between askers, and the same
   artifact compliance consumes — instead of re-deriving the graph per
   question.
3. **Refusals are part of the interface.** SKILL.md golden paths include
   what the concierge won't do (boundary exceptions, guardrail-path
   edits) and the escalation route, so a denial is a directed next step,
   not a dead end.

chant gap to file: project-local MCP tools. Lexicons ship MCP tools;
projects ship only skills and `.chant/rules/`. water park's domain verbs
want to surface as MCP tools from the repo/context package (a
`.chant/tools/` analog to `.chant/rules/`) so any MCP-speaking agent gets
`wp-request`/lens/projection verbs without a lexicon.

## To decide

1. Front-end: Slack vs CLI vs both; where the conversation → Fountain API
   glue lives.
2. Which CloudTrail access the explain agent needs and whether that
   stretches the plan tier (read-only but sensitive — may be its own
   credential scope).
3. Hygiene-agent cadence and PR volume limits (a burndown that opens 40
   PRs on day one is noise, not hygiene).
4. Whether level-1 Q&A ships inside behold instead of (or as well as) the
   concierge.
