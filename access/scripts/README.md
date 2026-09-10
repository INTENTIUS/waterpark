# scripts

Every script here runs the same way in an editor, from an agent and in CI,
and produces the same output. That is prescription 4, and it is why the CI
jobs are thin wrappers around these rather than shell embedded in YAML.

| Script | What it does | Lesson |
|---|---|---|
| `backend` | swap an env between the local and the S3 backend | 4 |
| `check` | the whole check stack, in the order CI runs it | 3 |
| `gen-codeowners` | emit `.github/CODEOWNERS` from the principal files | 6 |
| `plan-digest` | the digest an approval binds to | 6 |
| `render-delta` | plan JSON to the semantic access delta | 6 |
| `proofs` | Access Analyzer, when it answers | 6 |
| `prove-no-detach` | the apply role cannot detach its boundary | 6 |
| `drift` | declared against live, over every root that applies | 7 |
| `reconcile` | a drift report to reconcile PRs, under Rounds rules | 7 |
| `satellite-source` | swap the satellite between the local and the git module source | 8 |
| `mint-satellite-credential` | the satellite deploy credential, on Floci | 8 |
| `double-refusal` | strip the boundary, get refused twice | 8 |
| `rotation` | every static secret the account holds, with its age against the window | 9 |
| `break-glass` | grant, list, revoke and sweep a break-glass grant, by marker in the principal file | 10 |

None of them holds a credential of its own. The four that talk to an account
take the throwaway `test` key pair against Floci by default, and the two that
talk to the code host use whatever `gh` is already authenticated as.

## The asymmetry, which is what lesson 7 is about

Restoring is automatic and adopting is not.

When the account moves away from what the repo declares, `drift` reports it
and `reconcile` files one PR per resource that restores the declared state.
That PR carries no file change at all, because the repo already says what the
resource should be. Its whole job is to be merged so the apply runs.

When the change in the account was the right one, nothing automatic happens
and nothing should. Somebody decided that change was right, and the way to
keep it is for a human to edit the file that declares the resource so the
repo says it too. A watcher that could adopt would be a watcher that
ratifies whatever happened, and water park manages what it declares
(decision 3, Accessible Ops XIII).

So the two directions are deliberately unequal in effort. Putting the estate
back is a merge. Changing what the estate is takes a diff somebody wrote.

## Rounds rules, and where each one is enforced

`reconcile` follows decision 28, and each rule is held by a mechanism rather
than by the prompt that asks for it.

| Rule | Held by |
|---|---|
| owned resources only | the input, since a plan over a root this repo declares cannot contain a resource nobody here declared |
| one PR per resource | the branch name is derived from the resource address |
| never a second while one is open | an open PR on that branch is a skip |
| capped in volume | `watcher_max_open_prs` in `access/baseline`, read rather than restated |
| a marker in the body | so the count above can find them again next cycle |
| a page is not paperwork | a `page` severity finding is printed for a human and never filed |

Closing a reconcile PR unmerged is a no for that finding, and the label that
reopens the question is `desk:reconsider`. That half lives with the watcher in
lesson 13, because it needs something standing to remember the decline.
