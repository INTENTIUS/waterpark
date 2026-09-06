---
title: "Decisions"
---

Pinned so they don't get re-litigated. Each links to the doc that argues
it. Reversing one requires editing this file in the same PR.

1. **The write path is always the PR.** No write GUI, ever. Browsing goes
   to behold over the graph. ([plan](https://github.com/INTENTIUS/waterpark/blob/main/project/plan.md), [positioning](https://github.com/INTENTIUS/waterpark/blob/main/project/archive/positioning.md))
2. **No new format.** Declared source in, native artifacts out, so the
   estate outlives the toolchain. The anti-IAMbic clause. On Terraform
   the native artifact is HCL the provider applies directly, and the
   state file is bookkeeping, never the system of record (decision 32). ([landscape](https://github.com/INTENTIUS/waterpark/blob/main/project/archive/landscape.md))
3. **Manages what it declares, audits what it owns.** Not a CSPM, not a
   CIEM. Estate-wide scanning belongs to an auditor like Prowler. Chat intake is
   not a JIT catalog. A JIT product grants on approval, water park's
   concierge produces a diff a human merges (decision 18).
   ([positioning](https://github.com/INTENTIUS/waterpark/blob/main/project/archive/positioning.md), [landscape](https://github.com/INTENTIUS/waterpark/blob/main/project/archive/landscape.md))
4. **AWS is the wedge; cross-cloud is act two.** Track B is needs-design
   until persona equivalence is solved. ([plan](https://github.com/INTENTIUS/waterpark/blob/main/project/plan.md))
5. **Humans get permission sets, workloads get roles.** No IAM users, no
   IAM groups. ([landscape](https://github.com/INTENTIUS/waterpark/blob/main/project/archive/landscape.md), [design/personas](design/personas.md))
6. **Merge-then-apply is the default.** Apply-from-PR is a later option
   behind the freshness digest. ([pr-automation](https://github.com/INTENTIUS/waterpark/blob/main/project/archive/pr-automation.md))
7. **PR automation is compiled, not served.** A compile target of the CI
   generators; a standing runner is deferred to requirements capture (C5).
   ([pr-automation](https://github.com/INTENTIUS/waterpark/blob/main/project/archive/pr-automation.md))
8. **Break-glass expiry is cloud-side.** Temporal being down can delay
   cleanup, never extend access. TEAM interop documented, not replaced.
   ([design/break-glass](design/break-glass.md))
9. **Guardrails roll out warn-minor / error-major with ratchet
   baselines.** An upgrade cannot break a satellite without a warn cycle.
   ([design/guardrail-rollout](design/guardrail-rollout.md))
10. **The shared module is the delegation contract.** The guardrail
    checks, the boundary ARN and the `workload_role` module live in one
    versioned module a satellite consumes from its first file. Built in
    lesson I8 (amended under decision 26, it ships with the lesson, not
    "from the start" of a kit).
    ([plan](https://github.com/INTENTIUS/waterpark/blob/main/project/plan.md), [IAM, lesson 8](../courses/iam/08-delegation-and-the-double-refusal.md))
11. **Account vending is out of scope.** water park references accounts
    (registry, reference-existing); Control Tower / org-formation vend
    them. ([design/multi-account](design/multi-account.md))
12. **The apply credential is bounded.** water park must not be able to
    escalate water park; the apply role carries its own permission
    boundary. ([threat-model](threat-model.md))
13. **Federation trust is estate; the issuer is not.** water park declares
    OIDC/SPIFFE/Roles-Anywhere trust anchors as code with the strictest
    lint and drift severity, and never operates an identity issuer.
    ([design/workload-identity](design/workload-identity.md))
14. **Agents propose; they never approve, apply, or signal.** The agent
    is an untrusted author whose PRs are verified identically to human
    PRs. Trust attaches to the compiled checks, never to the author.
    ([design/agentic](design/agentic.md))
15. **The sandbox is never a principal.** An untrusted agent sandbox
    holds no cloud credentials and is never a federation subject.
    Identity attaches to the verb service outside the sandbox boundary;
    the sandbox receives only a conversation-scoped verb-API token.
    ([design/agentic](design/agentic.md),
    [design/workload-identity](design/workload-identity.md))
16. **water park owns the AWS governance reconcile, or nobody does.**
    The prior art here is chant's archived `aws-warden`, which covered
    the OU tree, SCPs, Identity Center, the org trail and a protected
    break-glass. It is adopted on water park's terms, which means
    declared source instead of a YAML tree and the PR as the write path,
    with the cycle design and guardrail set taken verbatim.
    ([upstream.md](https://github.com/INTENTIUS/waterpark/blob/main/project/upstream.md))
17. **The requester's identity is declared, never asserted.** A chat or
    intake identity earns standing only by appearing in a principal's
    leaf file under the repo's own review. An unmapped identity gets a
    refusal carrying the enrollment path, never a PR. Until the intake
    runtime attests the requesting author, the requester is rendered on
    the PR as an unverified claim, in those words.
    ([design/agentic](design/agentic.md))
18. **Chat is intake and notification; it is never an approval surface.**
    No approve button in a channel, no gate a message can satisfy, no Op
    a reply can signal. Decision 14's corollary, pinned separately
    because a chat front-end is exactly where someone will later propose
    one. ([design/agentic](design/agentic.md))
19. **One estate: AWS IAM, plus the code host's own protection.**
    Application-level authorization is out of scope. The code-host
    resources that guard the repo — branch protection, CODEOWNERS — are
    declared and drift-watched because merge rights are grant rights
    (principle 6, threat-model boundary 1); that is the repo protecting
    itself, not a second estate. Cross-cloud legs (Track B) stay parked.
    ([plan](https://github.com/INTENTIUS/waterpark/blob/main/project/plan.md), [threat-model](threat-model.md))
20. **Satellites create roles; the boundary is what makes that safe.** A
    satellite declares its own workload roles inside a permission boundary
    the central repo owns, enforced by lint at build and by the
    `iam:PermissionsBoundary` condition at apply. Central keeps personas,
    the boundary, and the guardrails.
    ([design/delegation](design/delegation.md))
21. **CODEOWNERS is generated, not authored.** The routing is derived from
    the principal files it routes, emitted, and drift-watched. Rerouting
    review of a team's access is a visible diff, never a quiet dotfile
    edit. ([threat-model](threat-model.md))
22. **A live proof never runs in a job an untrusted author can trigger.**
    PR-time validation is credential-free — Floci plus the full lint pack.
    Access Analyzer proofs run post-merge-queue or behind a
    maintainer-applied label. Applies to fork PRs and agent-authored PRs
    identically. ([threat-model](threat-model.md))
23. **The pattern is backend-blind; the course picks one.** water park is
    a way of holding access, not a tool. Terraform and OpenTofu are what
    the course teaches (decision 31), and chant is a typed backend the
    design docs describe. What makes them interchangeable is the change
    manifest, the plan reduced to a common shape, which is the review,
    evidence and access-review object everywhere. Everything
    backend-specific stays behind it.
    ([plan](https://github.com/INTENTIUS/waterpark/blob/main/project/plan.md), [pr-automation](https://github.com/INTENTIUS/waterpark/blob/main/project/archive/pr-automation.md))
24. **Approval binds to the manifest, and the PR is the envelope.** A
    reviewer approves the rendered change manifest identified by its
    digest, and apply refuses when the replanned manifest or the live
    estate has moved. On Terraform the saved plan file is that object and
    the refusal is native, since a saved plan will not apply against
    state it no longer matches. The manifest is never the system of
    record, declared source in git is (decision 2). Extends decision 6.
    ([pr-automation](https://github.com/INTENTIUS/waterpark/blob/main/project/archive/pr-automation.md))
25. **The IAM kit is the IAM scenario's backlog.** Superseded in framing
    by decision 26: the kit is neither a product nor parked; tracks A–E
    are the source material for lessons I1–I15 and IA, mapped in
    [issues.md](https://github.com/INTENTIUS/waterpark/blob/main/project/archive/issues.md). Nothing there is "parked" except Track B and
    the org-layer reconcile, which are appendix lessons.
    ([plan](https://github.com/INTENTIUS/waterpark/blob/main/project/plan.md), [issues](https://github.com/INTENTIUS/waterpark/blob/main/project/archive/issues.md))
26. **water park is an IAM project repo that comes with courses; the
    courses are about the Accessible Ops properties.** Two courses, each
    lesson naming the properties it demonstrates: course 1 is Fountain
    (the agent side, built up to the propose loop abstracted from Mend,
    Rounds and dns-desk); course 2 is the IAM repo, where the agent goes
    to work. The IAM scenario is the worked example because it exercises
    both vehicles and most of the properties; it need not cover every
    one. Each lesson is a card, an optional video, one activity; it runs
    self-paced or live. No onboarding metaphor; titles are plain.
    ([plan](https://github.com/INTENTIUS/waterpark/blob/main/project/plan.md), [page model](https://github.com/INTENTIUS/waterpark/blob/main/project/page-model.md))
27. **Solo is Floci; live is real.** The free path deploys to Floci and
    says per lesson what Floci cannot show (Organizations, Identity
    Center, Access Analyzer; `iam:PermissionsBoundary` enforcement
    unverified). A facilitated session uses real sandbox accounts, real
    zones, real repos, from checkpoints. ([demo](demo.md))
28. **Drift reconcile follows Rounds' rules.** One PR per owned resource
    on a derived branch with a marker in the body; the PR restores the
    declared state; an operator who wants the change kept edits the PR
    to declare it; closing unmerged is a no for that finding until
    relabeled; a capped number open at once; never a PR for a foreign
    resource; state lives in the code host. The same rules govern the
    watcher (I13). ([IAM, lesson 7](../courses/iam/07-drift.md), Rounds README)
29. **Containment claims need a hosted sandbox provider.** The
    self-hosted runner is trusted mode: no isolation, no egress policy
    (Fountain ADR 0022). Any lesson that says "default-deny egress" or
    "no credentials can leave" runs on Sprites, E2B or Daytona; on a
    runner the lesson says so. ([Fountain, lesson 10](../courses/fountain/10-self-hosted-runner.md))
30. **The verb service is a server with policy; Mend, Rounds and dns-desk
    are the reference implementations.** Decision 15's "verb service outside the sandbox"
    is Rounds' server: the agent holds a read-only grant, the server
    holds the write credential for one target for one proposal, enforces
    the rules the prompt cannot, and renders the PR body from the same
    objects it reports. Where a human is present, Mend's form (the PR
    opened from the human's browser with the human's token) is enough.
    No verb service is built ahead of need.
    ([propose loop](../propose-loop.md), [Fountain, lesson 8](../courses/fountain/08-propose-loop-interactive.md),
    [Fountain, lesson 9](../courses/fountain/09-propose-loop-ambient.md), [design/agentic](design/agentic.md))
31. **The course runs on Fountain and Terraform.** water park is a GitOps
    pattern, not a toolchain. Any agent runtime and any declarative
    applier can drive it, and naming the pair is a course decision rather
    than a property of the pattern. This course pairs Fountain with
    Terraform because both run free on a laptop and Terraform is where
    most orgs already are. The repo is one resource per `.tf` file and the
    directory is the module, so nothing assembles anything. `terraform
    plan` is the plan, `terraform apply` in a gated job is the only write,
    `plan -detailed-exitcode` is the drift watch, `import` blocks are
    adopt-in-place, `terraform validate` and `tflint` are the editor
    check, and Access Analyzer `validate-policy` and `check-no-new-access`
    are the proofs, since those are cloud APIs and not part of any
    toolchain. The agent app is [the AWS desk](aws-desk.md), where direct
    mode is dns-desk's posture and repo mode is the course's. chant
    remains a backend the design docs describe (decision 23) and is not
    taught. Replacing either half is an edit to this decision.
    ([aws-desk](aws-desk.md), [plan](https://github.com/INTENTIUS/waterpark/blob/main/project/plan.md))
32. **The state file is a cost the course names out loud.** Accessible Ops
    XI says the live system is the truth and warns about a tool that hosts
    its own state. Terraform hosts one, and water park does not pretend
    otherwise. The mitigations are that state lives in
    `waterpark-security` with locking and is never the system of record
    (decision 2), that every read of the estate in these lessons goes to
    the cloud rather than to state, and that the drift watch compares
    declared against live. Lesson I4 teaches the cost and lesson I7
    teaches the mitigation. A backend without a state file scores better
    on this property and the course says so rather than hiding it.
    ([IAM, lesson 4](../courses/iam/04-deploy-to-floci.md), [IAM, lesson 7](../courses/iam/07-drift.md))
33. **The access repo is this repo.** The Terraform the IAM course builds,
    which is the `envs/<env>/` layout, the baseline module, the shared
    `workload_role` module, the tflint rule pack, `proofs` and
    `render-delta`, the apply workflow and the Floci local path, lands in
    this checkout beside `content/` and `skills/` rather than in a sibling
    repo. [The estate](estate.md) already says the repo a student clones is
    the repo the course puts under management, and one clone, one PR flow
    and one CI keep that literal. The HCL root is a top-level `access/`
    directory, so every path a lesson gives starts `access/envs/<env>/`.
    The cost is named out loud. The site repo carries a state backend
    config, an OIDC apply workflow and CODEOWNERS gating `.tf` files, so
    course PRs and access PRs share one review queue. Lesson checkpoints
    are git tags here.
    ([estate](estate.md), [aws-desk](aws-desk.md), [plan](https://github.com/INTENTIUS/waterpark/blob/main/project/plan.md))
34. **The desk edits directly, and there is no `scripts/request`.** In repo
    mode the desk locates the file by convention, makes the one edit
    itself, then runs `terraform validate`, `tflint`, `proofs`, `terraform
    plan` and `render-delta`, and opens the PR. The domain-verb idea in
    [design/agentic](design/agentic.md) keeps its read side, which is
    `access/scripts/whocan`, `access/scripts/expiring` and
    `access/scripts/offboard --preview`, and it keeps its refusals. The
    write side is dropped, so no script authors the edit on the agent's
    behalf. The trade is stated rather than hidden. Two identical requests
    may produce two different diffs, and the guardrails and the rendered
    delta carry the weight a deterministic authoring script would have
    carried. Prescription 13's check moves with it and now asks whether a
    human making the same edit by hand lands in the same jobs and the same
    rendered delta.
    ([aws-desk](aws-desk.md), [design/agentic](design/agentic.md), [prescriptions](prescriptions.md))
35. **Approve the change, not the diff, is prescription 14.** The saved
    plan is the manifest, `terraform show -json` renders the typed changes,
    the apply job refuses a plan whose digest does not match what was
    approved, and the PR shows the semantic access delta, meaning the
    grants added and removed by principal and by resource. Decisions 24 and
    31 already say most of this. P14 promotes it to a checkable
    prescription, closed by lesson I14, whose check is that an apply
    against a stale or altered plan fails and the PR comment names the
    grants added and removed. I14 previously claimed P3, which belongs to
    I2 and I7.
    ([prescriptions](prescriptions.md), [IAM, lesson 14](../courses/iam/14-approve-the-change-not-the-diff.md))
36. **One permissions boundary for the whole estate.** It lives in
    `access/baseline/` as an `aws_iam_policy` and it denies all IAM
    write, Organizations and Identity Center, the guardrail-path
    resources by name, and boundary detachment, while allowing the
    service surface an app team plausibly needs. That is the lean the
    delegation note carried, adopted as written. Splitting per OU is
    deferred until an OU needs it. The Sandbox OU carries no boundary at
    all, because sandboxes exist to be broken and the live session guide
    has the room break things there. `deployer` is not delegable, so a
    satellite creates only `service` roles. The cost is that the
    boundary becomes the most-revised object in the baseline, and
    tightening it can break an existing role at apply time where lint
    will not catch it, so guardrail-rollout's warn discipline applies.
    Settles delegation items 1, 2, 4 and 5.
    ([design/delegation](design/delegation.md), [IAM, lesson 5](../courses/iam/05-the-permission-boundary.md), [demo](demo.md))
37. **Break-glass is a temporary Identity Center assignment carrying a
    time condition.** The assignment's policy carries an
    `aws:CurrentTime` condition, so the cloud ends the access even if
    every job dies. Max TTL is two hours, held in `access/baseline/` as
    a constant, and a tflint rule refuses a longer one. The approver is
    the reviewer of the break-glass PR, and the apply job copies that
    identity into the grant's tags, so the approval and the artifact
    name the same human. With the code host down the fallback is a CLI
    confirmation by a second human, as the break-glass note already
    documents. The cost is that Floci cannot run Identity Center, so the
    self-paced path uses the time-conditioned policy on a role and the
    page says so. Settles break-glass items 1, 2, 3 and 5. Item 4, TEAM
    interop, stays open.
    ([design/break-glass](design/break-glass.md), [IAM, lesson 10](../courses/iam/10-break-glass.md))
38. **Adopt in place is import from live, one resource at a time.** The
    documented first path for an existing estate is an `import` block
    per resource, `terraform plan -generate-config-out` reviewed by hand
    into the one-file-per-resource layout, and a plan that proves
    nothing changes on day one, with a `removed` block to back out.
    Greenfield is the course's own path and needs no adoption story.
    Carve was chant-only (decision 23). Bulk import is not the
    documented path, because water park manages what it declares
    (decision 3, Accessible Ops XIII) and a bulk import declares a pile
    nobody has read. The old export-bundle criterion is moot now that
    the HCL is the artifact, and decision 2 stands. The cost is that
    adoption is slow by design and a large estate takes many PRs.
    ([IAM, lesson 15](../courses/iam/15-adopt-in-place.md))
39. **Workloads federate through declared OIDC providers.** The trust
    anchors are `aws_iam_openid_connect_provider` entries under
    `access/identity/`, issuer and audience pinned, no wildcard `sub`
    claim. Roles Anywhere gets one paragraph as the option for a fleet
    with an existing PKI, and nothing more. The rotation check for the
    few remaining static secrets runs on the same weekday schedule as
    the watch, so one cron drives both and lesson I13 teaches the
    schedule once. The cost is that an org whose workloads sit outside a
    CI or a cluster reads that one paragraph and builds the rest itself.
    Settles workload-identity item 4 and the rotation cadence.
    ([design/workload-identity](design/workload-identity.md), [IAM, lesson 9](../courses/iam/09-federation-trust.md))
40. **The watcher holds at most five open PRs.** The watcher's prompt
    says so, and the credential-free PR job counts open PRs carrying the
    desk marker and fails a sixth, so the cap holds when the prompt is
    ignored. No propose endpoint is built, because a job that already
    reads the code host can do the counting. Five is a constant in
    `access/baseline/` so lesson I13 can show a student changing it. The
    cost is that a real backlog takes several cycles to clear and the
    sixth finding waits.
    ([aws-desk](aws-desk.md), [design/agentic](design/agentic.md), [IAM, lesson 13](../courses/iam/13-the-watcher.md))
41. **The persona set is four, and it is closed.** The personas are
    `reader`, `deployer`, `service`, and the `platform` persona that
    owns the guardrail path. That is what this estate needs, and adding
    one is a module release rather than a leaf-file edit. Team scoping
    is module parameters. There is no standing admin, because
    permissions management always goes through the repo. The three-org
    survey is dropped as out of scope for a course whose estate is one
    small org, and the personas note says in one sentence that a larger
    org would revisit the set. Cross-cloud equivalence stays parked with
    Track B (decision 19). The cost is that a reader running a
    centralized enterprise gets a set that was never tested against one.
    Settles personas items 1, 2 and 3.
    ([design/personas](design/personas.md), [estate](estate.md), [IAM, lesson 2](../courses/iam/02-personas-and-principals.md))
42. **The access review reads live, never a satellite's HCL.** It reads
    the live account through `get-role`,
    `list-attached-role-policies` and Access Analyzer unused-access
    findings, so anything a satellite created appears regardless of
    which repo declared it. That closes the cross-repo reachability
    question by not needing an answer to it, which retires delegation
    item 3 and the archive's C1 and C6 unknown for this course. The
    read-only queries, `whocan`, `expiring` and `offboard --preview`,
    stay scripts under `access/scripts/` that the desk's estate pane
    calls, so there is no separate Q&A page. The cost is that the review
    is only as current as its last read and it says nothing about a
    resource nobody has permission to read. Lessons I11 and I8.
    ([design/delegation](design/delegation.md), [design/agentic](design/agentic.md), [IAM, lesson 11](../courses/iam/11-offboard-and-access-review.md))
43. **The local backend is the default, and the S3 backend swaps in for
    the live path.** `access/envs/prod/backend.local.tf` is checked in so
    a fresh clone inits with zero AWS. `access/backends/backend.s3.tf`
    (state in waterpark-security, encrypted, with `use_lockfile`) is
    copied in by `access/scripts/backend s3 envs/prod`. Terraform allows
    one backend block per root, and `-backend-config` cannot change the
    backend type, so a file swap is the only clean mechanism. The `floci`
    provider variable defaults to true for the same reason, the taught
    path is the default posture, and the live path passes `-var
    floci=false`. The provider lock file is gitignored because students
    run this on three platforms. The cost is that the live path is two
    commands further from the clone than the local one.
    ([access](https://github.com/INTENTIUS/waterpark/blob/main/access/README.md), [IAM, lesson 4](../courses/iam/04-deploy-to-floci.md))
44. **Human principals are live only, under `access/identity/`.** Floci
    runs no Identity Center, so permission sets and assignments cannot
    apply on the solo path. The persona module refuses a human persona in
    any root that has not set `identity_center = true`, and that refusal
    fires at plan time because Terraform defers cross-variable
    validation, while a wrong persona name fails at validate. `identity/`
    is validated and linted on every check and never applied on a laptop.
    File names strip the provider prefix from the real type, so
    `ssoadmin_permission_set.<name>.tf`, not the `sso_permission_set` the
    desk doc sketched, now fixed there too.
    ([access/identity](https://github.com/INTENTIUS/waterpark/blob/main/access/identity/README.md), [aws-desk](aws-desk.md), [IAM, lesson 2](../courses/iam/02-personas-and-principals.md))
45. **Grant policies are rendered by the persona module, not written as
    leaf files.** A principal file is one module call plus a list of
    grants (prescription 2). Lesson I1 still builds the raw role, policy
    and attachment as three files so the student sees what the module
    replaces in I2, which is why a policy leaf file exists at
    checkpoint/i1 and not after, and the desk doc's sketch of a permanent
    one is fixed to match. The module exports a `grants` output carrying
    expiry so a later proofs script has something to read.
    ([access/modules/persona](https://github.com/INTENTIUS/waterpark/blob/main/access/modules/persona/README.md), [aws-desk](aws-desk.md), [IAM, lesson 1](../courses/iam/01-one-type-per-file.md), [IAM, lesson 2](../courses/iam/02-personas-and-principals.md))
46. **Leaf files name the boundary once, as `permissions_boundary =
    module.baseline.boundary_arn`.** Issue 43 wanted leaf files silent
    about the boundary. With baseline as a module in the same root, that
    one reference is the dependency edge that orders the policy before
    the roles. The alternatives were a second apply with baseline as its
    own root, or a data-source lookup that fails on first apply. The
    module still applies the boundary, so no grant restates it. The
    boundary policy itself is tagged `guardrail = "boundary"`, and
    `no-wildcard-action` exempts it, because a boundary is a ceiling that
    needs `s3:*`-shaped allows, not a grant.
    ([access/baseline](https://github.com/INTENTIUS/waterpark/blob/main/access/baseline/README.md), [design/delegation](design/delegation.md), [IAM, lesson 5](../courses/iam/05-the-permission-boundary.md))
47. **The rule pack is tflint with the OPA ruleset, Rego under
    `access/.tflint.d/policies/`, and severity is the function-name
    prefix.** `deny_` is an error and `warn_` a warning, so promoting a
    rule (decision 9's warning-first rollout) is a one-word edit plus a
    line in `access/scripts/check`. All nine rules are Rego, including
    the two layout rules, because the ruleset exposes each resource's
    file name. `no-open-ingress` and `sg-reference-not-cidr` ship as
    warnings with fixtures although the estate declares no security
    groups yet. tflint installs from the tap
    `terraform-linters/tap/tflint`, not homebrew core. The editor half of
    prescription 4 is documented rather than demonstrated, since `tflint
    --langserver` is a process apart from `terraform-ls`.
    ([access](https://github.com/INTENTIUS/waterpark/blob/main/access/README.md), [design/guardrail-rollout](design/guardrail-rollout.md), [IAM, lesson 3](../courses/iam/03-guardrails-in-the-editor.md))
48. **What phase 1 for I1 to I5 deliberately left out.** ECR and
    security groups are not declared in `envs/prod`, because the Floci
    provider overrides only iam, sts and s3 and the fork's ECR support is
    untested, so the runner registry and the default-deny groups wait for
    a lesson that can show them. `scripts/proofs`, `render-delta`,
    CODEOWNERS generation and the apply workflow belong to I6 and later.
    Access Analyzer validate-policy is untried. Checkpoint tags
    `checkpoint/i0` to `checkpoint/i5` mark the repo after each lesson,
    so lesson N starts from i(N-1).
    ([plan](https://github.com/INTENTIUS/waterpark/blob/main/project/plan.md), [issues](https://github.com/INTENTIUS/waterpark/blob/main/project/archive/issues.md))
49. **The satellite lives in this repo.** `waterpark-runner` names the one
    satellite, a sibling root under `access/`, named in `access/README.md`.
    It declares its registry and the `runner-builder` role inside the
    boundary, with no human principal. It is not a second GitHub repository.
    Decision 33 already made this repo the estate, one clone and one PR
    flow, and a second repository would put the marquee double-refusal
    lesson behind a repo the student does not have. The satellite shares CI
    and CODEOWNERS with the central repo, so the cost is that the lesson has
    to say what a separate repo would change (its own PR job, its own deploy
    credential minted centrally), and the double refusal is demonstrated
    with a separate deploy credential rather than a separate repo.
    ([estate](estate.md), [design/delegation](design/delegation.md),
    [IAM, lesson 8](../courses/iam/08-delegation-and-the-double-refusal.md))
50. **The shared module is a git source, not a registry module.** Issue 46
    and decision 10 said `waterpark/workload-role/aws`. The satellite
    consumes the module as
    `git::https://github.com/INTENTIUS/waterpark.git//access/modules/<name>?ref=<tag>`,
    pinned to a checkpoint or release tag, and the same for the rule pack
    path. A registry namespace is a thing to run and an account to hold, and
    a git ref carries the same version pin. This also answers C1's open
    question about how a satellite consumes central identifiers, with module
    outputs and pinned refs rather than `terraform_remote_state`. The cost
    is that a git source has no semantic version constraint syntax, so
    warn-minor and error-major (decision 9) is a tagging convention and a
    line in the rule pack's README rather than a registry feature.
    ([issues](https://github.com/INTENTIUS/waterpark/blob/main/project/archive/issues.md),
    [design/delegation](design/delegation.md),
    [design/guardrail-rollout](design/guardrail-rollout.md),
    [IAM, lesson 8](../courses/iam/08-delegation-and-the-double-refusal.md))
51. **The apply job runs against Floci, like everything else.** I6's gated
    apply on protected branches is a GitHub Actions job whose target is a
    Floci service container in the same job, so the whole path from PR to
    apply runs with no AWS account, and the digest check on the saved plan
    (P14) is what the job proves. The OIDC tiers into a real account
    (decision 12) are declared as code and described on the page, and their
    first run is live-only until an account exists. The cost is that an
    apply against a service container that dies with the job proves the
    pipeline, not persistence, so the lesson says which, and the drift
    lesson (I7) seeds its drift locally rather than in CI.
    ([threat-model](threat-model.md),
    [IAM, lesson 6](../courses/iam/06-one-path-to-prod.md),
    [IAM, lesson 7](../courses/iam/07-drift.md))
52. **The plan digest travels as a workflow artifact keyed by the PR head
    sha.** The pr job uploads `plan.json` and `plan.digest` as
    `access-plan-<head sha>`, the apply job resolves the merged PR from the
    commit, finds the successful pr run on that head sha and downloads by
    run id, then recomputes the digest on its own plan and refuses on
    mismatch. A committed digest file was rejected because a digest is
    against a particular account, and a student whose Floci already holds
    the estate computes a different one from an empty CI container. One
    script, `access/scripts/plan-digest`, does the normalization for both
    jobs. The cost is that a rebase merge changes the head sha, so the apply
    job must resolve the PR through the merged commit rather than the sha it
    runs on, and a PR merged without a green pr run has no artifact and the
    apply refuses, which is the intended failure.
    ([access](https://github.com/INTENTIUS/waterpark/blob/main/access/README.md),
    [IAM, lesson 6](../courses/iam/06-one-path-to-prod.md))
53. **The shared module for satellites is `access/modules/persona`, not a
    `workload_role` wrapper.** Decision 10 named the wrapper. A wrapper
    forwarding a dozen variables declares them twice and enforces nothing
    the boundary and the rule pack do not already enforce. The persona
    module gained `federated_trust` with an explicit issuer host so trust
    policies are known at plan time, and a `push` grant level for registries
    with `ecr:GetAuthorizationToken` as its own statement because the API
    refuses to scope it. The satellite consumes the boundary through a `data
    "aws_iam_policy"` lookup by name, not `terraform_remote_state` and not a
    copied ARN.
    ([access/modules/persona](https://github.com/INTENTIUS/waterpark/blob/main/access/modules/persona/README.md),
    [design/delegation](design/delegation.md),
    [IAM, lesson 8](../courses/iam/08-delegation-and-the-double-refusal.md))
54. **The OIDC provider for GitHub Actions lives in `envs/prod`, not
    `identity/`.** Decision 39 put trust anchors under `identity/`, but
    `identity/` targets the management account and is live only, while an
    OIDC provider is account scoped and this one belongs to `waterpark-prod`
    beside the role that trusts it. Lesson I9 settles whether `identity/`
    keeps any trust anchors at all.
    ([design/workload-identity](design/workload-identity.md),
    [IAM, lesson 6](../courses/iam/06-one-path-to-prod.md),
    [IAM, lesson 9](../courses/iam/09-federation-trust.md))
55. **`runner-builder` moved from `envs/prod` to the satellite root
    `access/satellites/waterpark-runner/`, per [the estate](estate.md)'s
    scenario 5.** The satellite declares its own ECR registry, because the
    patched Floci runs ecr and `aws_ecr_repository` applies and plans clean
    with an endpoint override. This lifts the registry deferral in decision
    48. The module source is committed as the local path, with
    `access/scripts/satellite-source local|git <tag>` switching to the
    pinned git form, because the tag a satellite pins is cut after the
    commit that introduces it. Earlier checkpoints are unaffected, since
    they are tags of the tree as it was.
    ([estate](estate.md), [design/delegation](design/delegation.md),
    [IAM, lesson 8](../courses/iam/08-delegation-and-the-double-refusal.md))
56. **Two rule changes.** `path-matches-name` drops any known provider
    prefix (`aws_`, `github_`), and `boundary-required` also fires on a
    module call in an `iam_role.*.tf` file, because tflint reads the calling
    directory only and a satellite leaf file with the boundary stripped
    would otherwise pass lint. The double refusal depends on the second.
    Both carry failing and passing fixtures. Both landed at
    `checkpoint/i6` with the check stack rather than at lesson 8, so lesson
    6 is where the first refusal became real and lesson 8 relies on it.
    ([design/guardrail-rollout](design/guardrail-rollout.md),
    [IAM, lesson 6](../courses/iam/06-one-path-to-prod.md),
    [IAM, lesson 8](../courses/iam/08-delegation-and-the-double-refusal.md))
57. **The rule pack is delivered to a satellite by a shallow clone at a tag,
    not a tflint plugin source.** tflint has no git source for a Rego pack,
    so the satellite's `.tflint.hcl` sets `TFLINT_OPA_POLICY_DIR` and the
    documented clone at depth 1 on the tag is the pin. Warn-minor and
    error-major is a tagging convention written in
    `access/.tflint.d/README.md`. Ratchet baselines for what already
    violates a new rule are not built, and the README says so.
    ([design/guardrail-rollout](design/guardrail-rollout.md),
    [IAM, lesson 8](../courses/iam/08-delegation-and-the-double-refusal.md))
58. **The apply role's boundary is a known contradiction that only bites on
    a real account.** The estate boundary denies all IAM write and the
    guardrail path by name, which includes `role/waterpark-apply` and the
    state bucket, so a `waterpark-apply` carrying it could not apply the
    estate. On the taught path the job uses Floci test credentials and the
    role carries no grants, and `access/scripts/prove-no-detach` uses a
    stand-in user because Floci honors the role's trust policy. A real
    account needs an apply-specific boundary, which decision 36's
    one-boundary rule has not taken. Also record here as facts, not
    decisions. Floci does enforce boundary denies in authorization (phase 0
    tested only the condition key), Floci honors trust policies on
    `sts:AssumeRole`, the drift job in CI is always clean because it applies
    into an empty container and says so, and the satellite deploy credential
    `waterpark-runner-deploy` is a user with the boundary condition as its
    cap and no boundary of its own, standing in for the satellite's OIDC
    role since Floci has no subject to bind.
    ([threat-model](threat-model.md),
    [IAM, lesson 6](../courses/iam/06-one-path-to-prod.md),
    [IAM, lesson 8](../courses/iam/08-delegation-and-the-double-refusal.md))
