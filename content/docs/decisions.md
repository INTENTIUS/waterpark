---
title: "Decisions"
---

Pinned so they don't get re-litigated. Each links to the doc that argues
it. Reversing one requires editing this file in the same PR.

1. **The write path is always the PR.** No write GUI, ever. Browsing goes
   to behold over the graph. ([plan](plan.md), [positioning](positioning.md))
2. **No new format.** Typed source in, native artifacts out, export bundle
   so the estate outlives the toolchain. The anti-IAMbic clause. Applies
   to both backends: chant emits CloudFormation, Terraform keeps its own
   plan/state. ([landscape](landscape.md))
3. **Manages what it declares, audits what it owns.** Not a CSPM, not a
   CIEM. Estate-wide scanning is the chant-audit funnel. Chat intake is
   not a JIT catalog: a JIT product grants on approval, water park's
   concierge produces a diff a human merges (decision 18).
   ([positioning](positioning.md), [landscape](landscape.md))
4. **AWS is the wedge; cross-cloud is act two.** Track B is needs-design
   until persona equivalence is solved. ([plan](plan.md))
5. **Humans get permission sets, workloads get roles.** No IAM users, no
   IAM groups. ([landscape](landscape.md), [design/personas](design/personas.md))
6. **Merge-then-apply is the default.** Apply-from-PR is a later option
   behind the freshness digest. ([pr-automation](pr-automation.md))
7. **PR automation is compiled, not served.** A compile target of the CI
   generators; a standing runner is deferred to requirements capture (C5).
   ([pr-automation](pr-automation.md))
8. **Break-glass expiry is cloud-side.** Temporal being down can delay
   cleanup, never extend access. TEAM interop documented, not replaced.
   ([design/break-glass](design/break-glass.md))
9. **Guardrails roll out warn-minor / error-major with ratchet
   baselines.** An upgrade cannot break a satellite without a warn cycle.
   ([design/guardrail-rollout](design/guardrail-rollout.md))
10. **The context package is the delegation contract.** Rules, presets and
    `WorkloadRole` live in `@org/waterpark-context`; a satellite is a
    consumer from its first file. Built in lesson I8 (amended under
    decision 26: it ships with the lesson, not "from the start" of a kit).
    ([plan](plan.md), [lessons/I8](../courses/iam/i8-delegation.md))
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
    chant's archived `aws-warden` — OU tree, SCPs, Identity Center,
    org trail, protected break-glass — is adopted on water park's terms:
    typed source instead of a YAML tree, the PR as the write path, the
    cycle design and guardrail set taken verbatim.
    ([upstream.md](upstream.md))
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
    ([plan](plan.md), [threat-model](threat-model.md))
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
23. **Two backends, one manifest.** water park supports chant and
    Terraform/OpenTofu as authoring backends, both first-class end
    states. The normalized change manifest — chant's typed change set,
    Terraform's plan JSON reduced to the same schema — is the common
    review, evidence, and access-review object; everything
    backend-specific stays behind it. `chant carve` is a chant feature
    documented for orgs that choose to move, never a water park funnel.
    ([plan](plan.md), [pr-automation](pr-automation.md))
24. **Approval binds to the manifest; the PR is the envelope.** A
    reviewer approves the rendered change manifest, identified by its
    digest; apply refuses when the recompiled manifest or the live
    estate diverges. The manifest is never the system of record —
    declared source in git is (decision 2). Extends decision 6.
    ([pr-automation](pr-automation.md))
25. **The IAM kit is the IAM scenario's backlog.** Superseded in framing
    by decision 26: the kit is neither a product nor parked; tracks A–E
    are the source material for lessons I1–I15 and IA, mapped in
    [issues.md](issues.md). Nothing there is "parked" except Track B and
    the org-layer reconcile, which are appendix lessons.
    ([plan](plan.md), [issues](issues.md))
26. **water park is a course on the propose loop.** Short lessons, each one
    theme and one check, teaching Fountain and one loop abstracted from
    Mend, Rounds and dns-desk ([propose loop](../propose-loop.md)) through the Accessible
    Ops properties, with one scenario, IAM at pepperoni, that applies
    it; Mend, Rounds and dns-desk are worked references inside the
    lessons, not tracks of their own. Every lesson runs alone or live
    with a group. IAM is one example and need not cover every property,
    and it is not forced onto one app: the concierge takes the desk's
    form, the watcher Rounds', and Mend runs on the access repo as-is.
    ([plan](plan.md), [demo](demo.md))
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
    watcher (I13). ([lessons/I7](../courses/iam/i7-drift.md), Rounds README)
29. **Containment claims need a hosted sandbox provider.** The
    self-hosted runner is trusted mode: no isolation, no egress policy
    (Fountain ADR 0022). Any lesson that says "default-deny egress" or
    "no credentials can leave" runs on Sprites, E2B or Daytona; on a
    runner the lesson says so. ([lessons/F10](../courses/foundations/f10-your-own-machine.md))
30. **The verb service is a server with policy; Mend, Rounds and dns-desk
    are the reference implementations.** Decision 15's "verb service outside the sandbox"
    is Rounds' server: the agent holds a read-only grant, the server
    holds the write credential for one target for one proposal, enforces
    the rules the prompt cannot, and renders the PR body from the same
    objects it reports. Where a human is present, Mend's form (the PR
    opened from the human's browser with the human's token) is enough.
    No chant MCP verb service is built ahead of need.
    ([propose loop](../propose-loop.md), [lessons/F8](../courses/foundations/f8-the-propose-loop-interactive.md),
    [lessons/F9](../courses/foundations/f9-the-propose-loop-ambient.md), [design/agentic](design/agentic.md))
