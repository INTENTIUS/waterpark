The course consumes four upstreams: [Fountain](https://github.com/BinaryBourbon/fountain)
(agent runtime), the Fountain apps by jhgaylor (Mend, Rounds, dns-desk,
fountain-demos), [chant](https://intentius.io/chant) (compiler, lifecycle,
Ops, audit) and [Floci](https://github.com/floci-io/floci) (the free AWS
path). Pinned 2026-08-21; every lesson body is written against these
versions and re-run before it ships.

## Fountain — local main #858 (2026-08-19), CLI v0.12.0

**Where it lives.** `github.com/BinaryBourbon/fountain` returned 404 on
2026-08-21 (repo and docs site); the last fetched `main` is commit
`bcf069b` (#858). The Homebrew tap still publishes the v0.12.0 CLI from
that path. Verify the canonical location before a lesson links it.

**What the foundation lessons use.**

| Surface | Lesson | Fact |
|---|---|---|
| Four primitives; `fountain apply -f` over `apiVersion: fountain.dev/v1` | F1 | Environment, Vault, Agent, Conversation; secrets write-only; `env_vars` plain |
| Sandbox lifecycle | F2 | idle suspend (default 60 min) keeps the disk; max lifetime (default 24 h) destroys it; conversation stays resumable either way |
| `networking_type: limited` + `allowed_hosts`; vault wins on collision; `allowed_environment_ids` / `allowed_vault_ids` | F3 | default-deny egress allowlist; empty list denies all |
| Vault bound per conversation at creation | F4 | Mend's credential split depends on it |
| Team page; teammate = conversation on `fountain:team`; presence; `/api/team/stream` | F5 | one thread per agent; remove terminates and unbinds |
| Team schedules (#825): `POST /api/team/:agent_id/schedules`, `run now`, `schedule` stream event | F6 | cron 5 fields UTC; `one_off`, `enabled`; `last_run_at`, `last_error` |
| Sign in with Fountain (OAuth code + PKCE; token is an API key); `API_CORS_ORIGINS`; `OAUTH_CLIENTS` | F7 | the pattern every external app uses |
| Hosted MCP served by Fountain with the conversation's sandbox token (team-comms PoC) | F8, I12 | the provider credential never enters the sandbox |
| Self-hosted runner, ADR 0022 (accepted, built) | F10 | trusted mode only: no isolation, no egress policy, daemon must be online |
| ADR 0016 governance as an ACP proxy | F11 | Proposed, unbuilt; runtimes run with permission prompts bypassed; audit trail retrospective |
| `GET /api/search` across conversations | I13 | "which requests did the concierge handle" is a query |

**Two earlier claims corrected.** The demo-era runbook called the
self-hosted runner "the answer to shared infra"; ADR 0022 says the
opposite about containment (decision 29). And `design/agentic.md` once
read `limited` networking as a hint; it is an allowlist.

## The Fountain apps (jhgaylor, 2026-08-20/21)

| App | What it shows | Lessons |
|---|---|---|
| [fountain-demos](https://github.com/jhgaylor/fountain-demos) | the index at demos.inevitable.fyi; apps listed by audience | site layout |
| [Mend](https://github.com/jhgaylor/mend) | `chant audit` → agent mends → per-fix diffs → PR opened from the browser with the user's token; toolkit Environment with chant + ten lexicons; per-repo read-only vault; protocol blocks (`audit-report`, `mend-plan`, `mend-patch`, `mend-fix`, `pr-draft`) | F4, F7, F8, I3, I12 |
| [Rounds](https://github.com/jhgaylor/rounds) | the unattended sibling: schedule → audit → reconcile against own past PRs → fix and verify → propose through a server that mints a one-repo write token, enforces cap / declined / branch prefix, renders the PR body; agent holds an HMAC grant for a read-only token; `.rounds.yml`; `rounds:reconsider` | F6, F9, I7, I13 |
| [dns-desk](https://github.com/jhgaylor/dns-desk) | Cloudflare operator teammate; `dns-state` / `dns-plan` / `dns-result`; `APPROVE plan-id`; re-read before apply; token zone list is the blast radius; cites fountain#643 for gates | F7, F8, F11, I12 |
| fountain-team, fountain-conversations | the static-client patterns the others copy | F5, F7 |

## chant — 0.44.14

Unchanged from the kit-era notes, with the course's reading:

- **Lexicons.** `@intentius/chant-lexicon-aws` (CloudFormation) for the
  IAM scenario; `@intentius/chant-lexicon-fountain` exists, so the I12
  Environment can be declared in chant (INTENTIUS/fountain-ops is
  "self-hosted fountain, deployed by chant").
- **`chant audit`** with the ten catalogs (Mend's list) and the three
  tiers; WAW056-058 in the aws audit tier. Lessons F8, I3.
- **Graph lenses and `chant search`**; **`chant carve`** (documented, never
  pushed, decision 23); **landing-zone composites** (I5); **post-synth
  policy checks** and `policyGate()`; the **read path** for IAM drift
  (I7); the **apply contract** with endpoint overrides (I4's Floci path is
  the same code path as a real account); `plan --json` with lexicon
  version stamping (I14).
- **The aws-warden problem** stands: config producer in the lexicon,
  reconciler archived; decision 16 keeps it as appendix lesson IA.

**Still missing, and which lesson waits.**

| Gap | Lesson |
|---|---|
| Lint rule packages | I8 ships re-export shims |
| Project-local MCP tools (`.chant/tools/`) | I12 verbs surface as skills + Ops |
| Change-set renderers, plan digest (pr-automation items 1–2) | I14 |
| Op-manifest diff (item 9) | I10 step 4, I14 |
| A step referencing a prior step's output (chant#1290) | `wp-request` returns its PR URL as a search attribute |

## fountain-ops — local main 36ba204 (2026-08-09)

[INTENTIUS/fountain-ops](https://github.com/INTENTIUS/fountain-ops).
Self-hosted Fountain deployed by chant onto Kubernetes. `just up` on a
k3d laptop cluster in about five minutes; `tier=ha` gives two app
replicas in one Erlang cluster over CNPG-replicated Postgres; the same
build targets a real cluster. Registration and first-admin handling
match what the compose stack does (ADR 0011). Its Status page is
asserted against reality on every push and wins disagreements with its
own docs.

Seams that matter here. spritzer is its in-cluster data plane, so
conversations complete as **echoes** (34 of 34 at fountain v0.6.1 +
spritzer 0.5.0), which verifies the deployment and nothing about real
agent work; floci is its in-cluster S3 for backup dump/restore and PITR
drills, a different use of Floci than the courses'. The fountain image
pin is v0.7.0, which predates runner support, team schedules and most
of what the courses use.

Relation to the class stack: `compose/` is the student path (real
conversations on a containerized runner, Docker as the only prereq);
fountain-ops is the facilitator path to a durable shared instance, once
its pin moves to a runner-capable image and a real data plane
(`SPRITES_TOKEN` or runners) replaces spritzer.

## Floci — local main 17c7f7ef (2026-08-21)

In-process IAM (users, roles, groups, policies, boundaries, STS
AssumeRole / WebIdentity), CloudFormation, EC2 SGs (rules not enforced as
a firewall), CloudTrail. **IAM enforcement mode**
(`FLOCI_SERVICES_IAM_ENFORCEMENT_ENABLED=true`) evaluates identity,
session and boundary policies with `Condition` support; on deny,
CloudTrail emits `AccessDenied`. Not present: Organizations, Identity
Center, Access Analyzer. Open: whether the `iam:PermissionsBoundary`
condition key is honored on `CreateRole` (I8 solo path; plan.md).

## Accessible Ops — 14 properties (site content 2026-08-14)

Hugo; one page per property, expandable bars on the home page; each
property tagged with the outcome it buys. The course borrows the site
layout and uses the properties as lesson themes (F0).
