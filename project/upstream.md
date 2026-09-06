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

**Manifest secrets are a map.** `docs/primitives.md` shows `secrets` as a list of `{key, value}`. The server silently drops that form (`secret_count: 0`). The real contract, confirmed against a live v0.12 stack and the CLI tests, is a map (`secrets: {KEY: value}`). The lesson and skill use the map. Worth an upstream doc fix when the repo is reachable.

**Three things seen on the compose stack, 2026-09-05.** The Claude
runtime refuses fully qualified model ids (`claude-sonnet-4-6`,
`claude-opus-4-7`, dated ids) at turn time with `Invalid value for config
option model` and runs on the account default, while the aliases `sonnet`,
`opus` and `haiku` pass, so the lessons pin aliases. `GET /api/conversations`
returns `environment_id` null for a conversation whose agent carries the
environment and whose provision log names it. A user is capped at two
concurrent sandboxes (`http 429`), and an idle conversation holds its slot
until `fountain conv terminate`. All three are upstream questions once the
repo is reachable.

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

## Floci as a Terraform target, verified 2026-09-05

Floci alone on port 4566, IAM enforcement on
(`FLOCI_SERVICES_IAM_ENFORCEMENT_ENABLED=true`), hashicorp/aws against
`endpoints { iam sts s3 }`. The `test` access key resolves to
`arn:aws:iam::000000000000:root` and acts unrestricted under enforcement,
so all four facts ran with enforcement on. Total wall time 4m 16s.

| Fact | Result | Proving command | Evidence |
|---|---|---|---|
| 1. Converge | partial | `terraform apply -auto-approve` then `terraform plan -detailed-exitcode` | apply creates all 5 resources, none rejected; the immediate plan exits **2**, not 0, with `+ permissions_boundary = "arn:aws:iam::000000000000:policy/wp-permission-boundary"` |
| 2. Drift | pass | `aws iam detach-role-policy --role-name wp-workload --policy-arn ...wp-workload-read` then `terraform plan -detailed-exitcode` | exit **2**, `# aws_iam_role_policy_attachment.workload_read will be created`; `aws iam tag-role` drift also lands, `- "owner" = "intruder" -> null` |
| 3. Import | pass | `terraform plan -generate-config-out=generated.tf`, apply, then re-plan | `aws_iam_role.adopted: Import complete [id=wp-adopted]`; the adopted role appears in the next plan only as a `Refreshing state...` line, with no diff |
| 4. Boundary enforcement | fail | `aws iam create-role` as a user allowed `iam:CreateRole` only under `StringEquals iam:PermissionsBoundary` | both calls denied: `An error occurred (AccessDenied) when calling the CreateRole operation: User is not authorized to perform: iam:CreateRole`, with and without `--permissions-boundary` |

**Versions.** Floci image `floci/floci:latest`, digest
`sha256:4e451c39c7bb88e3cd4f87e8fc0c25d5b47695a51185d521e2241fa00486e8eb`,
image id `sha256:04d032aeba34ae0401fc4c0776c732384e557862abd8656c1e4bf74bdbb51a8b`,
built 2026-09-01. The container reports `floci 2.0.1 native (powered by
Quarkus 3.37.4)` and `AWS Local Emulator 2.0.1`. The host CLI is `floci
0.2.0`, a different number for the same release line. Terraform v1.15.8
selected hashicorp/aws **v6.63.0**. Account `000000000000`, region
us-east-1, storage `memory`.

**Two boundary bugs, and they are different.** The first is a read bug.
Floci accepts `PermissionsBoundary` on `CreateRole` and accepts
`PutRolePermissionsBoundary`, both without error, but `GetRole` and
`ListRoles` return the field as `null` forever. Terraform therefore never
sees the boundary it just set and plans the same in-place update on every
run, so no estate carrying a boundary can ever reach a clean plan. That is
what makes fact 1 a partial. Any lesson that ends on a green
`plan -detailed-exitcode` has to avoid `permissions_boundary` on the Floci
path or teach the diff as expected.

The second is an authorization bug, and it settles the question this file
listed as open. Floci does not populate the `iam:PermissionsBoundary`
request context key, so a policy conditioned on it matches nothing and
denies every call. A control user granted `iam:CreateRole` with no
condition creates roles fine, which rules out policy evaluation being
broken in general. Four spellings were tried, `StringEquals` and
`ArnEquals` and `StringLike` on `iam:PermissionsBoundary`, plus the
lowercase `iam:permissionsboundary`, and all four denied even when
`--permissions-boundary` was passed.

The consequence for I8 is that the double refusal does not demonstrate
against Floci. The lesson needs the second call to succeed once the
boundary is supplied, and Floci refuses both. It fails closed, so nothing
unsafe gets through, but a student on the solo path sees deny then deny
and learns the wrong lesson. I8 needs a real account, a recorded run, or
a rewrite until Floci populates the key.

**Clean on the rest.** `terraform destroy -auto-approve` removed all six
resources with no errors. `import` blocks and `-generate-config-out` both
work, which is I15 unblocked. Drift detection works on both the
attachment and the tag path, which is I7 unblocked.

## Floci as a Terraform target, patched fork build, verified 2026-09-05

Same setup as the 2.0.1 run. Floci alone on port 4566, IAM enforcement on
(`FLOCI_SERVICES_IAM_ENFORCEMENT_ENABLED=true`), hashicorp/aws against
`endpoints { iam sts s3 }`. Image under test is `ghcr.io/lex00/floci:iam-boundary`,
a fork build from branch `fix/iam-permissions-boundary`, Floci 1.7.0 base plus
fixes for the two boundary bugs recorded in the prior section. Total wall
time 2m 38s (container start to teardown).

| Fact | Result | Proving command | Evidence |
|---|---|---|---|
| 1. Converge | pass | `terraform apply -auto-approve` then `terraform plan -detailed-exitcode` | apply creates all 5 resources, none rejected; the immediate plan exits **0** with "No changes. Your infrastructure matches the configuration."; `aws iam get-role --role-name wp-workload` returns a `PermissionsBoundary` block with `PermissionsBoundaryArn = arn:aws:iam::000000000000:policy/wp-permission-boundary` |
| 2. Drift | pass | `aws iam detach-role-policy --role-name wp-workload --policy-arn ...wp-workload-read` then `terraform plan -detailed-exitcode` | exit **2**, `# aws_iam_role_policy_attachment.workload_read will be created`; `aws iam tag-role` drift also lands, `- "owner" = "intruder" -> null` |
| 3. Import | pass | `terraform plan -generate-config-out=generated.tf`, apply, then re-plan | `aws_iam_role.adopted: Import complete [id=wp-adopted]`; the re-plan is now a genuine clean exit, **0**, "No changes", not just a refresh with a lingering boundary diff |
| 4. Boundary enforcement | pass | `aws iam create-role` as a user allowed `iam:CreateRole` only under `StringEquals iam:PermissionsBoundary` | first call, no `--permissions-boundary`, denied with `AccessDenied ... User is not authorized to perform: iam:CreateRole`; second call, with `--permissions-boundary arn:aws:iam::000000000000:policy/wp-permission-boundary`, succeeds and the returned role carries that same boundary ARN |

**Versions.** Image `ghcr.io/lex00/floci:iam-boundary`, digest
`sha256:b08cd3d507429fae9201b85cca58dcb5e6708bca3bde37eaface7b7fb1419813`,
image id `sha256:44ac5a70121fddc2dfa46126faf40e1547ea937a538b395697bc47a2c8653fc7`,
built 2026-09-05. The container reports `floci 1.7.0 on JVM (powered by
Quarkus 3.37.4)` and `AWS Local Emulator 1.7.0`. Terraform v1.15.8 selected
hashicorp/aws **v6.63.0**, the same provider version as the 2.0.1 run.
Account `000000000000`, region us-east-1, storage `memory`.

**Both boundary bugs are fixed.** The read bug is gone. `GetRole` now
returns the `PermissionsBoundary` block Terraform set on `CreateRole`, so
the provider's next refresh matches the config and `plan -detailed-exitcode`
exits 0 instead of proposing the same in-place update forever. That turns
fact 1 from a partial into a clean pass and means an estate carrying a
boundary can now reach a stable green plan on Floci.

The authorization bug is also gone. Floci now populates the
`iam:PermissionsBoundary` request context key on `CreateRole`, so a policy
conditioned on `StringEquals iam:PermissionsBoundary` matches and allows
the call when the boundary is supplied, and still denies when it is not.
This is the exact double-refusal shape I8 needs, deny without the
boundary and allow with it. The lesson can demonstrate against Floci now
without a real account or a recorded run.

**Everything else still clean.** `terraform destroy -auto-approve` removed
all six Terraform-managed resources with no errors. Drift detection still
works on both the attachment and the tag path. Import and
`-generate-config-out` still work, and now the post-import plan is truly
clean rather than clean-except-for-the-boundary-diff.

**Difference from the 2.0.1 run, beyond the two intended fixes.** This
build runs on JVM (`floci 1.7.0 on JVM`) rather than as a native binary
(the 2.0.1 image logged `floci 2.0.1 native`), so cold start is about 1.1s
against roughly 0.02s before. That did not matter here since `curl` against
`/` answered on the first try. The enabled-service list also differs
because it is a different base version rather than a fork change. This
1.7.0 build is missing classic `elb` and `rekognition` from the 2.0.1
list, and carries several services 2.0.1 does not, including `ivs`,
`mediapackage`, `medialive`, `sagemaker`, `bedrock`, `apprunner`,
`accessanalyzer`, `globalaccelerator`, `cognitoidentity`, `codeartifact`,
`appintegrations`, `datasync`, and `auditmanager`. None of that touches
`iam`, `sts`, or `s3`, and none of the five resource types under test was
rejected or produced a different error shape. No regression found in the
four facts against the prior run.

**Two more probes on the patched build, 2026-09-05.** Access Analyzer is
listed among the enabled services, but `validate-policy`,
`check-no-new-access` and `check-access-not-granted` all answer
`UnknownOperationException`, an AWS-shaped error with no verdict. The
proofs in lesson 6 are therefore live only on the solo path, and the PR job
prints a named skip line when the API does not answer. The OpenID Connect
side is half there. `aws_iam_openid_connect_provider` and a role trusting it
apply and plan clean, and `get-open-id-connect-provider` round-trips the
url, client ids and thumbprint. `AssumeRoleWithWebIdentity` is a stub that
mints credentials for any non-empty token, reports `Provider` as
`accounts.google.com` whatever the provider declared, uses a fixed subject,
and enforces no `aud` or `sub` condition. Floci fails open on federation, so
lesson 9 can manage trust on a laptop and cannot show a forged token
refused.
