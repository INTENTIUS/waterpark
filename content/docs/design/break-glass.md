---
title: "Design: break-glass guarantees"
---

Gates A9. The question: is a Temporal Op a sufficient mechanism for a
security control whose failure mode is "elevated access that never got
revoked"?

The sequence: request → approval gate → timed grant → auto-revoke. Durable
execution gives the workflow history as audit trail, revocation as saga
compensation, and a gate that survives runner death.

## Failure modes to design against

1. Temporal down or worker dead mid-grant — compensation can't run.
   Unacceptable as the only revocation path.
2. Forged approval signal — whoever can signal can approve. Signal auth
   is undesigned (threat-model boundary 3).
3. Revocation API call fails while the grant is live.
4. The Op definition itself weakened by PR — covered by Op-manifest
   diff + guardrail-path CODEOWNERS.

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

With layer 1, Temporal being down cannot extend access — only delay
cleanup. That is the honest guarantee statement for the docs.

## To decide

1. Grant mechanism: time-conditioned inline policy vs temporary
   Identity Center assignment vs a dedicated break-glass permission set.
   Lean: assignment + time-condition policy; validate mechanics.
2. Signal auth: who may approve, how authenticated, and whether the
   approver's identity lands in both the workflow history and the
   grant's tags.
3. Max TTL, and whether it is lint-enforced as a baseline constant.
4. TEAM interop: TEAM for routine elevated access, water park
   break-glass for when the paved road itself is down — confirm the
   boundary.
5. Code-host-down operation: CLI-signal path with the local executor as
   the documented fallback.

## Acceptance test (drives A9's AC)

Kill the Temporal worker mid-grant. Access must still end at the TTL
(layer 1), the watch must flag the leftover artifact (layer 3), and the
restarted worker must clean it up (layer 2).
