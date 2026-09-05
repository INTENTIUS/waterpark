---
title: "The AWS desk"
---

What the "Fountain AWS desk" is, concretely. It is dns-desk's form applied
to an AWS estate declared as Terraform, with Mend's credential split and
Rounds' rules where nobody is watching. It is the app the agent lessons
build (Fountain course 7 to 9, IAM course 12 and 13), and the applier is
Terraform itself (decision 31). Nothing here needs a toolchain beyond
Terraform, the AWS CLI, `jq` and a code host.

## One paragraph

A static page talks to a Fountain teammate called the desk. The desk's
target is a repo of Terraform, one resource per file, plus the live estate
that Terraform describes. You ask in plain words ("site-publisher needs
read on waterpark-artifacts"). The desk edits one file, runs `terraform
plan`, asks Access Analyzer whether the change grants new access, and hands
back a plan. The plan is the diff, the access delta and the proof verdict
side by side. What happens next depends on the mode. In **direct** mode,
which is dns-desk's posture, you say `APPROVE plan-id`, the desk replans
against the estate as it is now and applies the saved plan, holding a role
scoped by a permission boundary. In **repo** mode, which is the course's
posture, the desk opens a pull request with the plan in the body, the merge
is the approval, and a job holding the apply role runs `terraform apply`.
In repo mode the desk holds nothing that can write to AWS. On a schedule
the same teammate runs the drift watch and proposes one PR per drifted
resource under Rounds' rules. The conversation is the record for requests,
the code host is the record for changes, and CloudTrail with a
per-conversation source identity is the record for applies.

## The target: a repo of Terraform, one resource per file

```
envs/
  prod/
    main.tf                                    provider, backend, locals
    iam_role.site_publisher.tf                 one resource
    iam_policy.site_publisher_read_artifacts.tf
    s3_bucket.waterpark_artifacts.tf
    ecr_repository.waterpark_runner.tf
  dev/                                          the same shapes, no traffic
baseline/
  iam_policy.boundary.tf
  security_group.default_deny.tf
identity/
  sso_permission_set.course_author.tf
  sso_assignment.course_author_prod.tf
modules/
  workload_role/                                boundary, marker and naming, applied for you
scripts/
  render-delta                                  plan JSON -> the access delta text
  proofs                                        validate-policy and check-no-new-access
```

The path is the index. A file is named `<resource_type>.<label>.tf` and
holds exactly one `resource` block whose type and label the file name
repeats, so a stranger finds a resource by guessing a path and predicts
the file from the resource address. There is no assemble step and no
generated template, because Terraform already loads every `.tf` in a
directory as one module. That is the whole build.

A grant's expiry is a `Condition` on `aws:CurrentTime` in the policy
document plus a tag carrying the same date, and a check in `proofs` flags
the ones past due.

## State, named as a cost

Terraform keeps a state file. Accessible Ops XI warns about exactly that,
and the course does not pretend otherwise (decision 32). What the desk does
about it. State lives in `waterpark-security` with locking and is never the
system of record. Every read the desk performs goes to the cloud, through
`get-role` and `list-attached-role-policies` and the rest, not to state, so
`aws-state` describes the estate rather than Terraform's opinion of it. The
drift watch compares what the repo declares against what is live. State is
how Terraform maps one to the other and nothing more.

## The Fountain objects

| Object | Contents |
|---|---|
| Environment `aws-desk toolkit` | `apt`: `terraform`, `awscli`, `jq`; no secrets; `networking_type: limited`, `allowed_hosts`: the code host, the provider registry, and the AWS endpoints (or the Floci host) the mode needs |
| Agent `aws-desk` | the system prompt is `spec.ts` (the protocol and the rules); skills: the repo's SKILL.md; `allowed_vault_ids` pinned |
| Vault, direct mode | `AWS_ROLE_ARN` (the desk-operator role), `AWS_ROLE_SESSION_NAME`, `AWS_WEB_IDENTITY_TOKEN_FILE`, or static keys for Floci; one vault per account |
| Vault, repo mode | `GITHUB_TOKEN` fine-grained, contents and pull-requests on the access repo only |
| Teammate | one desk per estate (`AWS desk: waterpark`); its computer keeps the clone and the last `aws-state` |
| Schedule | the same teammate, `0 6 * * 1-5`, prompt "run the watch" |

## The protocol

Fenced blocks parsed out of replies (`protocol.ts`), pinned in the prompt
(`spec.ts`). Change one, change both. The page derives everything from
turns plus blocks on load, and from one `/api/team/stream` while live.

```
aws-state   {"fetched_at":…,"complete":false,
             "workspaces":[{"name":"prod","account":"…","region":"…",
                            "last_apply":"…","drift":"none",
                            "resources":[{"address":"aws_iam_role.site_publisher",
                                          "type":"aws_iam_role","id":"…"}]}]}
aws-plan    {"id":"plan-7f3a","workspace":"prod","mode":"repo",
             "changes":[{"action":"update","replace":false,
                         "address":"aws_iam_policy.site_publisher_read_artifacts"}],
             "delta":"grants s3:GetObject on waterpark-artifacts to site-publisher",
             "proofs":[{"check":"CheckNoNewAccess","result":"FAIL","reason":"new access: s3:GetObject"}],
             "files":["envs/prod/iam_policy.site_publisher_read_artifacts.tf"],
             "diff":"…unified diff of the file edit…","digest":"sha256:…"}
aws-result  {"plan_id":"plan-7f3a","status":"pr-opened"|"applied"|"refused"|"stale",
             "detail":"https://github.com/…/pull/42"|"Apply complete"|"…"}
aws-drift   {"workspace":"prod","detected_at":…,
             "resources":[{"address":"aws_security_group.default_deny","status":"changed",
                           "diff":[{"path":"ingress[0].cidr_blocks",
                                    "declared":"10.0.0.0/8","live":"0.0.0.0/0"}]}]}
```

`delta` and `proofs` are never model output. `render-delta` and `proofs`
produce them and the desk copies them in (decision 14). `changes` is read
out of `terraform show -json tfplan`, not summarized from the human
output. A `proofs` FAIL on a change the requester asked for is not an
error, it is what the reviewer is being asked to approve, rendered in
words.

## What the desk does, per request

1. **Read.** Refresh the clone, then read the estate from the cloud and
   emit `aws-state`, one workspace at a time.
2. **Edit.** Locate the file by convention (a principal maps to
   `envs/<env>/iam_role.<name>.tf` and its grants to the policy file
   beside it) and make the one edit.
3. **Plan.** `terraform plan -out=tfplan` against the target account with
   the plan role, or against Floci. `terraform show -json tfplan` for the
   typed changes. `proofs` on every changed policy document.
   `render-delta`. Emit `aws-plan` with a digest over the saved plan file.
4. **Propose.** Direct mode waits for `APPROVE plan-id`. Repo mode commits
   on `desk/<plan-id>`, opens the PR with the plan block rendered as the
   body, and emits `aws-result: pr-opened`.
5. **Apply**, direct mode only. On approve, replan. If the new plan does
   not match the approved digest, discard and re-plan
   (`aws-result: stale`). Otherwise `terraform apply tfplan` and emit
   `aws-result: applied`. Terraform refuses a saved plan whose state has
   moved on its own, so the digest check and the applier agree. Repo mode
   leaves this to the job after merge, and the desk reports the job's
   outcome when asked.
6. **Refuse** when the request is outside the desk's workspaces, when it
   needs the boundary or the baseline changed ("that is a change to the
   fence, here is the platform path"), or, in repo mode, when it comes
   from a requester not enrolled on a principal file (decision 17). A
   refusal is an `aws-result: refused` with the next step named.

## The watch (the same teammate, on the schedule)

`terraform plan -detailed-exitcode` per workspace. Exit 0 means the estate
matches. Exit 2 means it does not, and the plan JSON says which resources
and which attributes. Emit `aws-drift`. For each changed or deleted owned
resource, open one PR on `desk/drift/<workspace>/<address>` that restores
what the repo declares, which is usually an empty diff whose job is to
trigger the apply, with a marker in the body. Never a second PR for the
same resource while one is open. A PR closed unmerged is a no until it is
labeled `desk:reconsider`. At most N open. Expired grants come through the
same path as burndown PRs. State lives at GitHub, as Rounds does it.

## The credential table

| Mode | Who | Holds | Can |
|---|---|---|---|
| direct | the desk | a vault with an assume-role into `desk-operator`, bounded by the central permission boundary, `sts:SourceIdentity` = conversation id | plan and apply on its workspaces, nothing outside the boundary, not detach the boundary |
| direct | the page | the user's Fountain session | approve, by message |
| repo | the desk | a fine-grained GitHub token, one repo, contents and pull requests | clone, commit on `desk/*`, open PRs, not merge |
| repo | the apply job | the apply role via OIDC, bounded (decision 12) | `terraform apply` on protected branches only, after the digest check |
| repo | CODEOWNERS | merge rights | the approval |
| both | the watcher | the same as the desk in that mode | the same, plus the cap and the declined list |

Direct mode is honest dns-desk. The token's scope is the real control, and
the desk holds a write credential while reading a repo. For a repo you
control and an account you own that is fine. For an org's IAM the course
moves to repo mode, where the desk holds nothing that can touch AWS
(decision 15) and the rules that matter, which are branch protection,
CODEOWNERS, the job's digest refusal and the boundary, hold when the prompt
is ignored.

## The page

Three panes, like dns-desk's zones and activity.

- **Estate**, the newest `aws-state`, per workspace its last apply and
  drift, per resource its address and id, and a search box that answers
  "who can reach the artifacts bucket" from the declared HCL and the live
  reads.
- **Activity**, derived: request, plan, decision, result. A plan shows the
  access delta first, then the proof verdicts, then the file diff, then
  the raw plan JSON. Buttons are **Approve** (direct) or **Open PR** (repo,
  opened from the browser with the user's token, Mend style, or by the
  desk with its PR-only token), and **Re-plan**.
- **Drift**, the newest `aws-drift` per workspace, each row linking its PR.

Settings in `localStorage`: Fountain URL, sign-in, the estate repo, the
mode, the account and region list. Server side, only what every Fountain
client needs, which is `API_CORS_ORIGINS` and `OAUTH_CLIENTS`. Nothing is
stored on a server.

## What exists, what is built

Exists: teammates, vaults bound at creation, schedules, the team stream,
Sign in with Fountain, the static-client patterns (dns-desk, fountain-team).
Terraform's saved plan, JSON plan output, `-detailed-exitcode`, `import`
blocks and `removed` blocks. Access Analyzer `validate-policy` and
`check-no-new-access`. Floci's IAM, STS and S3 for the solo path.

To build: the page, `spec.ts` and `protocol.ts`, `render-delta`, `proofs`,
the apply workflow with the digest check, and, if the watcher's cap needs
enforcing outside the prompt, a small propose endpoint in Rounds' shape.
None of it is a toolchain. All of it is repo scripts, a page and a prompt.

## Where it lands in the courses

| Lesson | The desk part |
|---|---|
| Fountain 7 | the protocol and the page, with `aws-state` as the hello block |
| Fountain 8 | direct mode end to end against Floci: state, plan, approve, apply, replan before apply |
| Fountain 9 | the watch on a schedule, one PR per drift, Rounds' rules |
| IAM 1 to 6 | the repo shape, the guardrail checks, CODEOWNERS, the job, the boundary |
| IAM 12 | repo mode: the request that becomes a PR, and the refusals |
| IAM 13 | the watch over the real estate, expired grants, burndown |
| IAM 14 | the plan digest, and the job that refuses on divergence |
| IAM 15 | `import` blocks: adopt a pre-existing role with nothing changed |
