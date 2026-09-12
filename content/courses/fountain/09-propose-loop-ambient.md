---
title: "The propose loop, ambient"
id: "F9"
lesson: 9
weight: 9
summary: "The same loop with nobody watching, and the rules that have to hold anyway."
# skill. a directory in this repo with a SKILL.md that drives the lesson. empty renders nothing
skill: "skills/f9-propose-loop-ambient"
# card. empty renders as TODO
goal: "Put the desk's watch on a schedule and let it run with nobody in the room. Move the account by hand, watch the run open one pull request per drifted resource with no file change in any of them, close one to say no, and watch the next run take no for an answer. Label it so it can ask again. Then lower the cap and watch the gate in CI refuse a pull request the watcher was perfectly willing to open, and fill in the rules table with a column saying where each rule is actually enforced."
done_when: >-
  A schedule you created runs the watch in the teammate's own thread and its
  `aws-drift` block names the drift you planted, one pull request exists per
  drifted resource and none of them changes a file, a pull request you closed
  is reported as declined on the next run rather than opened again, the same
  finding is filed once you label it `desk:reconsider`, a pull request carrying
  the reconcile marker fails its own `pr` job when the cap in `access/baseline`
  is below the number already open, and your rules table names, for each rule,
  the thing that would still enforce it with the prompt ignored.
restart_from: "lesson 8, with the desk on the team"
properties: ["XIII", "IV", "IX"]
# activity. kind is hands-on, watch-along or discuss
activity:
  kind: hands-on
  time: "60 min"
  needs: ["lesson 8 finished", "the desk seated in repo mode, which needs a GitHub token in its vault", "an inference key set, this lesson makes three model turns", "jq, curl and the AWS CLI"]
  solo: true
  live: true
---

## Context

- Ambient is the same eight parts as lesson 8 with one part missing. Nobody is in the room, so propose cannot be a person, and everything that a person would have caught has to be somewhere else. [The propose loop](../../propose-loop.md) has Rounds in the column beside Mend, and Rounds is the app this lesson's rules come from.
- The read is `access/scripts/drift`, which is `terraform plan -detailed-exitcode` per root with the plan JSON read down to attributes. Exit 0 matches, exit 2 is drift, exit 1 is the watch itself broken, which is a different thing and reported as such.
- Two things are drift that a plan alone would not call drift. A grant whose expiry has passed is drift, because the cloud has stopped honouring it while the repo still says it exists. And a root that will not plan at all is drift, because the estate cannot be compared to anything.
- The propose step is `access/scripts/reconcile`, and the rules are in that script rather than in the desk's prompt on purpose. One pull request per resource, never a second while one is open, at most `watcher_max_open_prs` from `access/baseline`, a marker in every body, and a finding whose severity is `page` refused rather than filed as paperwork.
- A reconcile pull request carries no file change. The repo already declares what the resource should be, so merging it is what runs the apply that puts the account back. The empty diff is the point and it looks like a mistake until somebody says so.
- The watcher never adopts. If the change in the account was the right one, the file that declares the resource has to be edited, and that is a request somebody makes rather than something a watcher infers. A watcher that adopted would ratify every change anybody made by hand, which is the opposite of managing what you declare, and that is Accessible Ops XIII.
- State is the quiet prerequisite. A scheduled run wakes on whatever computer it is given, and a computer with no state plans to create an estate that already exists, so the desk keeps state in a bucket rather than in a directory.

## Do

Lesson 8 had you in the room for every step. This one takes you out of it.

1. Seat the desk in repo mode, because a watcher with a credential that writes to the account is not a watcher, it is an unattended operator.

   ```sh
   just desk-hire repo
   ```

   That needs a GitHub token in the `aws-desk-github` vault. The Self-paced section says what kind and why it is the only credential this lesson hands out.

2. Give it a schedule. Five cron fields, UTC, the same call lesson 6 made.

   ```sh
   KEY=$(grep '^FOUNTAIN_API_KEY=' compose/.env | cut -d= -f2-)
   AGENT=$(curl -s -H "Authorization: Bearer $KEY" http://localhost:4000/api/team |
     jq -r '.data[]|select(.agent.name=="aws-desk")|.agent_id')
   curl -s -X POST -H "Authorization: Bearer $KEY" -H 'Content-Type: application/json' \
     -d '{"cron":"0 6 * * 1-5","prompt":"Run the watch and propose what it finds.","name":"The drift watch"}' \
     "http://localhost:4000/api/team/$AGENT/schedules" | jq -r '.data.id'
   ```

   Weekdays at six in the morning, which you are not going to wait for. Keep the id.

3. Move the account by hand, which is what the watch exists to find. Two edits, one changing a role and one deleting a grant. Two edits are not two findings, because deleting a policy drifts the policy and the attachment that held it, so expect three.

   ```sh
   export AWS_ENDPOINT_URL=http://localhost:4566 AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1
   aws iam tag-role --role-name on-call --tags Key=owner,Value=whoever
   ARN=$(aws iam list-policies --scope Local \
     --query 'Policies[?PolicyName==`desk-operator-list-waterpark-artifacts`].Arn' --output text)
   aws iam detach-role-policy --role-name desk-operator --policy-arn "$ARN"
   aws iam delete-policy --policy-arn "$ARN"
   ```

4. Run the schedule now rather than waiting for six in the morning.

   ```sh
   curl -s -X POST -H "Authorization: Bearer $KEY" \
     "http://localhost:4000/api/team/$AGENT/schedules/<the id>/run" | jq -c .
   ```

   The prompt lands in the teammate's own thread as though you had typed it, which is what makes a scheduled run auditable rather than invisible. Watch the `aws-drift` block arrive in the Drift pane, then look at what it opened.

   ```sh
   gh pr list --state open --json number,title,files \
     --jq '.[]|"\(.number) \(.title)  files \(.files|length)"'
   ```

   One pull request per drifted resource, three of them, and `files 0` on every one.

   `gh` takes the repository from your clone's `origin`. If yours does not point at your fork on GitHub, say which repository you mean with `-R <owner>/<repo>` on every `gh` command in this lesson, and use the GitHub URL rather than `origin` in step 7. A push to the wrong remote is the worst version of this, because it succeeds and then no job ever runs.

5. Say no to one of them, the way a person actually says no, by closing it.

   ```sh
   gh pr close <number> --comment "The tag change was deliberate."
   ```

6. Run the schedule again and read what it says about the one you closed.

   It reports that finding as declined and does not open it again. A watcher that refiled what somebody closed is a watcher that argues, and nobody keeps one of those. The way back in is a label rather than a reopened branch, because a label is a deliberate act by somebody with write access.

   ```sh
   gh pr edit <number> --add-label desk:reconsider
   ```

   Run it once more and the finding is filed again.

7. Now break the rule on purpose, from the other side. The cap says at most five open, and the watcher is the thing that is supposed to respect it. Find out what happens when it does not.

   Take one of the open reconcile pull requests, and on its branch lower the cap below the number currently open.

   ```sh
   git fetch origin <the branch> && git checkout -b cap-probe origin/<the branch>
   sed -i.bak 's/watcher_max_open_prs      = 5/watcher_max_open_prs      = 1/' access/baseline/locals.tf
   rm -f access/baseline/locals.tf.bak
   git commit -am "probe: lower the cap below what is open" && git push origin HEAD:<the branch>
   ```

   Delete the schedule first, or make it again afterwards. The watcher rewrites its own `desk/drift` branches, so a run that fires between your push and the job finishing overwrites your probe and the failure you are waiting for never happens.

   Its own `pr` job fails, and the message names the count and the cap. Give it eight minutes or so, because that job applies the base branch into its own account and runs the whole check stack before it gets anywhere near the cap.

   ```
   cap 1, open reconcile PRs 3
   The watcher has 3 open reconcile pull requests and the cap in
   access/baseline is 1. Close or merge one before this lands (decision 40).
   ```

   Read what that proves. The cap was not enforced by the watcher agreeing to it. The watcher had already opened them, and the gate refused anyway. Put the cap back.

8. Fill in the table. Take the rules from this lesson and write the third column yourself.

   | Rule | Where the watcher is told | What enforces it with the prompt ignored |
   |---|---|---|
   | one pull request per resource | `reconcile` | the branch name is derived from the address, so a second one collides |
   | never a second while one is open | `reconcile` | the open-pull-request lookup, every run |
   | a decline sticks | `reconcile` | the closed pull request, until somebody labels it |
   | at most five open | `access/baseline` | the `pr` job's own cap step, on the pull request itself |
   | never adopt what it found | the prompt | nothing. See below |
   | a page is not a pull request | `reconcile` | half of it. See below |

   Two of those rows are the point of the exercise. Write a sentence for each saying what it would take to move it, and what that would cost.

   The second one is worth being precise about. `reconcile` does filter on severity, so a `page` finding genuinely cannot be filed as paperwork, and that half holds with the prompt ignored. What nothing enforces is that anybody hears it. The finding is printed inside a sandbox at six in the morning and the sandbox goes away, so an unread page and no watcher at all look identical from outside.

## Self-paced

Everything runs on the Start-here stack, with one credential you have to make yourself. Repo mode needs a fine-grained GitHub token with contents and pull requests on your own copy of this repo and nothing else, because the whole claim of repo mode is that the desk holds nothing that can reach AWS. A classic token with `repo` scope will work and will also reach every repository you can reach, which is the blast radius this course spends a chapter arguing against.

What Floci cannot show. The apply that a merged reconcile pull request triggers runs in the job's own emulator, not in the one on your laptop, so merging one of these does not put your account back. On a real estate those are the same account and the loop closes. Here the loop closes everywhere except the last inch, and the honest thing is to notice that rather than to pretend.

The account's own drift is therefore yours to undo. Seat the desk in direct mode and ask it to plan and apply, or recreate Floci and start the estate again.

## Live

Twenty five minutes, and step 6 is the one to slow down for. Run the schedule, let the pull requests appear on the screen, and close one in front of the room while saying out loud that you are a person disagreeing with a robot. Run it again and let the decline land.

Say this when the cap refuses in step 7.

Every rule in the left column is a sentence somebody wrote in a prompt. The only ones that will still be true in a year are the ones in the right column, because those are the ones that do not depend on the agent having read them.

## Further reading

- [The propose loop](../../propose-loop.md), Rounds' column in particular
- [The AWS desk](../../docs/aws-desk.md), the watch section
- `access/scripts/reconcile` and `access/scripts/drift` in this repo
- Rounds README, for the same rules on a different target
