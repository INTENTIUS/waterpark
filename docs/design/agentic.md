# Design: the agentic layer

water park is accidentally the best-case agentic target: everything
built to make a first-time human contributor safe — near-data leaf
files, lint-in-editor, Access Analyzer proofs, CODEOWNERS, gated
applies, ownership, drift watch — is a verification harness that makes
untrusted authors safe. An agent is just another untrusted author.

## The stance

**The agent proposes, the pipeline verifies, humans approve.** Trust
never attaches to the agent; it attaches to the compiled checks, the
same trust model the repo applies to people. The no-write-GUI decision
is not violated: intake authors the PR, but the PR remains the only
write path.

Hard lines (decision 14): the agent never approves, applies, or signals
a gate. The sandbox holds no cloud credentials and is never a federation
subject (decision 15) — the plan-tier credential belongs to the verb
service outside the sandbox boundary, itself a water park workload
principal (A18); the sandbox gets a conversation-scoped verb-API token
and nothing else. Request text is a prompt-injection surface, tolerable
precisely because the verification stack doesn't care who authored the
PR. Agent commentary is labeled commentary; facts, renderings, and
proofs stay deterministic.

## Runtime: Fountain

[Fountain](https://github.com/BinaryBourbon/fountain) (multi-tenant
sandboxed coding-agent platform) is the standing runtime. The org
defines one Environment: water park checkout, SKILL.md, a
conversation-scoped token for the domain-verb API, a default-deny egress
allowlist pinned to the verb service and the code host
([upstream.md](../upstream.md)), no cloud credentials. The chant MCP
verb service runs outside the sandbox boundary, holds the plan-tier
credential behind a network-bound trust anchor
([workload-identity.md](workload-identity.md)), and is the only thing
the sandbox can call. The credential design still assumes exfiltration;
the allowlist is defence in depth.

Fountain enforces the boundary; water park declares its policy. Intake
is a CLI, a ticket webhook, or a Fountain conversation against the same
Environment; the reference manifest ships in this repo (D1), so adopting
the concierge is `fountain apply`. A chat front-end is deferred —
decisions 17 and 18 pin the rules it must satisfy when it returns.
Without Fountain the same works ad hoc: clone the repo, ask your agent —
SKILL.md carries the capability map (A15).

## The capability ladder

1. **Q&A** (read-only). "Who can reach the invoices bucket?" from
   `chant search`; offboarding previews from lifecycle projections.
2. **Request → PR.** "payments-api needs read on the invoices bucket" →
   one-file typed edit, PR, lint and CheckNoNewAccess before any human
   looks.
3. **Explain.** Who/when annotation on drift PRs, reviewer-side
   commentary, layered on the deterministic rendering.
4. **Proactive hygiene.** A scheduled agent turns unused-access
   findings and expiring grants into burndown PRs — remediation-as-PRs,
   which nobody in the landscape does.
5. **Concierge for the Ops.** Break-glass requested conversationally
   (the gate stays where it is), offboard drafted from a departure
   notice, satellite scaffolding.
6. **Migration** (optional). A carve-driven conversation walking
   Terraform IAM into chant leaf files, for orgs that choose that
   backend (A14).

Outbound, crossing all six: the Ops can notify into the org's intake
surfaces. Notification only — each terminates in a PR or an existing
gate, and nothing takes an instruction back (decision 18).

## Better than asking chant: domain verbs

A generic agent in a checkout already has chant MCP and can free-edit
files. The refinement is **fewer, sharper verbs**, packaged as Ops and
projections:

1. **Write side: intent goes through an Op.** `wp-request` takes
   structured intent — principal, resource, access level, expiry —
   locates the leaf file by convention, applies the edit
   deterministically, runs lint + CheckNoNewAccess, opens the PR. The
   agent extracts intent; the Op authors — same diff shape every time.
   Same pattern for offboard, break-glass, and scaffolding: every ladder
   level terminates in a gated or intent Op, never ad-hoc agent behavior.
2. **Read side: queries and projections, not graph walks.** `chant
   search` answers reachability in tens of tokens; "what expires in 30
   days" and "what would offboarding remove" are lifecycle projections
   exposed as typed commands.
3. **Refusals are part of the interface.** SKILL.md golden paths include
   what the concierge won't do and the escalation route, so a denial is
   a directed next step.

chant gaps: project-local MCP tools (a `.chant/tools/` analog of
`.chant/rules/`) so the domain verbs surface to any MCP-speaking agent
without a lexicon; and chant#1290 (a step cannot reference a prior
step's output), so `wp-request` returns its PR URL as a search attribute
or artifact.

## Executors and the HITL fallback

Temporal is optional, exactly as chant Ops already work. The
human-in-the-loop ladder: (1) the PR merge is the universal gate —
`wp-request` runs on the local executor and ends at a PR, so the intent
Op needs no gate of its own; (2) CI-native gates (`gate: 'ci'`) cover
gated applies with no Temporal deployment; (3) Temporal signal gates
(`gate: 'op'`) for operations needing a gate outside any one CI run —
break-glass, restore-class applies.

Break-glass keeps a documented no-Temporal path (local executor, CLI
confirmation by a second human) and stays safe with a weak gate because
revocation never depends on the gate: cloud-side expiry holds
regardless of executor. Gates degrade gracefully down the ladder;
revocation guarantees never degrade, because they live in the cloud.

## Git and ticketing integration

Git is the core, not an integration: the PR is the write path, blame
the audit trail, CODEOWNERS the routing, provenance keyed to PR/sha.
One addition: an `Access-Request: JIRA-123` trailer joining changes to
their originating request, indexed by the access-review Op so
compliance queries walk ticket → PR → provenance as one chain.

Ticketing is where most orgs' access requests live, and the stance
mirrors the GUI decision: **tickets are intake and notification; the
repo is the system of record.** Never sync state bidirectionally.
Inbound, a labeled ticket starts a concierge conversation and tracks the
PR's lifecycle as comments; outbound, events needing a human decision
but not a PR can file tickets. The concierge's Environment includes the
org's ticketing MCP server; chant needs no Jira lexicon.

## To decide

1. Which CloudTrail access the explain agent needs and whether that
   stretches the plan tier — wherever it lands, it lives in a verb
   service, never the sandbox; likely a dedicated `who-changed-this`
   projection.
2. Hygiene-agent cadence and PR volume caps (40 PRs on day one is
   noise, not hygiene).
3. Whether level-1 Q&A ships inside behold as well as the concierge.
4. The ticket-lifecycle comment format.
