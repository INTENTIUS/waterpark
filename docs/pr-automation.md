# Pull request automation

chant needs a first-class PR automation story. water park is its proving
ground. This doc studies the two prior arts, names the primitives, and maps
them onto what chant already has.

## Prior art

### Atlantis

A standing server wired to VCS webhooks. On PR open or push it locates the
changed Terraform projects, runs plan per project, and posts the output as
comments. `atlantis apply` in a comment applies from the PR, and merge
follows a successful apply. A lock table serializes PRs touching the same
project, because plans go stale against shared mutable state.

What it got right. Plan output on the PR where review happens. A uniform UX
across VCS providers. Autoplan scoped to what changed.

What it costs. You run and secure a credential-holding server. Locking
exists because Terraform state forced it. Scoping is file-path heuristics.
The comment-as-CLI is uniform only because the server abstracts every
platform down to its lowest common denominator.

### Pulumi

Two modes. CI-native: `pulumi/actions` runs preview inside the PR workflow
and maintains a sticky PR comment with the diff; apply runs on merge.
SaaS: Pulumi Deployments' Review Stacks spin up an ephemeral stack per PR
and destroy it on close. Gating leans on the CI's own primitives or Pulumi
Cloud approvals.

What it got right. No server for the common path — the CI's compute and
secret store do the work. Ephemeral per-PR environments. Sticky comments
that update per push instead of piling up.

What it costs. The GitHub action is first-class and everything else is
second-class. The preview is a text artifact, not typed data, so nothing
downstream can act on it.

### The per-CI reality

There is no uniform substrate. Each platform has different native
primitives, and a good story uses them instead of flattening them.

| Primitive | GitHub | GitLab | Forgejo |
|---|---|---|---|
| PR pipeline trigger | `pull_request` | MR pipelines | `pull_request` (Actions-compatible) |
| Present the plan | sticky comment + Check summary | native terraform MR widget | comment via API |
| Apply gate | environment + required reviewers | manual job + protected environment | protected branch + manual dispatch |
| Serialize applies | `concurrency:` group | `resource_group` | limited — freshness digest carries it |
| Comment commands | `issue_comment` workflow trigger | not idiomatic — the manual-job button is | `issue_comment`-style trigger |

## chant's position: compile the runner away

Atlantis is a server because Terraform pipelines were hand-written and
shared state needed a lock coordinator. chant compiles pipelines from the
component graph and has no state file. So PR automation should be a compile
target of the same generator, not a standing service. The per-CI differences
stop being a porting burden and become the serializer's job — one
declaration, three dialects, which is exactly what the CI lexicons are for.

## The five primitives

Every PR automation story reduces to five things. chant has most of them.

1. **Scope** — which components does this PR touch?
   `packages/core/src/lifecycle/affected.ts` diffs deterministic build
   artifacts between base and head, walks dependents, and reports
   deploy-time-input stacks as indeterminate. Better than Atlantis's path
   heuristics: a comment-only edit produces no artifact change and no plan.
2. **Plan** — what would change? `chant lifecycle plan` and the typed
   change set (create/update/delete/adopt/noop, ownership-aware). Typed
   data, not text, so everything downstream can act on it.
3. **Present** — show it on the PR. Per-CI adapters. GitLab ships today
   (`MrPlanReport` → the native MR widget via `--report gitlab-mr`).
   GitHub needs a sticky-comment + Check-summary composite and a
   `--report markdown` / `--report github-pr` renderer beside the gitlab
   one. Forgejo needs the comment adapter.
4. **Gate** — who may apply, when. Compiled to each platform's native
   primitive from one declaration. GitHub environments with required
   reviewers, GitLab manual jobs on protected environments, Forgejo
   protected branches plus dispatch.
5. **Serialize and freshness** — the Atlantis-lock analog, split in two.
   Concurrency: compile `concurrency:` groups / `resource_group` per
   component so applies never interleave. Staleness: record the change-set
   digest at plan time as an artifact; apply re-diffs and refuses if the
   live estate moved since. No lock server. The digest is the lock.

## Semantics chant can choose

**Merge-then-apply is the default.** It fits the gated deploy jobs the
generators already emit, and it keeps the audit trail on main. Atlantis's
apply-from-PR-then-merge can be an option later for orgs that want it — the
freshness digest is what makes it safe — but it is not the first target.

**Comment commands are per-platform idiom, not policy.** GitHub and Forgejo
get `/chant apply` via comment-triggered workflows, no server needed.
GitLab's idiom is the manual-job button on the MR pipeline. Don't force
uniformity; each dialect should feel native.

**Ephemeral PR instances come free.** The `{project}-{env}-{instance}-…`
naming scheme means `instance=pr-123` deploys alongside everything and
tears down on close — the Review Stacks analog with no SaaS. And chant has
one capability neither prior art has: emulator-backed PR validation. A PR
pipeline can take every stack to CREATE_COMPLETE against Floci with zero
cloud credentials in the PR context.

## Ops and lifecycle in the PR loop

Synthesis-first is the right frame, but chant is not only synthesis. Ops
and lifecycles are part of the PR story in four places, and this is where
chant leaves both prior arts behind — Atlantis and Pulumi automate a
stateless plan/apply; chant can put a durable workflow behind the merge
button.

**PRs that change Ops.** A PR editing `ops/*.op.ts` needs a plan too. Diff
the compiled Op manifest between base and head and present it as steps,
gates, schedules, and compensations added or removed. This is
security-critical rendering in water park: a PR that removes an approval
gate from the break-glass Op or lengthens its TTL must render loudly, not
as a TypeScript diff. Gate and compensation removals are high-severity by
default.

**Apply as a durable Op.** The generated apply job doesn't have to run the
apply in the CI runner. It can start (or attach to) an ApplyOp and stream
status back to the PR check. That gives the apply what a CI job can't:
survival across runner death, saga compensation on partial failure, and a
durable approval gate. Which raises the gate-ownership question — CI
environment approval or Temporal signal? For security-grade applies the
gate belongs in the Op, because it survives infrastructure failure and
leaves a workflow-history audit trail; the CI approval is then a forwarder
that sends the signal. For routine applies the CI gate alone is fine. One
declaration, `gate: 'ci' | 'op'`, compiled accordingly.

**Reconcile PRs are participants, not noise.** water park's reconcile Op
authors cloud-to-code PRs. The PR automation must treat them as first-class:
auto-plan them like any PR, and render their expected shape — a reconcile
PR should plan to noop-after-merge (it adopts live reality). The flip side
is drift-awareness on human PRs. The plan is a three-way comparison chant
already computes (declared-in-PR / declared-on-main / live), so a feature
PR's plan can say "2 changes from this PR, 1 pre-existing drift item,
reconcile PR #12 pending" instead of silently folding drift into the diff.
Atlantis cannot do this — it has a state file, chant has live truth. When
the estate moves, open plans go stale together; the freshness digest
catches it at apply, and a re-plan refreshes both kinds of PR.

**Ledger and provenance close the loop.** Merge + apply writes the
build/release ledger keyed by PR and sha, and the PR gets the applied
confirmation with provenance. The PR is then not just reviewed intent but
a traceable release record — the audit trail waterpark's access reviews
read from.

## What lands where

**chant core.** Renderer family over the change set (`markdown`,
`github-pr` beside `gitlab-mr`). Plan-digest record + `--require-fresh`
verification on apply. `affected` wired into the generated PR jobs.

**CI lexicons.** A `pullRequests` option on `generateComponentPipeline`
in all three, emitting the plan-on-PR jobs, the present adapter, the gate,
and the concurrency primitive for that platform. A GitHub `PrPlanComment`
composite (peer of gitlab's `MrPlanReport`) and a Forgejo equivalent.

**water park.** The implementation. PR opens → affected scoping →
credential-free Floci validation → lint (guardrails fail before review) →
plan presented per platform → CODEOWNERS routes → approval gate → merge →
gated apply from main with the freshness digest → the drift watch keeps it
true afterward.

Plus the one layer only water park can add: **semantic rendering.** An IAM
change set rendered as access deltas — "grants s3:GetObject on bucket X to
team payments" — instead of a JSON diff. Generic tools can't do this; a
typed graph can. For security review this is the difference between a
rubber stamp and an informed approval.

**Explicitly deferred.** A standing chant runner. If the compiled story
leaves gaps (cross-repo orchestration, richer interactivity), the
requirements accumulate in C5 and get filed on chant when concrete.

## Draft chant-side epic (to file on chant, not here)

1. Change-set renderers: `markdown`, `github-pr` (peer of `gitlab-mr`).
2. Plan-digest record at plan, `--require-fresh` refusal at apply.
3. github lexicon: `PrPlanComment` composite (sticky comment + Check).
4. forgejo lexicon: PR comment adapter composite.
5. `pullRequests` option in all three `generateComponentPipeline`s —
   plan jobs scoped by `affected`, present adapter, native gate,
   concurrency primitive.
6. Comment-command recipe (github/forgejo) — generated
   `issue_comment` workflow calling `chant run`, gated.
7. Ephemeral instance recipe — `instance=pr-<n>` up on open, down on
   close, documented against Floci and real accounts.
8. Lint rule packages — config-declared rule sources so a dependency can
   ship guardrail rules; today only a walked-up `.chant/rules/` dir loads
   (`packages/core/src/lint/rule-loader.ts`). Unblocks the org context
   package without re-export shims.
9. Op-manifest diff — compare compiled Op definitions base vs head, render
   steps/gates/schedules/compensations changed; gate and compensation
   removals flagged high-severity.
10. Op-backed apply — generated apply job starts/attaches to an ApplyOp,
    streams status to the PR check; `gate: 'ci' | 'op'` compiled per
    component, CI approval forwarding the Temporal signal in `'op'` mode.
11. Drift-aware PR plan — surface the three-way split (this PR / main /
    live) with pre-existing drift and pending reconcile PRs annotated
    separately from the PR's own changes.
12. Apply provenance on the PR — merge + apply records to the release
    ledger keyed by PR/sha and posts the applied confirmation back.

Ordering: 1–2 unblock everything; 3–5 are the visible story; 6–12 are
follow-ons, with 9 pulled early for water park (Op diffs are security
review). water park adopts each as it lands (Track C).
