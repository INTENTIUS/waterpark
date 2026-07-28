# Design: break-glass guarantees (open question 5)

Gates A9. Not settled. The question: is a Temporal Op a sufficient
mechanism for a security control whose failure mode is "elevated access
that never got revoked"?

## The shape

Request → approval gate → timed grant → auto-revoke. Durable execution
gives: the workflow history as audit trail, revocation as saga
compensation on failure, and a gate that survives runner death.

## Failure modes to design against

1. **Temporal down or worker dead mid-grant.** Compensation can't run
   until the worker returns. Unacceptable as the only revocation path.
2. **Forged approval signal.** Whoever can signal can approve. Signal
   authentication is currently undesigned (threat-model.md boundary 3).
3. **Revocation API call fails** (throttle, outage) while the grant is
   live. Compensation retries help; a cloud-side bound is still needed.
4. **The Op definition itself weakened by PR** (gate removed, TTL
   extended). Covered by Op-manifest diff + guardrail-path CODEOWNERS.

## The layered answer (lean)

The grant must expire cloud-side even if every water park component dies:

- **Layer 1 — the grant carries its own expiry.** The granted policy or
  assignment embeds a `Condition: DateLessThan aws:CurrentTime` bound, or
  uses a natively temporary mechanism (Identity Center supports temporary
  assignment semantics; role session duration bounds assumed sessions).
  The cloud enforces the TTL with no runner alive.
- **Layer 2 — saga compensation** actually removes the artifact (hygiene,
  and revoke-early on demand).
- **Layer 3 — the drift watch** flags any break-glass artifact past its
  expiry as drift (it should have been removed by layer 2; its presence is
  a finding even though layer 1 already made it inert).

With layer 1, Temporal being down cannot extend access — it can only delay
cleanup. That is the honest guarantee statement for the docs.

## To decide

1. Grant mechanism: inline policy with time condition vs temporary
   Identity Center assignment vs a dedicated break-glass permission set
   whose assignment is created/deleted. (Assignment + time-condition
   policy is the lean; validate mechanics.)
2. Signal auth: who may approve, how the signal is authenticated, and
   whether approval identity lands in both the workflow history and the
   grant's tags.
3. Max TTL and whether it is lint-enforced as a constant in the baseline.
4. TEAM interop: for Identity-Center shops already running TEAM, water
   park documents coexistence and does not duplicate it — confirm the
   boundary (TEAM for routine elevated access, water park break-glass for
   when the paved road itself is down?).
5. Does break-glass work when the code host is down (the scenario where
   it's most needed)? CLI-signal path with local executor as the
   documented fallback.

## Acceptance test (drives A9's AC)

Kill the Temporal worker mid-grant. Access must still end at the TTL
(layer 1), the watch must flag the leftover artifact (layer 3), and the
restarted worker must clean it up (layer 2).
