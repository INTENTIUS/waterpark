---
title: "The watcher"
id: "I13"
lesson: 13
weight: 13
summary: "The desk on a schedule turns findings into capped PRs."
# skill. a directory in this repo with a SKILL.md that drives the lesson. empty renders nothing
skill: "skills/i13-the-watcher"
# card. empty renders as TODO
goal: "Point the watcher from Fountain lesson 9 at this estate's own projections. Read what the account says about grants that are expiring, secrets that are old and who can reach what, then leave a break-glass grant lying around past its expiry and watch the sweep file a pull request that deletes it rather than one that restores anything. Put that beside a reconcile pull request until you can say which way each one pushes and why the difference is the whole job. Then find out whether the cap counts both of them, and ask the conversation record which requests the concierge handled."
done_when: >-
  `access/scripts/expiring`, `access/scripts/rotation` and
  `access/scripts/access-review` each answer from the account rather than from
  a file, a grant left past its expiry produces a sweep pull request whose diff
  removes the block while a drifted resource produces a reconcile pull request
  whose diff is empty, the `pr` job's cap counts both kinds against the one
  number in `access/baseline`, and `GET /api/search` returns the conversation
  where the concierge handled a request you can name.
restart_from: "lesson 12, with the desk on the team and Fountain lesson 9 done"
properties: ["XIII"]
# activity. kind is hands-on, watch-along or discuss
activity:
  kind: hands-on
  time: "40 min"
  needs: ["lesson 12 finished and Fountain lesson 9 done, so the watcher and its rules are familiar", "the desk's GitHub token in its vault", "an inference key set, this lesson makes one model turn", "jq, curl, gh and the AWS CLI"]
  solo: true
  live: true
---

## Context

- Fountain lesson 9 built the watcher and its rules. This lesson points it at what IAM has that a generic target does not, which is a set of projections over the account. Nothing here is a new mechanism.
- Drift is the account moving. Burndown is the clock moving. A reconcile pull request restores what the repo declares and carries no file change, and a sweep pull request removes what the repo declares and carries a real one. They arrive in the same list looking alike and they push in opposite directions.
- The projections read the account and never a file, which is Accessible Ops XI. `expiring` lists dated grants soonest first, `rotation` finds static secrets past their age, and `access-review` is the artifact a compliance reviewer accepts, saying where each fact came from and naming what it did not see.
- A grant past its expiry grants nothing, because the cloud stopped honouring it at the date in its condition. What is left is paperwork, and the paperwork is what the sweep retires. A grant that was applied before it expired arrives by two roads, since the drift watch reports it as an `expired-grant` finding as well. One that was never applied arrives by one road only, and step 3 is where you find out which road that is.
- The cap is on the watcher rather than on a script. The `pr` job counts every open pull request carrying any of the watcher's markers against `watcher_max_open_prs` in `access/baseline`, so a watcher that filed five reconciles and five sweeps is over the cap, not twice under it.
- The conversation is the record for requests and the code host is the record for changes. `GET /api/search` searches the first, which is how "which requests did the concierge handle" is a query rather than an archaeology project.
- Rounds as-is covers the lint tier on this repository. The IAM projections use its form rather than its code, which is decision 28.

## Do

Lesson 12 put an agent in front of the pipeline. This one leaves it running and asks what it should be looking at.

1. Read the three projections, and notice they ask the account rather than the repo.

   ```sh
   export AWS_ENDPOINT_URL=http://localhost:4566 AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1
   access/scripts/expiring
   access/scripts/rotation
   access/scripts/access-review | head -40
   ```

   The review says what it could not see as plainly as what it could. That is what makes it an artifact rather than a dashboard, and the sentence naming the unused-access analyzer it could not reach is the most useful line in it.

2. Leave something lying around. Put a break-glass grant on `on-call` whose expiry has already passed, the way lesson 10's grant would look if nobody had swept it.

   Put this in `access/envs/prod/iam_role.on_call.tf` in place of `grants = []`, with the two dates moved to three hours ago and one hour ago. The marker comments are not decoration. `break-glass` parses the id out of the opening one as the third whitespace-separated field, and it has to begin with `bg-`, so a fence written any other way leaves `list` and `sweep` finding nothing at all.

   ```hcl
   grants = [
     # break-glass bg-on-call-drill. Written by access/scripts/break-glass, revoked by its sweep.
     {
       resource   = "waterpark-artifacts"
       access     = "write"
       granted_at = "<three hours ago, RFC3339>"
       expires    = "<one hour ago, RFC3339>"
       reason     = "An incident grant nobody swept, left past its expiry on purpose."
     },
     # end break-glass bg-on-call-drill
   ]
   ```

   Those two hours are not a suggestion. `break_glass_max_ttl_hours` in `access/baseline` is 2 and the module refuses a longer window, so three hours ago to one hour ago sits exactly on the line. Move one of them and you are choosing between a grant that has not expired yet and a grant `terraform validate` rejects.

   Run `access/scripts/check lint` before you commit, because the script normally runs `terraform fmt` after writing a block and your hand does not.

   Then commit it on a branch, open a pull request and merge it, because a burndown removes what the base branch declares and there is nothing to remove until the base declares it. Merge with `gh pr merge <number> --squash --delete-branch`, which also puts you back on `main`, and being on `main` is what the next step needs.

   Watch what the checks say about that pull request on the way through. They pass. Nothing refuses a grant that is already dead, because a check cannot know when somebody will merge it, and the rule it would have to break is about the length of the window rather than about where the window sits. What catches it is the thing that runs afterwards, which is this lesson.

3. Ask the account what it thinks.

   ```sh
   access/scripts/expiring
   ```

   Nothing, and the reason is worth more than the finding. The grant was never applied, so the account never had it, and a projection that reads the account is right to say so. Two facts are hiding in that, which are that the repo can declare access the account does not hold, and that a projection over the account will not find paperwork. The sweep reads the files for exactly this reason.

4. Sweep it, standing on `main`.

   Which branch you are on decides what the sweep's pull request says. It branches from where you are, and a branch that is not the base makes a diff that reads as adding the grant rather than removing it. The script says as much in its own comments, having done it.

   ```sh
   git branch --show-current
   access/scripts/break-glass sweep
   ```

   The dry run names the file and the branch it would use. Then file it.

   ```sh
   access/scripts/break-glass sweep --open
   ```

   Read the pull request it opened.

   ```sh
   gh pr diff <number> | head -20
   ```

   The diff removes the block. Put that beside a reconcile pull request from Fountain lesson 9, whose diff was empty, and say which way each one pushes. The reconcile one asks the account to go back to what the repo says. This one asks the repo to stop saying something the account already stopped doing.

5. Find out whether the cap knows about both.

   The sweep files under its own marker and reconcile files under another. Look at what the `pr` job counts.

   ```sh
   grep -n 'markers=' .github/workflows/access.yml
   ```

   Both, and `desk-proposed` besides. Say why that matters. A cap that counted one kind would let a watcher hold five reconciles and five sweeps while the constant in `access/baseline` says five, and the number a person set would mean something other than what it says.

6. Ask the record what the concierge did.

   ```sh
   KEY=$(grep '^FOUNTAIN_API_KEY=' compose/.env | cut -d= -f2-)
   curl -s -H "Authorization: Bearer $KEY" \
     "http://localhost:4000/api/search?q=waterpark-artifacts" |
     jq -r '.data[]? | "\(.kind)  \(.snippet[0:70])"'
   ```

   The request you made in lesson 12 comes back as a `reply` row with the words in its snippet. The conversation is the record for requests and the code host is the record for changes, and neither one is trying to be the other. Search reads the first, which is why this is a query rather than an afternoon of scrolling.

7. Fill in the last column, one more time. Fountain lesson 9's table had a rule per row and a column for what enforces it. Add the rows this lesson adds.

   | Rule | Where the watcher is told | What enforces it |
   |---|---|---|
   | a burndown removes, a reconcile restores | `break-glass` and `reconcile` are separate scripts | the diff, which a reviewer reads |
   | the cap covers every kind the watcher files | `access/baseline` | the `pr` job, counting every marker |
   | a projection reads the account | `lib-live.sh`, which every read script sources | nothing, and see below |

   The `apply` job shows `skipping` on both of your pull requests, which is the pipeline working. It runs on a push to `main` and never on a pull request, which is lesson 6's whole shape.

   That last row is worth sitting with. Every read script goes through one helper that talks to the account, and a script that read a state file instead would still pass every check in this repository. What keeps the projections honest is that they were written that way, which is a convention rather than a control.

   Work out what it would cost to change that, in tiers, because the tiers are the interesting part. A grep gate that lets only the helper name an endpoint is an afternoon and catches carelessness. A negative test per projection, pointed at a dead endpoint and expecting a named failure, is ongoing work forever and catches laziness. Neither catches a script that reads the account and then prints something else, and closing that means a fixture per projection, seeded into the emulator and asserted in the output. The estate stopped at the convention because the first two tiers cost more than the failure they prevent, given that a wrong projection still has to get past somebody reading the artifact.

## Self-paced

Everything runs on the Start-here stack against your own copy of this repo.

What Floci cannot show. Access Analyzer answers no policy API, so the unused-access findings that a real watcher would file are absent, and `access-review` says so in the artifact rather than leaving a gap. On a real account that analyzer is what turns "nobody has used this grant in ninety days" into a pull request, and it is the projection with the best claim to being the reason a watcher exists at all.

The apply gap from Fountain lesson 9 is here too. Merging a sweep pull request removes the grant from the repo and the apply job runs against the job's own emulator, so your laptop's account is unchanged either way. In this case that matters less than usual, because the cloud already stopped honouring the grant at its expiry and the paperwork was all that was left.

## Live

Twenty minutes. Show step 4's two diffs side by side on one screen, the empty one and the one that deletes, and let the room work out which is which before you say. Then step 5.

Say this at the end.

The watcher's job is not to fix things. It is to make sure that everything that is wrong is written down somewhere a person will look, in a form that says which way it needs to move.

## Further reading

- [The propose loop](../../propose-loop.md), Rounds' column
- [The AWS desk](../../docs/aws-desk.md), the watch section
- [Prescriptions](../../docs/prescriptions.md), 9 and 11
- `access/scripts/expiring`, `rotation`, `access-review` and `break-glass` in this repo
