# github

The code host's own protection, declared as code. Branch protection on
`main`, the PR job as a required status check, one required review routed by
CODEOWNERS, and no force push.

This is not a second estate. Merge rights are grant rights, so the rules that
decide who can merge belong in the repo that manages access (decision 19,
threat-model boundary 1). Application-level authorization stays out of scope.

## Live only, like identity

There is no emulator for a code host. This root is validated and linted on
every run of `access/scripts/check` and it is never applied on the solo path,
the same way `access/identity` is never applied on the solo path because
Floci runs no Identity Center. That is the honest version of the rule, rather
than a softened one that happens to run on a laptop.

```sh
terraform -chdir=access/github init -backend=false
terraform -chdir=access/github validate
```

The live path needs a `GITHUB_TOKEN` with admin rights on the repository, and
the provider reads it from the environment rather than from a variable,
because a variable is a thing a plan can print.

```sh
GITHUB_TOKEN=... terraform -chdir=access/github init
GITHUB_TOKEN=... terraform -chdir=access/github plan
```

## What it protects, and what watches it

`required_check` is the name of the `pr` job in
`.github/workflows/access.yml`, and `protected_branch` is the same string the
apply role's OIDC subject pins in
`access/envs/prod/iam_role.waterpark_apply.tf`. If those two ever disagree,
the write path has two doors and only one of them is guarded, so both are
outputs here and a live read compares them.

The drift watch covers this root the same way it covers the estate, which is
how a settings-page edit that turns off `enforce_admins` shows up as a finding
rather than as nothing. On the solo path there is nothing live to compare
against, so `access/scripts/drift` skips it by name.

## The cost

Declaring protection as code means the token that applies it can also remove
it. That is why the apply of this root is a human running a command with a
personal token, not a job holding a credential, and why the boundary the
estate carries has no analogue here. The code host is the trust root of the
whole pattern, and the pattern does not pretend to guard its own trust root.
