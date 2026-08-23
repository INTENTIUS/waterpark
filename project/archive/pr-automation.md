chant needs a first-class PR automation story; water park is its proving
ground. This doc studies the prior art, names the primitives, and pins
what the reviewer actually approves.

## Prior art

**Atlantis:** a standing credential-holding server wired to VCS
webhooks — plan as comments, apply from the PR, a lock table because
plans go stale against shared state. Got right: plan output where review
happens. **Pulumi:** CI-native previews with sticky comments, apply on
merge, ephemeral Review Stacks. Got right: no server for the common
path. Costs both share: GitHub-first with everything else second-class,
and a preview that is text, not typed data, so nothing downstream can
act on it.

**The per-CI reality.** No uniform substrate; a good story uses each
platform's native primitives:

| Primitive | GitHub | GitLab | Forgejo |
|---|---|---|---|
| PR pipeline trigger | `pull_request` | MR pipelines | `pull_request` |
| Present the plan | sticky comment + Check | native MR widget | comment via API |
| Apply gate | environment + required reviewers | manual job + protected env | protected branch + dispatch |
| Serialize applies | `concurrency:` group | `resource_group` | freshness digest carries it |

## chant's position: compile the runner away

Atlantis is a server because Terraform pipelines were hand-written and
shared state needed a lock coordinator. chant compiles pipelines from
the component graph and has no state file, so PR automation is a compile
target of the same generator, not a standing service. The per-CI
differences become the serializer's job — one declaration, three
dialects.

## The five primitives

1. **Scope** — which components does this PR touch? `affected.ts` diffs
   deterministic build artifacts and walks dependents; a comment-only
   edit produces no plan.
2. **Plan** — the typed change set (create/update/delete/adopt/noop,
   ownership-aware). Typed data, not text.
3. **Present** — show it on the PR, per-CI adapters (GitLab's
   `MrPlanReport` ships today).
4. **Gate** — who may apply, when; compiled to each platform's native
   primitive.
5. **Serialize and freshness** — compiled concurrency groups so applies
   never interleave, and a change-set digest recorded at plan that
   apply re-checks, refusing if the estate moved. The digest is the
   lock; no lock server.

## The manifest is what gets approved (decisions 23, 24)

Intent compiles to source deterministically, so the source diff is a
build artifact and the wrong altitude for security review. The reviewable
object is the **manifest**: the typed change set, rendered as the
semantic access delta ("grants `s3:GetObject` on `splashdown-receipts` to
`tickets-api`, expires 2026-11-01"), with proof verdicts and Op-manifest
diffs beside it.

Approval binds to the manifest's digest, not the source sha. Apply
recompiles, re-diffs against live, and refuses if either diverges from
what was approved — the freshness check from primitive 5, promoted from
staleness guard to the definition of consent. The PR remains the
envelope: it supplies authority (code-host review, CODEOWNERS, branch
protection) and the durable record, which no manifest ledger should try
to rebuild. The manifest is never the system of record (decision 2).

The binding mechanics: the plan job records the manifest digest beside
the rendering it posts at a given sha; the code host's stale-approval
dismissal is the native guard for push-after-approval; and apply
recomputes the manifest and compares digests, which catches both estate
movement and a synth-output change between approval and apply (a
lexicon bump on unchanged source — the exact case decision 24 exists
for). chant epic item 2 carries the record/refuse half; C4 wires the
comparison into the pipelines.

The manifest is also the cross-backend layer. chant emits it natively;
Terraform's plan JSON normalizes into the same schema (the parked
manifest-schema unknown, issues.md E1),
so review, evidence, and the access-review artifact are backend-blind
while lint, synthesis, and drift mechanics stay per-backend.

## Semantics

**Merge-then-apply is the default** (decision 6); apply-from-PR is a
later option the freshness digest makes safe. **Comment commands are
per-platform idiom, not policy** — GitHub/Forgejo get comment-triggered
workflows, GitLab's idiom is the manual-job button. **Ephemeral PR
instances come free**: `instance=pr-123` deploys alongside everything
and tears down on close, and Floci-backed validation takes every stack
to CREATE_COMPLETE with zero cloud credentials in the PR context.

## Ops and lifecycle in the PR loop

**PRs that change Ops.** Diff the compiled Op manifest between base and
head; a PR removing an approval gate from the break-glass Op must render
loudly, never as a TypeScript diff. Gate and compensation removals are
high-severity by default.

**Apply as a durable Op.** The generated apply job can attach to an
ApplyOp and stream status to the PR check: survival across runner death,
saga compensation, a durable gate. One declaration, `gate: 'ci' | 'op'` —
security-grade applies gate in the Op, with CI approval forwarding the
signal.

**Reconcile PRs are participants.** Auto-plan them (they should plan to
noop-after-merge), and make human PRs drift-aware: the three-way
comparison (declared-in-PR / declared-on-main / live) lets a plan say
"2 changes from this PR, 1 pre-existing drift item" instead of silently
folding drift in.

**Ledger and provenance.** Merge + apply writes the release ledger keyed
by PR and sha — the audit trail the access reviews read from.

## What lands where

**chant core:** change-set renderers (`markdown`, `github-pr`);
plan-digest record + `--require-fresh`; `affected` in generated PR
jobs. **CI lexicons:** a `pullRequests` generator option per platform.
**water park:** the implementation — PR opens → affected scoping →
credential-free Floci validation → lint → manifest presented →
CODEOWNERS → gate → merge → gated apply with the digest → drift watch.
Plus the layer only water park can add: the semantic access delta, the
difference between a rubber stamp and an informed approval.

## Draft chant-side epic

1. Change-set renderers: `markdown`, `github-pr`.
2. Plan-digest record at plan, `--require-fresh` refusal at apply.
3–5. Per-platform present composites + `pullRequests` generator option
   (*opportunistic* — the agent is a universal present adapter).
6. ~~Comment-command recipe~~ (dropped — see below).
7. Ephemeral instance recipe. 8. Lint rule packages.
9. Op-manifest diff (gate/compensation removals high-severity).
10. Op-backed apply (`gate: 'ci' | 'op'`).
11. Drift-aware PR plan (three-way split).
12. Apply provenance on the PR.

**Status, 2026-08-21 (chant 0.44.14).** None has landed except GitLab's
`MrPlanReport`. `plan --json` improvements and lexicon-version stamping
make items 1–2 cheaper than when drafted. Lesson I14 waits on 1, 2 and
9; nothing else in the course does. Two living instances of *present*
and *gate* exist outside chant: Mend renders the plan and opens the PR
from the browser; Rounds' server renders the PR body from the findings
and is the gate (decision 30).

## What the agent changes, and what it cannot

Scope is determinism, plan is evidence, gate is authority, freshness is
correctness — an agent substitutes for none of them. Present is where
substitution is real: items 3–5 exist to render one plan into three
comment dialects, and an agent holding the host's API is a universal
present adapter, so they are opportunistic and item 6 is obsoleted
outright. The exception is the one rendering that is a fact: the
semantic access delta is what a reviewer approves a grant on, so
decision 14 forbids it being model output — the renderer stays
deterministic and the agent layers English, context, and Q&A on top.

One counterweight: an agent degrades to nothing when the inference
provider is down; a deterministic renderer degrades to plain text. For
the write path to org IAM, the floor cannot be "the model was
available."

Revised priority: items 1, 2, and 9 are the spine — evidence,
correctness, and security rendering, together the manifest of decision
24. Everything else is opportunistic or accumulates in C5.
