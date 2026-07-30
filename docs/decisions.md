# Decisions

Pinned so they don't get re-litigated. Each links to the doc that argues
it. Reversing one requires editing this file in the same PR.

1. **The write path is always the PR.** No write GUI, ever. Browsing goes
   to behold over the graph. ([plan](plan.md), [positioning](positioning.md))
2. **No new format.** TypeScript in, CloudFormation out, export bundle so
   artifacts outlive the toolchain. The anti-IAMbic clause.
   ([landscape](landscape.md))
3. **Manages what it declares, audits what it owns.** Not a CSPM, not a
   CIEM, no JIT catalog UX. Estate-wide scanning is the chant-audit
   funnel. ([positioning](positioning.md), [landscape](landscape.md))
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
10. **The context package ships early.** Rules and presets live in
    `@org/waterpark-context` from the start; satellites are consumers from
    day one. ([plan](plan.md))
11. **Account vending is out of scope.** water park references accounts
    (registry, reference-existing); Control Tower / org-formation vend
    them. ([design/multi-account](design/multi-account.md))
12. **The apply credential is bounded.** water park must not be able to
    escalate water park; the apply role carries its own permission
    boundary. ([threat-model](threat-model.md))
13. **Federation trust is estate; the issuer is not.** water park declares
    OIDC/SPIFFE/Roles-Anywhere trust anchors as code with the strictest
    lint and drift severity, and never operates an identity issuer —
    BYO-issuer (k8s SA tokens, CI OIDC, SPIRE, or a commercial SPIFFE
    vendor). ([design/workload-identity](design/workload-identity.md))
14. **Agents propose; they never approve, apply, or signal.** The agent
    is an untrusted author whose PRs are verified identically to human
    PRs. Trust attaches to the compiled checks, never to the author.
    Chat authors the PR; the PR remains the only write path.
    ([design/agentic](design/agentic.md))
15. **The sandbox is never a principal.** An untrusted agent sandbox
    holds no cloud credentials and is never a federation subject.
    Identity attaches to the verb service outside the sandbox boundary,
    whose trust anchor is network-bound; the sandbox receives only a
    conversation-scoped verb-API token.
    ([design/agentic](design/agentic.md),
    [design/workload-identity](design/workload-identity.md))
