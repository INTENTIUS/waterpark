---
name: waterpark-f9-propose-loop-ambient
description: Walk a student through Fountain lesson 9, The propose loop ambient. Use when they want lesson 9, or when they ask how an agent runs with nobody watching, what Rounds' rules are, or where a rule is actually enforced. Puts the desk's watch on a schedule, plants drift in the account, runs the schedule and reads the pull requests it opens with no file change in any of them, closes one to prove a decline sticks, labels it to let it ask again, lowers the cap so the gate refuses a pull request the watcher was willing to open, and ends on the rules table with an enforcement column. Three model turns.
---

# water park, Fountain lesson 9, The propose loop ambient

You are walking a student through Fountain lesson 9, The propose loop ambient
(https://intentius.io/waterpark/courses/fountain/09-propose-loop-ambient/).
The outcome is the same loop as lesson 8 with nobody in the room, and an
honest table of which rules survive the prompt being ignored. About an hour.

This lesson needs lesson 8 finished and the desk on the team. It also needs a
GitHub token, which the student mints and pastes and you never see. If the
`aws-desk-github` vault holds no `GITHUB_TOKEN`, `just desk-hire repo` says
so and stops, and that is where you stop too.

Confirm before seating the desk in repo mode, before planting drift in step 3,
before closing a pull request in step 5, and before pushing the cap probe in
step 7. Those are marked **confirm**. Reads run freely.

Three model turns, all of them the schedule firing. Say so before the first.

The student may watch from the page at http://localhost:1313/desk/, where the
Drift pane fills, or from a terminal. The terminal path is the same three
calls lesson 8's skill spells out, and `just desk-hire` prints both ids.

## 1. Say what this is

In two or three sentences say this is lesson 9. Ambient is the same eight
parts as lesson 8 with the person taken out, so propose cannot be a person and
every rule a person would have enforced has to live somewhere that still works
at six in the morning. Link the lesson page.

## 2. Check the ground, and seat the desk **confirm**

```sh
bash skills/start/check.sh
just desk-hire repo
```

If that stops on a missing `GITHUB_TOKEN`, read the student the instruction it
printed and stop. A token is theirs to mint. Tell them what kind, which is
fine-grained, contents and pull requests, one repository, and why, which is
that repo mode's whole claim is a desk holding nothing that reaches AWS.

## 3. The schedule

```sh
KEY=$(grep '^FOUNTAIN_API_KEY=' compose/.env | cut -d= -f2-)
AGENT=$(curl -s -H "Authorization: Bearer $KEY" http://localhost:4000/api/team |
  jq -r '.data[]|select(.agent.name=="aws-desk")|.agent_id')
curl -s -X POST -H "Authorization: Bearer $KEY" -H 'Content-Type: application/json' \
  -d '{"cron":"0 6 * * 1-5","prompt":"Run the watch and propose what it finds.","name":"The drift watch"}' \
  "http://localhost:4000/api/team/$AGENT/schedules" | jq -r '.data.id'
```

Keep the id. Point out that the prompt is a sentence, not a command, and that
it lands in the teammate's own thread when it fires, which is what makes an
unattended run auditable rather than invisible.

## 4. Plant drift **confirm**

Two kinds, because they read differently in the report.

```sh
export AWS_ENDPOINT_URL=http://localhost:4566 AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1
aws iam tag-role --role-name on-call --tags Key=owner,Value=whoever
ARN=$(aws iam list-policies --scope Local \
  --query 'Policies[?PolicyName==`desk-operator-list-waterpark-artifacts`].Arn' --output text)
aws iam detach-role-policy --role-name desk-operator --policy-arn "$ARN"
aws iam delete-policy --policy-arn "$ARN"
```

Keep that shell for the rest of the lesson. Every later read wants those four
variables.

Do not use `aws iam update-role` to plant drift, even though it looks like the
obvious way to change a role. Floci writes the change and then fails to
serialise its answer, so it exits 255 on a mutation that landed, which reads
as a failed step and is not one. `tag-role` is quiet.

## 5. Fire it

```sh
curl -s -X POST -H "Authorization: Bearer $KEY" \
  "http://localhost:4000/api/team/$AGENT/schedules/<the id>/run" | jq -c .
```

It answers `queued` with the conversation id, and the turn takes a few
minutes. When it settles, read the `aws-drift` block out of the thread, then
look at what it filed.

```sh
gh pr list --state open --json number,title,files \
  --jq '.[]|"\(.number) \(.title)  files \(.files|length)"'
```

Two things to say out loud. One pull request per drifted resource, and
`files 0` on every one, because the repo already declares what the resource
should be and merging is what runs the apply that puts the account back. An
empty diff looks like a mistake until somebody says that.

## 6. Say no, then let it ask again **confirm**

```sh
gh pr close <number> --comment "The tag change was deliberate."
```

Fire the schedule again. The run reports that finding as declined and opens
nothing. Ask the student why a watcher that refiled it would be worse than one
that missed it, and let them answer before you do.

Then the way back in.

```sh
gh pr edit <number> --add-label desk:reconsider
```

Fire it a third time and the finding is filed again. A label is a deliberate
act by somebody with write access, which a reopened branch is not.

## 7. Break the cap on purpose **confirm**

Say what is about to happen before you do it. This step lowers a security
constant and pushes it, which is what an attack looks like from the outside,
so a person driving this will be asked to approve it and an agent driving it
may be refused outright by its own permission layer. That is the right
response to the shape of the action and the wrong response to this particular
one, so the student decides rather than you. Nothing here leaves the emulator
or the probe branch, and the cap goes back two steps later.

If the refusal is absolute rather than a prompt, stop and say so. The lesson
is still worth its last step, which is the table, and a run that skipped the
cap probe should say which done-when it could not reach rather than claiming
it.

The watcher is told to hold at most five open. Find out what holds when it is
not told, by lowering the cap below what is already open, on the branch of one
of its own pull requests.

```sh
git fetch origin <the branch> && git checkout -b cap-probe origin/<the branch>
sed -i.bak 's/watcher_max_open_prs      = 5/watcher_max_open_prs      = 1/' access/baseline/locals.tf
rm -f access/baseline/locals.tf.bak
git commit -am "probe: lower the cap below what is open"
git push origin HEAD:<the branch>
```

Commit only `access/baseline/locals.tf`. A `git add -A` here sweeps in the
backend file the desk's setup writes and the plan step fails for an unrelated
reason, which costs ten minutes of looking at the wrong thing.

Its own `pr` job fails, naming the count and the cap. Say what that proves,
which is that the cap held without the watcher's cooperation, because the
watcher had already opened them.

Put the cap back and push again.

## 8. The table

Have them fill the third column. The lesson page has the rows. Do not read
them the answers to the last two.

Two rows have nothing in the enforcement column, which are never adopt what it
found, and a page is not a pull request. Both are prompt-only today. Ask what
it would take to move each one, and what that would cost. A good answer for
the first names the file that declares the resource and the fact that nothing
mechanical can tell a deliberate change from an accident.

## 9. Done when

1. A schedule you created ran the watch in the teammate's own thread and the
   `aws-drift` block named the planted drift.
2. One pull request per drifted resource, none of them changing a file.
3. A closed pull request came back as declined on the next run.
4. Labelling it `desk:reconsider` let the same finding be filed again.
5. A pull request carrying the reconcile marker failed its own `pr` job with
   the cap below the number open.
6. Their table names, per rule, what would enforce it with the prompt ignored,
   including the two rows where the answer is nothing.

If one fails, say which, and name the restart point, which is lesson 8.

## 10. Record where they stopped

```sh
mkdir -p .waterpark
```

Merge into `.waterpark/profile.json`.

```json
{"lessons": {"f9": {"state": "done", "saw_decline": true, "saw_cap_refuse": true}}}
```

## Clean up

Close any reconcile pull requests still open, and label each
`desk:reconsider` before closing, or a later run treats those findings as
declined and says nothing about them.

Delete the branches too. A closed pull request leaves its `desk/drift/*`
branch behind, and while the watcher now rewrites its own branches rather
than failing on them, a repository full of abandoned ones is noise nobody
reads.

```sh
for b in $(git ls-remote --heads origin 'refs/heads/desk/*' | awk '{print $2}' | sed 's|refs/heads/||'); do
  git push origin --delete "$b"
done
```

Delete the schedule if they do not want it firing at six.

```sh
curl -s -X DELETE -H "Authorization: Bearer $KEY" \
  "http://localhost:4000/api/team/$AGENT/schedules/<the id>"
```

The account still holds the drift, because the apply a merged reconcile pull
request triggers runs in the job's own emulator rather than the one on the
student's laptop. Say that plainly. Seating the desk in direct mode and asking
it to plan and apply is what puts the account back.
