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

| Skill | Drives | State |
|---|---|---|
| `start` | Start here. Clone water park, install and log in to Fountain, Floci for self-paced. macOS, Linux and Windows, OS install or Docker where both exist. `check.sh` and `check.ps1`. | first draft |
| `f1-four-primitives` | Fountain lesson 1, Four primitives. Writes an Environment/Vault/Agent manifest, `fountain apply -f`, reads secret keys back with no values, starts a conversation, re-applies for idempotence. Reuses `skills/start/check.sh`. | first draft |
| `i1-one-type-per-file` | IAM lesson 1, One resource per file. Worktree at `checkpoint/i0`, builds `access/envs/prod` one resource block per file, `terraform fmt`, `init` and `validate`, then breaks the convention and shows Terraform accepting it. No Floci, no AWS. | first draft |
| `i2-personas-and-principals` | IAM lesson 2, Personas and principals. Worktree at `checkpoint/i1`, replaces the raw role, policy and attachment with one `modules/persona` call, copies a sibling to make a second principal, adds the live-only humans, and fires both refusals. No Floci, no AWS. | first draft |
| `i3-guardrails-in-the-editor` | IAM lesson 3, Guardrails in the editor. Worktree at `checkpoint/i2`, writes `.tflint.hcl`, the two layout rules and one security rule with its fixtures, brings in the rest of the pack and `scripts/check`, and breaks the estate four times to watch the right rule fire. No Floci, no AWS. | first draft |
| `i4-deploy-to-floci` | IAM lesson 4, Deploy to Floci. Worktree at `checkpoint/i3`, starts the patched Floci image, `terraform apply` with no AWS account, `plan -detailed-exitcode` exits 0, `aws iam get-role` read back against the file, adds the credential-free plan stage to `access/scripts/check`. Reuses `skills/start/check.sh`. | first draft |
| `i5-the-permission-boundary` | IAM lesson 5, The permission boundary. Worktree at `checkpoint/i4`, writes `access/baseline` with one estate boundary, applies it through `modules/persona`, exempts it from no-wildcard-action by tag with a fixture, promotes `boundary-required` from warning to error, applies and reads the boundary back out of the cloud. Reuses `skills/start/check.sh`. | first draft |
| `i6-one-path-to-prod` | IAM lesson 6, One path to prod. Worktree at `checkpoint/i5`, copies the machinery it does not teach, writes the `waterpark-apply` role and its OIDC trust anchor, proves on Floci that it cannot detach its own boundary, generates `.github/CODEOWNERS` and fails a hand edit, writes the two-job workflow whose PR job holds no credential, and breaks the fork-PR property twice to watch `check workflow` catch both. Reuses `skills/start/check.sh`. | first draft |
| `i8-delegation-and-the-double-refusal` | IAM lesson 8, Delegation and the double refusal. Worktree at `checkpoint/i7`, writes the `waterpark-runner` satellite root with its own registry and provider, moves `runner-builder` out of `envs/prod`, reads the central boundary live by name, reroutes its review through `codeowners.map`, mints a deploy credential conditioned on `iam:PermissionsBoundary`, then strips the boundary and gets refused by the rule pack at build and by IAM at apply. Reuses `skills/start/check.sh`. | first draft |
