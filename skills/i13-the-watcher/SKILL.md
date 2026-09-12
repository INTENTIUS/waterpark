---
name: waterpark-i13-the-watcher
description: Walk a student through IAM lesson 13, The watcher. Use when they want lesson 13, or when they ask what a burndown is, how an expired grant differs from drift, or which requests the concierge handled. Reads the estate's three projections from the account, leaves a break-glass grant past its expiry and sweeps it into a pull request that deletes rather than restores, puts that beside a reconcile pull request, checks that the cap counts both kinds, and asks the conversation record what the concierge did. One model turn, and most of the lesson needs none.
---

# water park, IAM lesson 13, The watcher

You are walking a student through IAM lesson 13, The watcher
(https://intentius.io/waterpark/courses/iam/13-the-watcher/). The outcome is
the difference between a reconcile pull request and a burndown one, seen as
two diffs pushing opposite ways. About 40 minutes.

Lesson 12 and Fountain lesson 9 come first. If they have not seen the watcher
file a reconcile pull request, step 4's comparison has nothing to compare
against, so send them to Fountain lesson 9 rather than describing it.

Confirm before merging anything in step 2 and before `sweep --open` in step 4.
Those are marked **confirm**. Every read runs freely.

Most of this lesson needs no model turn at all, which is worth saying, because
the scripts are the watcher and the agent is only the thing that runs them on
a schedule. The one turn is optional and is in step 6.

`gh` reads the repository from the clone's `origin`. If theirs is not a GitHub
remote, pass `-R <owner>/<repo>` on every `gh` call and say so once.

## 1. Say what this is

Two or three sentences. Drift is the account moving and burndown is the clock
moving. Both arrive as pull requests from the same watcher and they push in
opposite directions, and telling them apart at a glance is the skill this
lesson is for.

## 2. The projections

```sh
export AWS_ENDPOINT_URL=http://localhost:4566 AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1
access/scripts/expiring
access/scripts/rotation
access/scripts/access-review | head -40
```

Keep that shell, or re-export in every command if each of yours is fresh.

Point at the review's own admissions. It names the analyzer it could not reach
rather than leaving a hole, and that is the difference between an artifact a
compliance reviewer accepts and a dashboard.

## 3. Leave something lying around **confirm**

Have them put a break-glass grant on `on-call` whose expiry has already
passed, fenced by the two marker comments the script writes, with `granted_at`
three hours ago and `expires` one hour ago. The block's shape is in
`access/envs/prod/iam_role.on_call.tf` after any break-glass grant, and lesson
10 wrote one.

It has to reach the base branch. A burndown removes what the base declares and
there is nothing to remove until the base declares it, so this is a commit, a
pull request and a merge.

Watch the checks pass on the way through, and ask why nothing refused a grant
that was already dead. The answer is that the rule is about the length of the
window rather than where the window sits, and a check cannot know when
somebody will merge. The thing that catches it runs afterwards, which is this
lesson.

## 4. The two directions **confirm**

First ask the account.

```sh
access/scripts/expiring
```

It finds nothing, because the grant was never applied and a projection over
the account cannot see paperwork. Let them sit with that before you explain
it. Two facts are in there: the repo can declare access the account does not
hold, and the sweep reads files for exactly this reason.

Then the dry run, then the real one.

```sh
access/scripts/break-glass sweep
access/scripts/break-glass sweep --open
```

```sh
gh pr diff <number> | head -20
```

The diff removes the block. Put it beside a reconcile pull request from
Fountain lesson 9, whose diff was empty, and make them say which way each one
pushes before you do. A reconcile asks the account to go back to what the repo
says. A burndown asks the repo to stop saying something the account already
stopped doing.

If the sweep says nothing in the file was still expired and opens nothing,
that is the script being honest rather than failing. Check the dates on the
block they wrote.

## 5. Whether the cap counts both

```sh
grep -n 'markers=' .github/workflows/access.yml
```

Both markers, and `desk-proposed` besides. Ask what a cap that counted one
kind would mean. The answer to get to is that the watcher could hold five
reconciles and five sweeps while `access/baseline` says five, and the number a
person set would mean something other than what it says.

## 6. The record

```sh
KEY=$(grep '^FOUNTAIN_API_KEY=' compose/.env | cut -d= -f2-)
curl -s -H "Authorization: Bearer $KEY" \
  "http://localhost:4000/api/search?q=waterpark-artifacts" |
  jq -r '.data[]? | "\(.kind)  \(.snippet[0:70])"'
```

The lesson 12 request comes back. The conversation is the record for requests
and the code host is the record for changes, and neither is trying to be the
other. If they want to see the watcher do this itself rather than running the
scripts by hand, the schedule from Fountain lesson 9 is still the way, and
that is the one model turn.

## 7. The table

Three more rows on Fountain lesson 9's table. Do not give them the third.

The third row is that a projection reads the account, which every read script
does by sourcing one helper, and nothing enforces it. A script that read a
state file instead would pass every check in this repository. What keeps the
projections honest is that somebody wrote them that way. Ask what it would
cost to make that a control, and accept "a test per script that points the
helper at a file and expects a failure" as a good answer.

## 8. Done when

1. The three projections each answered from the account.
2. A grant left past its expiry produced a sweep pull request whose diff
   removes the block.
3. They can say which way a reconcile pull request pushes and which way a
   burndown does, without being told again.
4. The `pr` job's cap counts both markers against the one number.
5. `GET /api/search` returned the conversation where the concierge handled a
   request they can name.

If one fails, say which. The restart point is lesson 12.

## 9. Record where they stopped

```sh
mkdir -p .waterpark
```

```json
{"lessons": {"i13": {"state": "done", "swept": true}}}
```

## Clean up

Merge the sweep pull request if they want the estate tidy, or close it and
delete the branch. Either is fine and the difference is worth naming. Merging
retires the paperwork; closing leaves a grant the cloud already stopped
honouring sitting in the file where the next watch will report it again.

```sh
gh pr close <number> --comment "Closed after the lesson."
git push origin --delete desk/break-glass/on-call
```
