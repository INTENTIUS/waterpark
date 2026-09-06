# identity

The human principals. Humans get Identity Center permission sets and
workloads get IAM roles, and there are no IAM users and no IAM groups
(decision 5, prescription 3).

This root is live only. Identity Center lives in `waterpark-mgmt` and Floci
does not run it, so the checks validate this directory on every run and only
a real account ever plans or applies it. That is the honest version of
prescription 3 on the solo path. The rule is not softened for the emulator,
the half that needs a real org is marked as needing one.

```sh
terraform -chdir=access/identity init -backend=false
terraform -chdir=access/identity validate
```

`platform` is on the `platform` persona and `course-author` is on `reader`,
per [design/personas](../../content/docs/design/personas.md). Each file is one
module call and nothing else.
