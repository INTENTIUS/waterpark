---
title: "Design: break-glass guarantees"
---

Gates A9. The question is whether a durable workflow is a sufficient
mechanism for a security control whose failure mode is elevated access
that never got revoked.

The sequence: request → approval gate → timed grant → auto-revoke. Durable
execution gives the workflow history as audit trail, revocation as saga
compensation, and a gate that survives runner death.

## Failure modes to design against

1. The workflow engine is down or its worker died mid-grant, so
   compensation cannot run. Unacceptable as the only revocation path.
2. Forged approval signal — whoever can signal can approve. Signal auth
   is undesigned (threat-model boundary 3).
3. Revocation API call fails while the grant is live.
4. The workflow definition itself weakened by a PR, which is covered by
   rendering gate removals loudly and by guardrail-path CODEOWNERS.

## The layered answer (adopted; decision 8)

The grant must expire cloud-side even if every water park component
dies:

- **Layer 1 — the grant carries its own expiry.** A
  `Condition: DateLessThan aws:CurrentTime` bound, or a natively
  temporary mechanism (temporary Identity Center assignment, session
  duration). The cloud enforces the TTL with no runner alive.
- **Layer 2 — saga compensation** removes the artifact (hygiene, and
  revoke-early on demand).
- **Layer 3 — the drift watch** flags any break-glass artifact past its
  expiry: layer 1 already made it inert, its presence is still a
  finding.

With layer 1, the workflow engine being down cannot extend access, only
delay cleanup. That is the honest guarantee statement for the docs.

## Settled, and what is left

1. **Grant mechanism.** A temporary Identity Center assignment whose
   policy carries an `aws:CurrentTime` condition. Floci cannot run
   Identity Center, so the self-paced path uses the time-conditioned
   policy on a role and lesson I10 says so (decision 37).
2. **Signal auth.** The approver is the reviewer of the break-glass PR,
   and the apply job copies that identity into the grant's tags, so the
   approval and the artifact name the same human (decision 37).
3. **Max TTL is two hours.** It is a constant in `access/baseline/` and
   a tflint rule refuses a longer one (decision 37).
4. Still to decide. TEAM interop: TEAM for routine elevated access,
   water park break-glass for when the paved road itself is down —
   confirm the boundary.
5. **Code-host-down operation.** A CLI confirmation by a second human is
   the documented fallback (decision 37).

## Acceptance test (drives A9's AC)

Kill the worker mid-grant. Access must still end at the expiry
(layer 1), the watch must flag the leftover artifact (layer 3), and the
restarted worker must clean it up (layer 2).
