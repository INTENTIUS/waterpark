# water park — principles

The invariants. Every prescription serves one of these; each cites the
pinned decision that argues it ([decisions.md](decisions.md)).

1. **The write path is always the PR.** No write GUI, no broker, no
   approve button in chat. Browsing is read-only. (decisions 1, 18)
2. **Trust attaches to compiled checks, never to authors.** Human,
   agent, or attacker — the pipeline verifies identically, which is
   what makes an untrusted author safe to have. (decisions 14, 22)
3. **Approve the change, not the diff.** The reviewer approves a
   rendered manifest — the semantic access delta and its proofs — bound
   by digest; apply refuses on divergence. (decisions 6, 24)
4. **Revocation guarantees live in the cloud.** A dead orchestrator can
   delay cleanup; it can never extend access. (decision 8)
5. **Authority never decentralizes; boundaries do.** A team may create
   identities that act on its own resources, inside a centrally-owned
   permission boundary; it may never change what an identity is allowed
   to be. (decisions 5, 20)
6. **Everything security-relevant is declared and drift-watched — the
   machinery included.** CODEOWNERS, branch protection, trust anchors:
   all generated or declared, all watched. Drift is an incident, not
   noise. (decisions 3, 13, 21)
7. **The sandbox is never a principal.** Untrusted compute holds no
   cloud credentials and is never a federation subject; capability
   arrives as a scoped token for a verb service outside the boundary.
   (decision 15)
8. **Identity is declared, never asserted.** A requester earns standing
   by appearing in a reviewed leaf file; anything else is an unverified
   claim, rendered as one. (decision 17)
9. **No new formats.** Typed source in, native artifacts out; the
   estate must outlive the toolchain that produced it. (decision 2)
10. **Meet the org where it is.** AWS first; authoring backends are
    first-class end states; migration is offered, never pushed.
    (decisions 4, 11, 23)
