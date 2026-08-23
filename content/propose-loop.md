---
title: "The propose loop"
weight: 1
---

{{< todo "prose" >}}

<!-- context. How work gets done at splashdown is one loop abstracted from three Fountain apps, Mend, Rounds and dns-desk. The apps differ on two axes, interactive or ambient and audit-driven or request-driven, and share everything else. -->

## The parts

| Part | What it is | Mend | Rounds | dns-desk |
|---|---|---|---|---|
| **target** | The thing under management. The agent does not control it and treats its contents as untrusted. | A repo's CI, Kubernetes, Docker and cloud config. | The same, enrolled. | The Cloudflare zones a token can see. |
| **read** | A deterministic read of the target. An audit yields findings sorted by fix confidence (deterministic, judgement, report-only). A request yields the current state, re-read before any apply. | `chant audit` over ten catalogs. Silent catalogs are shown greyed. | The same, on a schedule. | `dns-state`, incremental per zone. |
| **operator** | An agent on a toolkit environment with the tool on its PATH and a credential that can read the target and nothing more. One per target. | One mender per repo. A per-repo read-only token in its own vault. | The same, holding a grant it trades for a one-hour read-only token. | One desk per token. The vault's zone list is the blast radius. |
| **plan** | What the operator proposes per finding or per request. Applied means mechanical from the tool's own diff. Proposed means a judgement call it was confident in. Skipped means it turns on intent it cannot see, with a note. Rendered as a diff. | `mend-plan` plus one `mend-fix` block per fix, independently selectable. | One cluster per file, with status. | `dns-plan`, a diff against the last read. |
| **verify** | Re-run the read after the change and before proposing. Findings gone, merge-worthy count not up, files still parse. Or re-read the target and re-plan if it moved. | Before the plan is shown. | A failed verify opens nothing. | Re-read the zone before apply. Re-plan instead of applying stale. |
| **propose** | The only path that writes, held by something that is not the operator. | The human's browser with the human's token. Every context line re-verified against the target right now. | A server minting a one-target write token for one proposal, checking policy and history, rendering the PR body from the findings. | The desk applies after an `APPROVE plan-id` message, with a token scoped before the conversation began. |
| **rules** | Constraints that hold when the prompt is ignored, enforced where the write happens. | The browser refuses a stale patch. | Never reopen what a human closed. Never a second PR for the same thing. Never outside the derived branch. At most N open. `enabled: false` means nothing happens. | The token's scope. Today the approve is convention and the audit trail, until fountain#643. |
| **record** | Where the state lives. It is where the person who decides is already standing, with nothing to keep in sync. | The conversation. Report, plan and patch are derived from turns and blocks. | GitHub. Branch name and a marker in the PR body. The conversation holds the round report. | The conversation. Plan status is always derived, never stored. |
| **refusal** | An outcome, not a failure, rendered as one. | `skipped`, with the note. | `already-open`, `declined`, `deferred`, `clean`. A decline sticks until `rounds:reconsider`. | A request outside the token's zones. |

{{< todo "prose" >}}

<!-- context. Two invariants run through every column. The claim and the report are one copy. The operator never holds a write. -->

## The four forms

|  | audit-driven | request-driven |
|---|---|---|
| **interactive** | Mend. Point it at a target, watch, ask for changes, take the patch or open the PR yourself. | dns-desk. Ask in words, read the plan as a diff, approve, done. |
| **ambient** | Rounds. Schedule, reconcile against its own past work, cap, server as propose, declines stick. | A ticket webhook starting a desk conversation. No app yet. |

## The loop on IAM

{{< todo "prose" >}}

<!-- context. The applier is CloudFormation, never the agent. The desk proposes in repo mode and applies only in direct mode with a bounded role. See docs/aws-desk.md. IAM is a target that is also a repo, so propose is the PR in every form and approval is the merge, never an in-conversation message (decision 18). -->

| Form | IAM instance | Build or reuse | Lessons |
|---|---|---|---|
| interactive, request-driven | **The concierge**, in the desk's form. The estate on screen. "tickets-api needs read on the receipts bucket." One deterministic file edit. The plan is the rendered access delta. The PR is opened with a PR-only token. CODEOWNERS approve. The gated job applies. Refusals name the enrollment or escalation path. | Build. | I12 |
| ambient, audit-driven | **The watcher**, in Rounds' form. Unused-access findings and expiring grants on a schedule. One PR per finding, capped, declines stick. The drift reconcile runs under the same rules. | Rounds as-is for what its catalogs cover. IAM projections added. | I7, I13 |
| interactive, audit-driven | **Mend the access repo.** Point Mend at `splashdown/access`. The aws catalog reads the synthesized CloudFormation. | Mend as-is. | I3 |
| ambient, request-driven | A ticket that opens a desk conversation and tracks the PR as comments. | Later. | I12 |

{{< todo "prose" >}}

<!-- context. The parts, on IAM. -->

| Part | IAM at splashdown | Lessons |
|---|---|---|
| target | `splashdown/access` and the live estate it owns. A satellite repo. | I1, I8 |
| read | The guardrails, the drift watch, the Access Analyzer proofs, the unused-access and expiring-grant projections, and the estate view. | I3, I6, I7, I11 |
| operator | A teammate on the reference Environment with a checkout, SKILL.md and a code-host token that can open PRs and nothing else. No cloud credential. | I12, F4 |
| plan | The access delta rendered by the deterministic renderer, never the model. A directed refusal for a boundary exception or an unmapped requester. | I12, I14 |
| verify | The guardrails and a changeset against Floci on every PR with no credential. `check-no-new-access` where an untrusted author cannot trigger it. The digest re-checked at apply. | I4, I6, I14 |
| propose | The PR. Merge then apply by a gated job on a protected branch. The watcher's propose endpoint with cap and declined list. | I6, I13 |
| rules | Generated CODEOWNERS and branch protection. The apply role's own boundary. The satellite's `iam:PermissionsBoundary` condition. Rounds' rules on reconcile and watcher (decision 28). | I5, I6, I7, I8 |
| record | Git for blame, the PR and provenance by PR and sha. The conversation for the request. Reconcile state in the code host. | I6, I7, I12 |
| refusal | The guardrail in the editor. The double refusal. An unmapped identity with the enrollment path. A reconcile PR closed unmerged. | I3, I8, I12, I7 |

## What the loop asks of Fountain

{{< todo "prose" >}}

<!-- context. An environment with the tool preinstalled and no secrets (F1, F4). A vault per target bound at creation (F4). A teammate per target with a persistent computer (F5). A schedule for the ambient forms (F6). Protocol blocks and the conversation as record for the interactive forms (F7). A hosted sandbox provider wherever the operator reads untrusted input while holding anything (F10). No approval gate in the loop, which is why propose lives outside it (F11). -->
