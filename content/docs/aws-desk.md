---
title: "The AWS desk"
---

What the "Fountain AWS desk" is, concretely: dns-desk's form applied to
an AWS estate declared as plain CloudFormation JSON, with Mend's credential
split and Rounds' rules where nobody is watching. It is the app the agent
lessons build (Fountain course 7–9; IAM course 12–13), and the applier for
the IAM course is CloudFormation itself (decision 31). Nothing here needs a
toolchain beyond the AWS CLI, `jq`, and a code host.

## One paragraph

A static page talks to a Fountain teammate called the desk. The desk's
target is a repo of CloudFormation resources, one per file, assembled into
one template per stack, plus the live stacks those templates describe. You
ask in plain words ("tickets-api needs read on the receipts bucket"); the
desk edits one file, assembles, asks CloudFormation for a changeset, asks
Access Analyzer whether the change grants new access, and hands back a
plan: the changeset rendered as a diff with the access delta and the proof
verdict beside it. What happens next depends on the mode. In **direct**
mode (dns-desk's posture) you say `APPROVE plan-id`, the desk re-creates
the changeset against the stack as it is now and executes it, holding a
role scoped by a permission boundary. In **repo** mode (the course's
posture) the desk opens a pull request with the plan in the body, the
merge is the approval, and a job with the apply role runs
`aws cloudformation deploy`; the desk holds nothing that can write to AWS.
On a schedule the same teammate runs drift detection and proposes one PR
per drifted resource, under Rounds' rules. The conversation is the record
for requests; the code host is the record for changes; CloudTrail, with a
per-conversation source identity, is the record for applies.

## The target: a repo of CloudFormation, one resource per file

```
stacks/
  access-tickets-prod/
    stack.json                      # StackName, account, region, parameters, capabilities
    AWS::IAM::Role/tickets-api.json # one resource: {"Type":…,"Properties":{…}}
    AWS::IAM::ManagedPolicy/tickets-api-read-receipts.json
    AWS::IAM::Role/tickets-deployer.json
  access-baseline/
    AWS::IAM::ManagedPolicy/boundary.json
    AWS::EC2::SecurityGroup/default-deny.json
  identity-center/
    AWS::SSO::PermissionSet/developer.json
    AWS::SSO::Assignment/tickets-developer-tickets-prod.json
scripts/
  assemble       # jq: one directory -> one template; Resources keyed by file name
  render-delta   # deterministic: changeset JSON + policy docs -> the access delta text
  proofs         # accessanalyzer validate-policy / check-no-new-access over changed policies
```

The path is the index (`stacks/<stack>/<Type>/<LogicalId>.json`); a file is
exactly the resource object CloudFormation expects, so a stranger predicts
the template from the file and `assemble` is a `jq -s` merge anyone can read.
`expires` on a grant is a tag and a date inside the policy's `Condition`
(`aws:CurrentTime`); a check in `proofs` flags the ones past due.

## The Fountain objects

| Object | Contents |
|---|---|
| Environment `aws-desk toolkit` | `apt`: `awscli`, `jq`; no secrets; `networking_type: limited`, `allowed_hosts`: the code host, and the AWS endpoints (or the Floci host) the mode needs |
| Agent `aws-desk` | the system prompt is `spec.ts` (the protocol and the rules); skills: the repo's SKILL.md; `allowed_vault_ids` pinned |
| Vault, direct mode | `AWS_ROLE_ARN` (the desk-operator role), `AWS_ROLE_SESSION_NAME`, `AWS_WEB_IDENTITY_TOKEN_FILE` or static keys for Floci; one vault per account |
| Vault, repo mode | `GITHUB_TOKEN` fine-grained: contents + pull-requests on the access repo only |
| Teammate | one desk per estate (`AWS desk: splashdown/access`); its computer keeps the clone and the last `aws-state` |
| Schedule | the same teammate, `0 6 * * 1-5`, prompt "run the watch" |

## The protocol

Fenced blocks parsed out of replies (`protocol.ts`), pinned in the prompt
(`spec.ts`); change one, change both. The page derives everything from
turns plus blocks on load and from one `/api/team/stream` while live.

```
aws-state   {"fetched_at":…,"complete":false,
             "stacks":[{"name":"access-tickets-prod","account":"…","region":"…",
                        "status":"UPDATE_COMPLETE","drift":"IN_SYNC",
                        "resources":[{"logicalId":"tickets-api","type":"AWS::IAM::Role","physicalId":"…"}]}]}
aws-plan    {"id":"plan-7f3a","stack":"access-tickets-prod","mode":"repo",
             "changeset":{"id":"…","changes":[{"action":"Modify","logicalId":"tickets-api-read-receipts",
                           "type":"AWS::IAM::ManagedPolicy","replacement":false}]},
             "delta":"grants s3:GetObject on splashdown-receipts to tickets-api",
             "proofs":[{"check":"CheckNoNewAccess","result":"FAIL","reason":"new access: s3:GetObject"}],
             "files":["stacks/access-tickets-prod/AWS::IAM::ManagedPolicy/tickets-api-read-receipts.json"],
             "diff":"…unified diff of the file edit…","digest":"sha256:…"}
aws-result  {"plan_id":"plan-7f3a","status":"pr-opened"|"applied"|"refused"|"stale",
             "detail":"https://github.com/…/pull/42"|"UPDATE_COMPLETE"|"…"}
aws-drift   {"stack":"access-tickets-prod","detected_at":…,
             "resources":[{"logicalId":"default-deny","type":"AWS::EC2::SecurityGroup","status":"MODIFIED",
                           "diff":[{"path":"/SecurityGroupIngress/0/CidrIp","expected":"10.0.0.0/8","actual":"0.0.0.0/0"}]}]}
```

`delta` and `proofs` are never model output: `render-delta` and `proofs`
produce them and the desk copies them in (decision 14). A `proofs` FAIL on a
request the requester asked for is not an error; it is what the reviewer
is being asked to approve, rendered in words.

## What the desk does, per request

1. **Read.** Refresh the clone; `describe-stacks`, `describe-stack-resources`
   for the stacks it owns; emit `aws-state` (incremental per stack).
2. **Edit.** Locate the file by convention (principal → `stacks/<stack>/AWS::IAM::*/<name>.json`),
   make the one edit, run `assemble`.
3. **Plan.** `create-change-set` (type UPDATE, or CREATE for a new stack) against the
   target account with the plan role, or against Floci; `describe-change-set`;
   `proofs` on every changed policy document; `render-delta`; emit `aws-plan`
   with a digest over (template, parameters, changeset changes).
4. **Propose.** Direct mode: wait for `APPROVE plan-id`. Repo mode: commit
   on `desk/<plan-id>`, open the PR, body = the plan block rendered; emit
   `aws-result: pr-opened`.
5. **Apply** (direct mode only). On approve: re-read the stack; if the
   stack's last-updated time or the template digest moved, discard and
   re-plan (`aws-result: stale`); else `execute-change-set`, wait, emit
   `aws-result: applied`. Repo mode: the job does this after merge and the
   desk reports the job's outcome when asked.
6. **Refuse** when the request is outside the desk's stacks, needs a change
   to the boundary or baseline ("that is a change to the fence; here is the
   platform path"), or, in repo mode, comes from a requester not enrolled on
   a principal file (decision 17). A refusal is an `aws-result: refused`
   with the next step named.

## The watch (the same teammate, on the schedule)

`detect-stack-drift` per owned stack; `describe-stack-resource-drifts`; emit
`aws-drift`. For each MODIFIED or DELETED owned resource, one PR on
`desk/drift/<stack>/<logicalId>` that restores the declared state (the
template already says what it should be; the PR's change is often empty
and its job is to trigger the apply), with a marker in the body; never a
second PR for the same resource while one is open; a PR closed unmerged
is a no until labeled `desk:reconsider`; at most N open. Expired grants
(the `proofs` check) come through the same path as burndown PRs. State
lives at GitHub, as Rounds does it.

## The credential table

| Mode | Who | Holds | Can |
|---|---|---|---|
| direct | the desk | a vault with an assume-role into `desk-operator`, bounded by the central permission boundary, `sts:SourceIdentity` = conversation id | create/execute changesets on its stacks; nothing outside the boundary; not detach the boundary |
| direct | the page | the user's Fountain session | approve, by message |
| repo | the desk | a fine-grained GitHub token, one repo, contents + pull requests | clone, commit on `desk/*`, open PRs; not merge |
| repo | the apply job | the apply role via OIDC, bounded (decision 12) | `cloudformation deploy` on protected branches only, after the digest check |
| repo | CODEOWNERS | merge rights | the approval |
| both | the watcher | the same as the desk in that mode | the same, plus the cap and the declined list |

Direct mode is honest dns-desk: the token's scope is the real control,
and the desk holds a write credential while reading a repo. For a repo it
controls and an account it owns that is fine; for an org's IAM the course
moves to repo mode, where the desk holds nothing that can touch AWS
(decision 15) and the rules that matter (branch protection, CODEOWNERS,
the job's digest refusal, the boundary) hold when the prompt is ignored.

## The page

Three panes, like dns-desk's zones and activity:

- **Stacks**: the newest `aws-state`; per stack its status and drift; per
  resource its type and physical id; a search box that is the estate view
  for "who can reach the receipts bucket" (the desk answers from the
  declared JSON and the live `get-role` / `list-attached-role-policies`).
- **Activity**: request → plan → decision → result, derived; a plan shows
  the access delta first, the proof verdicts, then the file diff, then the
  raw changeset; buttons: **Approve** (direct) or **Open PR** (repo; opened
  from the browser with the user's token, Mend-style, or by the desk with
  its PR-only token); **Re-plan**.
- **Drift**: the newest `aws-drift` per stack; each row links its PR.

Settings in `localStorage`: Fountain URL, sign-in, the estate repo, the
mode, the account/region list. Server-side, only what every Fountain client
needs: `API_CORS_ORIGINS`, `OAUTH_CLIENTS`. Nothing stored on a server.

## What exists, what is built

Exists: teammates, vaults bound at creation, schedules, the team stream,
Sign in with Fountain, the static-client patterns (dns-desk, fountain-team);
CloudFormation changesets, drift detection, resource import; Access Analyzer
`validate-policy` and `check-no-new-access`; Floci's CloudFormation, IAM and
STS for the solo path. To build: the page (three panes), `spec.ts` and
`protocol.ts`, `assemble`, `render-delta`, `proofs`, the apply workflow
with the digest check, and, if the watcher's cap needs enforcing outside
the prompt, a small propose endpoint in Rounds' shape. None of it is
toolchain; all of it is repo scripts, a page, and a prompt.

## Where it lands in the courses

| Lesson | The desk part |
|---|---|
| Fountain 7 | the protocol and the page, with `aws-state` as the hello block |
| Fountain 8 | direct mode end to end against Floci: state, plan, approve, apply, re-read before apply |
| Fountain 9 | the watch on a schedule; one PR per drift; Rounds' rules |
| IAM 1–6 | the repo shape, `assemble`, guardrails (JSON Schema + `validate-policy`), CODEOWNERS, the job, the boundary |
| IAM 12 | repo mode: the request that becomes a PR; refusals |
| IAM 13 | the watch over the real estate; expired grants; burndown |
| IAM 14 | the plan digest; the job refuses on divergence |
| IAM 15 | resource import: adopt a pre-existing role into a stack, zero edits |
