---
title: "Design: the agentic layer"
---

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
sandboxed coding-agent platform) is the standing runtime; lessons F1–F11
teach it, and [the propose loop](../../propose-loop.md) is the loop the concierge (desk
form) and the watcher (Rounds form) instantiate. The org defines one Environment: the access-repo checkout,
SKILL.md, a conversation-scoped token for the domain-verb API, a
default-deny egress allowlist pinned to the verb service and the code
host, no cloud credentials. The concierge is a teammate on that
Environment (F5); the watcher is the same teammate on a schedule (F6).
The verb service runs outside the sandbox boundary and follows Rounds'
server design (decision 30): it holds the plan-tier credential behind a
network-bound trust anchor ([workload-identity.md](workload-identity.md)),
enforces the rules the prompt cannot, and is the only thing that writes.
Where a human is present, Mend's form — the PR opened from the human's
browser with the human's token — is enough. The credential design still
assumes exfiltration; the allowlist is defence in depth, and only holds
on a hosted sandbox provider (decision 29; a self-hosted runner is
trusted mode).

Fountain enforces the boundary and the repo declares its policy, with
the concierge's own Environment manifest checked in beside it. Fountain has no
approval gate in the loop (ADR 0016 proposed, unbuilt; F11), which is
why decision 14 puts the gate at the PR. Intake is a CLI, a ticket
webhook, or a Fountain conversation against the same Environment; the
reference manifest ships with lesson I12, so adopting the concierge is
`fountain apply`. A chat front-end is deferred — decisions 17 and 18 pin
the rules it must satisfy when it returns. Without Fountain the same
works ad hoc: clone the repo, ask your agent — SKILL.md carries the
capability map (A15).

## The capability ladder

1. **Q&A** (read-only). "Who can reach the artifacts bucket?" answered
   from `scripts/whocan`, and offboarding previews from the same
   read-only scripts.
2. **Request → PR.** "tickets-api needs read on the receipts bucket" →
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
6. **Migration** (optional). A conversation walking a pile of
   hand-rolled Terraform into the one-resource-per-file layout, for orgs
   adopting the pattern on an estate they already have (A14).

Outbound, crossing all six: the Ops can notify into the org's intake
surfaces. Notification only — each terminates in a PR or an existing
gate, and nothing takes an instruction back (decision 18).

## Better than a free-editing agent: domain verbs

An agent loose in a checkout can edit any file any way it likes, and
every edit is a different diff. The refinement is **fewer, sharper
verbs**, which here are ordinary scripts in the repo that a human runs
the same way.

1. **Write side: intent goes through a script.** `scripts/request` takes
   structured intent, which is a principal, a resource, an access level
   and an optional expiry. It locates the file by convention, applies the
   edit deterministically, runs the checks and the no-new-access proof,
   and opens the PR. The agent extracts intent and the script authors, so
   the same request produces the same diff every time. Offboard,
   break-glass and satellite scaffolding follow the same pattern, and
   every ladder level terminates in one of these rather than in ad-hoc
   agent behavior.
2. **Read side: queries, not graph walks.** `scripts/whocan` answers
   reachability in tens of tokens. "What expires in 30 days" and "what
   would offboarding remove" are `scripts/expiring` and
   `scripts/offboard --preview`, reading the declared HCL and the live
   estate.
3. **Refusals are part of the interface.** SKILL.md golden paths include
   what the concierge will not do and the escalation route, so a denial
   is a directed next step.

The scripts are the contract, not the agent. Anything the concierge can
do, a person can do by running the same command, which is what makes the
agent replaceable and prescription 13 checkable.

## Executors and the HITL fallback

A durable executor such as Temporal is optional. The human-in-the-loop
ladder has three rungs. First, the PR merge is the universal gate, since
`scripts/request` ends at a PR and needs no gate of its own. Second,
CI-native gates cover gated applies with nothing else deployed. Third, a
durable workflow with a signal gate covers operations that need a gate
outside any one CI run, which means break-glass and restore-class
applies.

Break-glass keeps a documented path with no durable executor at all,
which is a CLI confirmation by a second human, and it stays safe with a
weak gate because revocation never depends on the gate. Cloud-side expiry
holds regardless. Gates degrade gracefully down the ladder and revocation
guarantees never degrade, because they live in the cloud.

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
org's ticketing MCP server, and nothing in the repo needs to know what
tracker the org uses.

## To decide

1. Which CloudTrail access the explain agent needs and whether that
   stretches the plan tier — wherever it lands, it lives in a verb
   service, never the sandbox; likely a dedicated `who-changed-this`
   projection.
2. Hygiene-agent cadence and PR volume caps (40 PRs on day one is
   noise, not hygiene).
3. Whether level-1 Q&A ships as a read-only page as well as the
   concierge.
4. The ticket-lifecycle comment format.
