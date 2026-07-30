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
- The sandbox holds no cloud credentials and is never a federation
  subject (decision 15). The plan-tier credential belongs to the verb
  service outside the sandbox boundary, which is itself a water park
  workload principal via the trust layer (A18) — water park manages the
  access of the services that serve the agents that author water park
  changes. The sandbox gets a conversation-scoped verb-API token and
  nothing else.
- Agent output is untrusted input like any contributor's. The request
  text it consumes is a prompt-injection surface, tolerable precisely
  because the verification stack doesn't care who authored the PR.
- Agent commentary on PRs is labeled commentary; facts, renderings, and
  proofs stay deterministic.

## Runtime: Fountain

[Fountain](https://github.com/BinaryBourbon) (multi-tenant sandboxed
coding-agent platform; Environment/Vault/Agent/Conversation primitives,
REST conversations API, manifest-driven apply) is the standing runtime.
The org defines one Environment: water park checkout, SKILL.md, the A11
index artifact, a conversation-scoped token for the domain-verb API,
`networking_type: limited` with a pinned `networking_config` (fountain's
actual API surface — the enum is `unrestricted | limited`, not the
`egress_only` its docs describe) — and no cloud credentials
(decision 15). The chant MCP verb service runs outside the sandbox
boundary, holds the plan-tier credential behind a network-bound trust
anchor ([workload-identity.md](workload-identity.md)), and is the only
thing the sandbox can call. Restricted networking limits inbound, not
exfiltration — the credential design assumes exfiltration and makes it
worthless.
Fountain enforces this boundary (isolation, token plumbing, egress);
water park declares its policy (the verb service's trust anchor and
role, lint on both). Teams get conversations against the Environment
via the API — the hook for a Slack front-end or CLI. The reference
Environment manifest ships in this repo (D1) so adopting the concierge
is `fountain apply`.

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

## Executors and the HITL fallback

The temporal lexicon is involved **optionally**, exactly as chant Ops
already work (loomster precedent: `chant run <op>` on the local executor,
`--temporal` where durability and gates are wanted). water park's
human-in-the-loop is a three-tier ladder, and Temporal is the top tier,
not a requirement:

1. **The PR merge is the universal gate.** Everything that flows through
   code — including every agent-authored change — gets durable HITL from
   the code host itself: review, approval, merge. No Temporal anywhere.
   `wp-request` runs on the local executor and *ends* at a PR, so the
   intent Op needs no gate of its own.
2. **CI-native gates** (`gate: 'ci'` in pr-automation.md): GitHub
   environment required-reviewers, GitLab manual jobs. Covers gated
   applies for orgs with no Temporal deployment.
3. **Temporal signal gates** (`gate: 'op'`): for the operations that need
   a gate *outside* any one CI run — break-glass, restore-class applies —
   where durability across runner death and a workflow-history audit
   trail matter.

Break-glass keeps a documented no-Temporal path (local executor, CLI
confirmation by a second human — also the code-host-down story,
break-glass item 5), and it stays safe with a weak gate because
revocation never depends on the gate: cloud-side expiry (layer 1) holds
regardless of executor. The rule of thumb: gates degrade gracefully down
the ladder; revocation guarantees never degrade because they live in the
cloud, not the workflow.

## Git and ticketing integration

Git is already the core, not an integration: the PR is the write path,
blame is the audit trail, CODEOWNERS is the routing, and apply provenance
keys to PR/sha (pr-automation item 12). The one addition worth a
convention: a commit/PR trailer (`Access-Request: JIRA-123`) joining
changes to their originating request, indexed by the access-review Op so
compliance queries walk ticket → PR → apply provenance as one chain.

Ticketing (Jira, Linear, ServiceNow) is where most orgs' access requests
live today, and the stance mirrors the GUI decision: **tickets are intake
and notification surfaces; the repo is the system of record.** Never sync
state bidirectionally into a ticket — that's the write-GUI trap in new
clothes.

- **Inbound**: a labeled ticket starts a concierge conversation (Fountain
  API webhook glue); the concierge extracts intent, runs `wp-request`,
  links the PR back, and the ticket tracks the PR's lifecycle
  (opened/approved/applied) as comments. Orgs with ServiceNow-style
  access-request processes keep their intake and their evidence chain —
  the chain just terminates in a PR and a provenance record instead of a
  screenshot.
- **Outbound**: water park events that need a human decision but not a PR
  (drift on a foreign resource, review-campaign assignments, hygiene
  findings exceeding the PR volume cap) can file tickets.
- **Mechanism**: this lives at the agent layer, not the deterministic
  core. The concierge's Fountain Environment includes the org's ticketing
  MCP server; chant needs no Jira lexicon. The code hosts' own issue
  systems are already covered by the github/gitlab/forgejo lexicons and
  the orbit MCP tools.

## To decide

1. Front-ends: Slack, CLI, and/or ticket-webhook intake; where the
   glue that starts Fountain conversations lives. Ticket-lifecycle
   comment format.
2. Which CloudTrail access the explain agent needs and whether that
   stretches the plan tier (read-only but sensitive — may be its own
   credential scope). Wherever it lands, it lives in a verb service,
   never in the sandbox (decision 15) — likely a dedicated
   `who-changed-this` projection rather than raw CloudTrail reach.
3. Hygiene-agent cadence and PR volume limits (a burndown that opens 40
   PRs on day one is noise, not hygiene).
4. Whether level-1 Q&A ships inside behold instead of (or as well as) the
   concierge.
5. Fountain gap to track: conversation-time `vault_id` can override the
   declared Environment's env vars (vault wins on key collision), with no
   agent-side allowlist — a caller can inject env into the concierge
   sandbox at spawn. Upstream ask filed (chant#1217, ask 4); until it
   lands, D1 mitigates by restricting who may open conversations against
   the concierge Environment.
