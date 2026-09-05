---
title: "Principles (IAM scenario)"
---

The invariants of the IAM scenario. Every prescription serves one of these;
each cites the pinned decision that argues it ([decisions.md](decisions.md))
and the [Accessible Ops](https://accessibleops.net) property it
instantiates. The course's themes are the properties; these are what they
look like on org IAM.

1. **The write path is always the PR.** No write GUI, no broker, no
   approve button in chat. Browsing is read-only. (decisions 1, 18;
   Accessible Ops IV)
2. **Trust attaches to compiled checks, never to authors.** Human,
   agent, or attacker — the pipeline verifies identically, which is
   what makes an untrusted author safe to have. (decisions 14, 22;
   II, XIV)
3. **Approve the change, not the diff.** The reviewer approves a
   rendered manifest — the semantic access delta and its proofs — bound
   by digest; apply refuses on divergence. (decisions 6, 24; VIII, XIV)
4. **Revocation guarantees live in the cloud.** A dead orchestrator can
   delay cleanup; it can never extend access. (decision 8; VII)
5. **Authority never decentralizes; boundaries do.** A team may create
   identities that act on its own resources, inside a centrally-owned
   permission boundary; it may never change what an identity is allowed
   to be. (decisions 5, 20; VI)
6. **Everything security-relevant is declared and drift-watched — the
   machinery included.** CODEOWNERS, branch protection, trust anchors:
   all generated or declared, all watched. Drift is an incident, not
   noise. (decisions 3, 13, 19, 21, 28; XI, XIII)
7. **The sandbox is never a principal.** Untrusted compute holds no
   cloud credentials and is never a federation subject; capability
   arrives as a scoped token for a verb service outside the boundary.
   (decisions 15, 29, 30; V, VI)
8. **Identity is declared, never asserted.** A requester earns standing
   by appearing in a reviewed leaf file; anything else is an unverified
   claim, rendered as one. (decision 17; IX)
9. **No new formats.** Declared source in, native artifacts out, so the
   estate outlives the toolchain that produced it. (decision 2; I,
   XII)
10. **Meet the org where it is.** AWS first, the pattern is
    backend-blind, and the course teaches on Terraform because that is
    where most orgs already are. Migration is offered, never pushed.
    (decisions 4, 11, 23, 31; XII)

Accessible Ops III (documentation is law) has no invariant of its own:
the decisions ledger is the worked example, and lesson I0 teaches it. X
(secret rotation is cheap) is a consequence of 7 and the trust layer
(lesson I9).
