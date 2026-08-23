---
title: "The propose loop"
weight: 1
---

{{< todo "prose" >}}

<!-- context: How work gets done at splashdown is one loop, abstracted from three Fountain apps — [Mend](https://github.com/jhgaylor/mend), [Rounds](https://github.com/jhgayl … -->

## The parts

| Part | What it is | Mend | Rounds | dns-desk |
|---|---|---|---|---|
| **target** | the thing under management, which the agent does not control and whose contents it treats as untrusted | a repo's CI, k8s, Docker and cloud config | the same, enrolled | the Cloudflare zones a token can see |
| **read** | a deterministic read of the target. Audit-driven: **findings** sorted by how confident the fix is — *deterministic* (exact edit known), *judgement* (confident something is wrong; will not guess the fix), *report-only*. Request-driven: the current state, re-read before any apply | `chant audit`, ten catalogs, the silent ones shown greyed | the same, on a schedule | `dns-state`, incremental per zone |
| **operator** | an agent on a toolkit environment with the tool on its PATH and a credential that can **read the target and nothing more**, one per target | one mender per repo; a per-repo read-only token in its own vault | the same, holding a grant it trades for a one-hour read-only token | one desk per token; the vault's zone list is the blast radius |
| **plan** | what the operator proposes, per finding or per request: *applied* (mechanical, from the tool's own diff), *proposed* (a judgement call it was confident in), *skipped* (turns on intent it cannot see, with a note on what to decide); rendered as a diff | `mend-plan` plus one `mend-fix` block per fix, independently selectable | one cluster per file, with status | `dns-plan`, a diff against the last read |
| **verify** | re-run the read after the change, before proposing: findings gone, merge-worthy count not up, files still parse; or the target re-read and the plan re-made if it moved | before the plan is shown | a failed verify opens nothing | re-read the zone before apply; re-plan instead of applying stale |
| **propose** | the only path that writes, held by something that is not the operator | the human's browser with the human's token; every context line re-verified against the target right now | a server minting a one-target write token for one proposal, checking policy and history, rendering the PR body from the findings | the desk applies after an `APPROVE plan-id` message, with a token that was scoped before the conversation began |
| **rules** | constraints that hold when the prompt is ignored, enforced where the write happens | the browser refuses a stale patch | never reopen what a human closed; never a second PR for the same thing; never outside the derived branch; at most N open; `enabled: false` means nothing | the token's scope; today the approve is convention and the audit trail, until fountain#643 |
| **record** | where the state lives: where the person who decides is already standing, nothing to keep in sync | the conversation: report, plan, patch derived from turns and blocks | GitHub: branch name and a marker in the PR body; the conversation for the round report | the conversation: plan status always derived, never stored |
| **refusal** | an outcome, not a failure, rendered as one | `skipped`, with the note | `already-open`, `declined`, `deferred`, `clean`; a decline sticks until `rounds:reconsider` | a request outside the token's zones |

{{< todo "prose" >}}

<!-- context: Two invariants run through every column. The claim and the report are one copy (a PR body rendered from the objects the plan reports cannot disagree with it). A … -->

## The four forms

|  | audit-driven | request-driven |
|---|---|---|
| **interactive** | Mend: point it at a target, watch, ask for changes, take the patch or open the PR yourself | dns-desk: ask in words, read the plan as a diff, approve, done |
| **ambient** | Rounds: schedule, reconcile against its own past work, cap, server as propose, declines stick | (a ticket webhook starting a desk conversation; no app yet) |

## The loop on IAM

{{< todo "prose" >}}

<!-- context: the applier is CloudFormation, never the agent; the desk proposes (repo mode) or applies only in direct mode with a bounded role; see docs/aws-desk.md -->

{{< todo "prose" >}}

<!-- context: IAM is a target that is *also* a repo, so propose is the PR in every form and approval is the merge, never an in-conversation message (decision 18). That is the … -->

| Form | IAM instance | Build or reuse | Shifts |
|---|---|---|---|
| interactive, request-driven | **the concierge**, in the desk's form: the estate on screen (`chant search`), "tickets-api needs read on the receipts bucket", `wp-request` makes one deterministic leaf edit, the plan is the rendered access delta, the PR is opened with a PR-only token, CODEOWNERS approve, the gated job applies; refusals name the enrollment or escalation path | build | I12 |
| ambient, audit-driven | **the watcher**, in Rounds' form: unused-access findings and expiring grants on a schedule, one PR per finding, capped, declines stick; and the drift reconcile under the same rules | Rounds as-is for the lint tier (enroll `splashdown/access`); IAM projections added | I7, I13 |
| interactive, audit-driven | **mend the access repo**: point Mend at `splashdown/access`; `chant audit`'s aws catalog reads the synthesized CloudFormation; the repo's own `.chant/rules/` are the judgement tier | Mend as-is | I3 |
| ambient, request-driven | a ticket that opens a desk conversation and tracks the PR as comments | later | I12 (ticketing) |

{{< todo "prose" >}}

<!-- context: The parts, on IAM: … -->

| Part | IAM at splashdown | Shifts |
|---|---|---|
| target | `splashdown/access` and the live estate it owns; a satellite repo | I1, I8 |
| read | the lint pack, the drift watch, the Access Analyzer proofs, the unused-access and expiring-grant projections, `chant search` for the estate view | I3, I6, I7, I11 |
| operator | a teammate on the reference Environment: checkout, SKILL.md, a code-host token that can open PRs and nothing else, **no cloud credential** | I12, F4 |
| plan | the access delta rendered by the deterministic renderer (never the model); a directed refusal for a boundary exception or an unmapped requester | I12, I14 |
| verify | lint and emulator-backed validation on every PR with no credential; CheckNoNewAccess where an untrusted author cannot trigger it; the manifest digest re-checked at apply | I4, I6, I14 |
| propose | the PR; merge-then-apply by a gated job on a protected branch; the watcher's propose endpoint with cap and declined list | I6, I13 |
| rules | generated CODEOWNERS and branch protection; the apply role's own boundary; the satellite's `iam:PermissionsBoundary` condition; Rounds' rules on reconcile and watcher (decision 28) | I5, I6, I7, I8 |
| record | git: blame, the PR, provenance by PR and sha; the conversation for the request; reconcile state in the code host | I6, I7, I12 |
| refusal | the red squiggle; the double refusal; "unmapped identity, here is the enrollment path"; a reconcile PR closed unmerged | I3, I8, I12, I7 |

## What the loop asks of Fountain

{{< todo "prose" >}}

<!-- context: An environment with the tool preinstalled and no secrets (F1, F4); a vault per target bound at creation (F4); a teammate per target with a persistent computer s … -->
