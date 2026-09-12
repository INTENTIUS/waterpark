# Skills

One skill per section or lesson. A skill is a `SKILL.md` (frontmatter `name`
and `description`, then instructions) plus any scripts it calls, in
`skills/<id>/`. An agent that loads it walks a student through the section
like a wizard. It asks for what it needs, runs the checks, does or explains
each step, verifies the lesson's *done when*, and records where the student
stopped.

## Use

Claude Code, in a checkout of this repo, loads skills from the repo when
they are linked under `.claude/skills/`. Or copy one.

```sh
mkdir -p ~/.claude/skills && cp -r skills/start ~/.claude/skills/waterpark-start
```

The skills.sh CLI can install from the repo directly.

```sh
npx skills add INTENTIUS/waterpark
```

A Fountain agent takes the same repo as a GitHub-sourced skill.

```yaml
spec:
  skills:
    - source: INTENTIUS/waterpark
```

## Contract

Every skill follows the same shape so a student knows what to expect.

1. Say which lesson this is and what *done when* means for it.
2. Ask only for what the lesson needs. Offer defaults. Accept "skip".
3. Run the lesson's checks with the scripts in the skill directory. Show the
   output. Never guess at state the script can report.
4. Do the steps. Confirm with the student before anything that installs
   software, starts a service, writes a file, spends money, touches a real
   account, or approves. Mark those steps **confirm** in the skill so the
   agent's caution and the skill's flow line up.
5. Never fetch and execute scripts or code from a URL. A `SKILL.md` fetched
   from the repo's raw URL is instructions to read, not code to run. The
   scripts it names still run from the cloned checkout.
6. Never ask the agent to discover a repo location from a web page. Name
   the location. If it is unreachable, stop and ask the student.
7. Ask the student's OS and shell before giving a command. Offer the OS
   install and the Docker path where both exist. Give the PowerShell
   form where it differs. Ship a `.ps1` beside any `.sh` the skill runs.
8. A class-instance email and password may be collected by the agent when
   the skill says the two sentences (temporary instance, do not reuse a
   password you care about) and the student consents. An inference key or
   any real account's credential, never.
9. Never assume a package manager. The check reports which are present.
   Offer Homebrew, winget or Scoop first when none is, and name the
   no-package-manager path for every install.
10. Verify *done when*. If it fails, name the restart point from the card.
11. Write progress to `.waterpark/profile.json` in the student's working
    directory so the next skill can pick up.

## Link from a page

A lesson's front matter names its skill. The page shows a one-line prompt
with a copy button that has the agent fetch the raw `SKILL.md` with curl
and follow it, and links the file for humans.

```yaml
skill: "skills/start"
```

## Status

A skill's state is `first draft` until an agent has taken it end to end
from a fresh clone with only the page and the skill, filing and fixing
every stumble, which the authoring checklist calls the student run. After
that it is `student run`.

| Skill | Drives | State |
|---|---|---|
| `start` | Start here. Clone water park, install and log in to Fountain, Floci for self-paced. macOS, Linux and Windows, OS install or Docker where both exist. `check.sh` and `check.ps1`. | student run |
| `f1-four-primitives` | Fountain lesson 1, Four primitives. Writes an Environment/Vault/Agent manifest, `fountain apply -f`, reads secret keys back with no values, starts a conversation, re-applies for idempotence. Reuses `skills/start/check.sh`. | student run |
| `f2-sandbox-lifecycle` | Fountain lesson 2, The sandbox lifecycle. Applies an Environment and Agent, starts one conversation, finds its sandbox as a directory on the runner with `just runner-sh`, writes a file into it, waits for the two-minute idle bound to park it, reads the `sandbox` stage event, wakes it with a follow-up prompt onto the same sandbox id with the file intact, then terminates it and shows the directory gone. Needs no inference key. Reuses `skills/start/check.sh`. | student run |
| `f3-egress-allowlist` | Fountain lesson 3, The egress allowlist. Applies a `limited` Environment with an empty `allowed_hosts`, watches `fountain run` fail to provision, reads the stage events naming `backend_lacks_network_policy` and `provider: runner`, repeats with a named host, then contrasts with an `unrestricted` environment that provisions. Needs no inference key. Reuses `skills/start/check.sh`. | student run |
| `f4-credentials-and-vaults` | Fountain lesson 4, Credentials and vaults. Applies an Environment and two Vaults overriding one key, then two Agents allowed one vault each by id, starts a conversation on each, reads the merged secret off the runner's disk with `just runner-sh`, gets a disallowed vault refused with a 422, hears the agent decline to print the value, empties an allowlist and sees a new conversation fall back to the environment's value while the parked one keeps the vault's. Four model turns. Reuses `skills/start/check.sh`. | student run |
| `f5-the-team` | Fountain lesson 5, The team. Adds an agent to the team with `curl`, keeps the team stream open, reads the roster and the channel-filtered conversation list as two views of one conversation, messages the teammate and gets a 400 for a second message mid-turn, adds the same agent again for a 200, lets it sleep and wakes it, stops the runner to read `machine_offline` and a queued message, and removes it to find the binding gone and the record kept. Three model turns. Reuses `skills/start/check.sh`. | student run |
| `f6-schedules` | Fountain lesson 6, Schedules. Gets `@reboot` refused, makes a disabled `@daily` schedule before the teammate exists and reads the `agent is not on the team` stamp a run leaves, adds the agent to the team, creates an every-minute schedule and catches the fire on the stream with `last_conversation_id` equal to the thread, disables it and runs it by hand, runs a one-off on a fresh sandbox with no channel, and removes the teammate to find its schedules gone. Three model turns. Reuses `skills/start/check.sh`. | student run |
| `f7-driving-an-agent-from-an-app` | Fountain lesson 7, Driving an agent from an app. Proves what `API_CORS_ORIGINS` admits with a preflight from the page's origin and one from an origin nobody named, applies the AWS desk's three objects from `desk/fountain.yaml` and puts it on the team with its vault bound, has the student sign in from the page and verifies the key it got lists as `oauth:aws-desk`, asks the desk what the estate holds and finds the fenced block in the conversation rather than on the screen, then renames the block on the page's half of the protocol and lets `just desk-check` refuse it. Has a browser in it, so the seeing is the student's and the verifying is the agent's. One model turn. Reuses `skills/start/check.sh`. | student run |
| `f8-propose-loop-interactive` | Fountain lesson 8, The propose loop interactive. Runs the whole loop with the desk from lesson 7. Plans the estate the repo declares and applies it on `APPROVE`, reads the account back by hand rather than trusting the reply, takes one grant request in plain words and reads the diff the desk made, deletes a grant in the account before approving so the plan comes back `stale` with the moved resource named and nothing applied, recovers with a re-plan, gets a boundary change refused, and ends by filling the eight parts for the desk against Mend and naming propose as the one that differs. Seven model turns. Reuses `skills/start/check.sh`. | student run |
| `f9-propose-loop-ambient` | Fountain lesson 9, The propose loop ambient. Seats the desk in repo mode, puts its watch on a cron, plants two kinds of drift in the account, fires the schedule and reads one pull request per drifted resource with no file change in any of them, closes one to prove a decline sticks and labels it `desk:reconsider` to let it be filed again, lowers `watcher_max_open_prs` on a reconcile branch so the `pr` job refuses a pull request the watcher was willing to open, and ends on the rules table with an enforcement column including the two rows where the answer is nothing. Needs a GitHub token the student mints. Three model turns. Reuses `skills/start/check.sh`. | student run |
| `i12-the-concierge` | IAM lesson 12, The concierge. Seats the desk in repo mode against the access repo, takes a request in plain words and reads the one-file pull request it opens, whose body marks the requester as an unverified claim, gets a refusal naming the enrolment path for an identity that appears in no principal's `teams`, then has the student make the identical edit by hand and compares the two `pr` jobs and their rendered deltas line by line, which is prescription 13 checked rather than asserted. Needs the desk's GitHub token. Two model turns. Reuses `skills/start/check.sh`. | student run |
| `f10-self-hosted-runner` | Fountain lesson 10, The self-hosted runner. Reads the runner from `GET /api/runners`, from `docker compose ps` and from inside its container as one process and one user holding the API key, replays the `limited` refusal, has a second sandbox list its sibling and reads both directories as one owner from the runner's shell, stops the container for a `409` on a new run and a `runner_offline` failure on a parked one, restarts it and prompts the same conversation, and fills the trade table. Three model turns. Reuses `skills/start/check.sh`. | student run |
| `f11-no-gate-in-fountain` | Fountain lesson 11, No approval gate in Fountain. Has an agent write a file with nobody asked, reads the runtime's command line off the runner mid-turn for `--allow-dangerously-skip-permissions`, pages the conversation's events and counts zero `request_permission` messages beside the `Write` tool call, asks for a deletion and hears the model decline on its own judgment, reads ADR 0016's status, and fills the gate table ending on `nothing` for the sandbox. Two model turns. Reuses `skills/start/check.sh`. | student run |
| `i1-one-type-per-file` | IAM lesson 1, One resource per file. Worktree at `checkpoint/i0`, builds `access/envs/prod` one resource block per file, `terraform fmt`, `init` and `validate`, then breaks the convention and shows Terraform accepting it. No Floci, no AWS. | student run |
| `i2-personas-and-principals` | IAM lesson 2, Personas and principals. Worktree at `checkpoint/i1`, replaces the raw role, policy and attachment with one `modules/persona` call, copies a sibling to make a second principal, adds the live-only humans, and fires both refusals. No Floci, no AWS. | student run |
| `i3-guardrails-in-the-editor` | IAM lesson 3, Guardrails in the editor. Worktree at `checkpoint/i2`, writes `.tflint.hcl`, the two layout rules and one security rule with its fixtures, brings in the rest of the pack and `scripts/check`, and breaks the estate four times to watch the right rule fire. No Floci, no AWS. | student run |
| `i4-deploy-to-floci` | IAM lesson 4, Deploy to Floci. Worktree at `checkpoint/i3`, starts the patched Floci image, `terraform apply` with no AWS account, `plan -detailed-exitcode` exits 0, `aws iam get-role` read back against the file, adds the credential-free plan stage to `access/scripts/check`. Reuses `skills/start/check.sh`. | student run |
| `i5-the-permission-boundary` | IAM lesson 5, The permission boundary. Worktree at `checkpoint/i4`, writes `access/baseline` with one estate boundary, applies it through `modules/persona`, exempts it from no-wildcard-action by tag with a fixture, promotes `boundary-required` from warning to error, applies and reads the boundary back out of the cloud. Reuses `skills/start/check.sh`. | student run |
| `i6-one-path-to-prod` | IAM lesson 6, One path to prod. Worktree at `checkpoint/i5`, copies the machinery it does not teach, writes the `waterpark-apply` role and its OIDC trust anchor, proves on Floci that it cannot detach its own boundary, generates `.github/CODEOWNERS` and fails a hand edit, writes the two-job workflow whose PR job holds no credential, and breaks the fork-PR property twice to watch `check workflow` catch both. Reuses `skills/start/check.sh`. | student run |
| `i7-drift` | IAM lesson 7, Drift. Worktree at `checkpoint/i6`, brings in `drift` and `reconcile`, fixes the wait loop in the scheduled job, seeds drift by hand with `detach-role-policy` and `tag-role`, reads a report naming the attribute with declared beside live, widens a trust policy to watch the severity route to a page, reads the reconcile plan under the Rounds rules, and states the asymmetry. Reuses `skills/start/check.sh`. | student run |
| `i8-delegation-and-the-double-refusal` | IAM lesson 8, Delegation and the double refusal. Worktree at `checkpoint/i7`, writes the `waterpark-runner` satellite root with its own registry and provider, moves `runner-builder` out of `envs/prod`, reads the central boundary live by name, reroutes its review through `codeowners.map`, mints a deploy credential conditioned on `iam:PermissionsBoundary`, then strips the boundary and gets refused by the rule pack at build and by IAM at apply. Reuses `skills/start/check.sh`. | student run |
| `i9-federation-trust` | IAM lesson 9, Federation trust. Worktree at `checkpoint/i8`, federates `site-publisher` through the GitHub Actions anchor with the `github-pages` environment as the exact subject, refuses a wildcard at validate, writes `trust.rego` and the subject fixtures, brings in the audience fixtures and the rotation machinery, pages on a hand-edited trust policy and a widened anchor, runs `rotation` clean and then against a hand-made key under a zero window, forges a token to show the emulator failing open, and closes the workflow-level gap in `check workflow`. Reuses `skills/start/check.sh`. | student run |
| `i10-break-glass` | IAM lesson 10, Break-glass. Worktree at `checkpoint/i9`, brings in the grant shape and the TTL rule, writes the `on-call` stand-in, grants prod write for two minutes with `access/scripts/break-glass`, reads the `DateLessThan` condition and the tags back, gets a three-hour grant refused by the script, the rule pack and `plan`, leaves the cleanup unrun past the expiry, watches `drift` report the leftover, sweeps and revokes, and reads the apply job's approver stamp. Reuses `skills/start/check.sh`. | student run |
| `i11-offboard-and-access-review` | IAM lesson 11, Offboard and the access review. Worktree at `checkpoint/i10`, brings in the four read-side scripts and the quarterly workflow, asks `whocan` and `expiring` against the account and watches a console-attached policy appear, reads the review artifact, offboards `course-author` with the preview reading nothing live and the grep reading zero, offboards `desk-operator` with a five-resource destroy and a `NoSuchEntity` read back, and restores both from the checkpoint. Reuses `skills/start/check.sh`. | student run |
| `i15-adopt-in-place` | IAM lesson 15, Adopt in place. Worktree at `checkpoint/i11`, makes a role, a bucket and an open security group by hand, watches `drift` not see them, adopts the role with an import block and a resource block reviewed out of `-generate-config-out`, proves with `adopt-check` that only the estate's tags change and watches it fail a misstated file, adopts the other two, watches the rule pack fail the adopted role and warn on the group, backs the group out with a `removed` block, and says what walking away costs. Reuses `skills/start/check.sh`. | student run |
| `i14-approve-the-change-not-the-diff` | IAM lesson 14, Approve the change, not the diff. Worktree at `checkpoint/i15`, reads the two jobs' digest steps and the unconfigured `prod` environment, saves a plan and reads its delta and digest, tags the role by hand to watch the digest change with the diff naming `tags`, applies and watches Terraform refuse the stale saved plan, plans one in-place change from two emulators for one digest against the old digest's two, renames a role to read the replacements section, and says what the digest cannot say. No model turns. Reuses `skills/start/check.sh`. | student run |
