# .tflint.d

The rule pack, and the contract a satellite consumes it under.

The rules themselves are Rego under `policies/`, run by
[tflint-ruleset-opa](https://github.com/terraform-linters/tflint-ruleset-opa)
(decision 47). The table of what each one fails is in
[the access README](../README.md).

## Severity is the function-name prefix, and that is the versioning policy

`deny_` is an error and `warn_` is a warning. That is not a formatting
convention, it is how an upgrade reaches a satellite without breaking it
(decision 9).

A new rule lands as `warn_`. Every satellite that pins a ref carrying it sees
the finding, in the editor and in its own PR job, and nothing fails. The rule
becomes `deny_` at a later ref, by which time the estate it applies to has
had a full cycle to conform. Promoting is the one-word edit from `warn_` to
`deny_` plus the matching line in `access/scripts/check`.

`boundary-required` is the worked example. It landed as a warning in lesson 3,
because the boundary it asks for did not exist yet, and lesson 5 promoted it
to an error once every role carried one. Lesson 6 widened it to cover a
principal file that makes a role through a module, which is what a satellite
writes.

## The tagging convention, which is what warn-minor and error-major became

The shared module was going to be a registry module with a semver number, and
in this repo it is a directory consumed by a pinned git ref instead (decisions
49 and 50). So the semver contract is spelled as tags rather than as version
constraints.

| Change | Tag it lands on | What a satellite sees |
|---|---|---|
| a new `warn_` rule | any tag | a warning, and a green build |
| a `warn_` promoted to `deny_` | a tag a satellite must move to deliberately | a failing build, after a cycle of warnings |
| a rule message or a fix suggestion | any tag | better wording, same verdict |
| an emergency `deny_` on an actively exploited pattern | any tag, with a changelog entry naming why | a failing build with no warn cycle, and this is rare by policy |

A satellite pins the ref in two places, the module source in its principal
file and the vendored pack its `.tflint.hcl` points at, and both move together
in one PR. That PR is planned like any other change, so a bump shows exactly
which new warnings appear before anything is merged.

## Ratchet baselines

Not built. `tflint` has no first-class baseline file, so recording
pre-existing violations in a shrink-only checked-in file means wrapping
`tflint --format=json`, which
[guardrail-rollout](../../content/docs/design/guardrail-rollout.md) already
names as a spike. This estate has nothing to ratchet against, because every
rule was green before it was promoted. A satellite with a real backlog needs
the wrapper, and the design doc is where it is designed.

## Fixtures

Every rule has a failing and a passing case under `../tests/fixtures`, and
`access/scripts/check fixtures` runs each pair with `--only` set to that one
rule, so a fixture proves its own rule and nothing else. A rule change without
a fixture change is a rule nobody tested.
