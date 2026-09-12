---
name: waterpark-i12-the-concierge
description: Walk a student through IAM lesson 12, The concierge. Use when they want lesson 12, or when they ask how an agent asks for access on their behalf, what an unverified claim is on a pull request, or whether an agent's pull request gets an easier ride than a person's. Seats the desk in repo mode against the access repo, takes a request in plain words and reads the pull request it opens, gets a refusal naming the enrolment path for an identity the estate does not know, and ends by making the same edit by hand and comparing the two jobs line by line. Two model turns.
---

# water park, IAM lesson 12, The concierge

You are walking a student through IAM lesson 12, The concierge
(https://intentius.io/waterpark/courses/iam/12-the-concierge/). The outcome is
a request in words that became a reviewable pull request, a refusal that was
about standing rather than about access, and a side-by-side that shows the
pipeline treating an agent exactly like a person. About 45 minutes.

Nothing is built in this lesson. The desk is the one from Fountain lessons 7
and 8, and if the student has not done those, send them there rather than
seating a desk they have never watched work.

Confirm before seating the desk and before each request. Those are marked
**confirm**. Reads run freely, and so does opening the student's own pull
request in step 5, which is theirs.

Two model turns, in steps 2 and 4. Say so first.

The student needs `gh` able to write to their copy of this repo. `gh` reads
the repository from the clone's `origin`, so if theirs is not a GitHub remote,
pass `-R <owner>/<repo>` on every `gh` command and say so once rather than
letting each one fail.

## 1. Say what this is

Two or three sentences. Lesson 12 is the desk pointed at this estate in repo
mode, and the only new things are IAM's own refusals and IAM's own reviewer.
The claim being checked is prescription 13, which is that an agent's pull
request goes through the same pipeline as a person's, and the last step
checks it rather than believing it.

## 2. Check the ground, and seat the desk **confirm**

```sh
bash skills/start/check.sh
just desk-hire repo
```

If it stops for want of a `GITHUB_TOKEN`, read them the line it printed and
stop. Tell them the shape, which is fine-grained, one repository, contents and
pull requests, and why, which is that this lesson's whole claim is a desk
holding nothing that reaches AWS.

Reading the desk's replies from a terminal is the same three calls lesson 8
used, and they are here so you do not have to send anybody back for them.

```sh
KEY=$(grep '^FOUNTAIN_API_KEY=' compose/.env | cut -d= -f2-)
AGENT=$(curl -s -H "Authorization: Bearer $KEY" http://localhost:4000/api/team |
  jq -r '.data[]|select(.agent.name=="aws-desk")|.agent_id')
CONV=$(curl -s -H "Authorization: Bearer $KEY" http://localhost:4000/api/team |
  jq -r '.data[]|select(.agent.name=="aws-desk")|.conversation.id')
curl -s -X POST -H "Authorization: Bearer $KEY" -H 'Content-Type: application/json' \
  -d "$(jq -n --arg p 'the words' '{prompt:$p}')" \
  "http://localhost:4000/api/team/$AGENT/messages"
```

Whether it has finished is `.data.status` on the conversation, `running` or
`idle`, and `.data.turn_count` is how many turns there have been. There is no
`.data.turns`. The reply is in the log feed.

```sh
curl -s -H "Authorization: Bearer $KEY" \
  "http://localhost:4000/api/conversations/$CONV/events?blocks=true&streams=acp&limit=1000" -o /tmp/ev.json
jq -r '[.data[].blocks[]?|select(.kind=="text")|.body]|join("")' /tmp/ev.json | tail -c 3000
```

## 3. The request **confirm**

Have them send it as themselves if they are on the platform team, or as Dana
if they would rather not use their own name.

```
I am Dana from the platform team. site-publisher needs list on waterpark-artifacts, so the build can see which checkpoint bundles exist before it picks one.
```

While it works, name what it is doing, because the interesting part is over
before the pull request appears. It reads the account, finds the file by the
naming rule, checks the team against that principal's `teams`, makes one edit,
plans, renders the delta and the digest with the repo's own scripts, and only
then opens the pull request.

Then read it as a reviewer would.

```sh
gh pr view <number> --json files --jq '[.files[].path]'
gh pr view <number> --json body --jq '.body' | head -20
```

One file. The body's first line names the requester and marks the claim.
Point at the words "unverified claim" and ask the student who checked that
they are Dana. The answer is nobody, and the pull request says so rather than
letting a reviewer assume otherwise.

## 4. The refusal **confirm**

```
I am Sam from the analytics team. on-call needs read on waterpark-site.
```

It refuses, and the refusal is about standing. Have them check the two facts
it used.

```sh
grep -n 'teams' access/envs/prod/iam_role.on_call.tf
grep -n 'analytics' access/codeowners.map || echo "analytics is not in the map"
```

Ask why the next step it named is enrolment rather than the grant. The answer
worth getting to is that access you can obtain by claiming a team name is
access nobody reviewed, and every check downstream would be reviewing a
sentence somebody invented.

Confirm no pull request was opened for it.

## 5. The same edit, by hand

```sh
git checkout -b same-edit-by-hand origin/main
```

Have them add the identical grant to
`access/envs/prod/iam_role.site_publisher.tf`, the same resource, access and
reason as the desk's diff, then commit and open their own pull request. Let
them type it rather than copying the desk's branch, because the point is that
a person did it.

## 6. Side by side

```sh
gh pr checks <the desk's number> | grep -E '^pr'
gh pr checks <their number> | grep -E '^pr'
```

Both ran the `pr` job. Then the rendered delta from each.

```sh
gh run view --job=<job id> --log | grep -A8 'The access delta'
```

The same lines from the same script. Ask what the pipeline noticed about the
difference between an agent and a person, and let them answer nothing.

Then the counterfactual, which is the part worth remembering. If the desk's
pull request had skipped a check, or carried a label that let it merge, the
estate would have two paths to prod and lesson 6 would be a lie.

## 7. The credential table

Have them add the concierge's rows to the table from Fountain lesson 4, then
ask which row they would have to compromise to get an unreviewed grant into
the account. The desk's row is not one of them, and noticing that is the
outcome.

## 8. Done when

1. A request in plain words produced a pull request changing exactly one file.
2. Its body named the requester as an unverified claim, in those words.
3. An identity in no principal's `teams` was refused with the enrolment path
   named, and no pull request was opened for the access.
4. Their own hand-typed pull request making the identical edit passed the
   identical `pr` job.
5. Both jobs rendered the same access delta.

If one fails, say which, and the restart point is lesson 11 with the desk from
Fountain lesson 7.

## 9. Record where they stopped

```sh
mkdir -p .waterpark
```

Merge into `.waterpark/profile.json`.

```json
{"lessons": {"i12": {"state": "done", "saw_refusal": true, "compared_jobs": true}}}
```

## Clean up

Close both pull requests unless they want to merge one, and delete the
branches. Merging the desk's is harmless and is the honest end of the loop,
but it moves the estate that later lessons start from, so say that before they
choose.

```sh
gh pr close <numbers> --comment "Closed after the lesson."
git push origin --delete same-edit-by-hand
```

The desk stays on the team. Lesson 13 puts it on a schedule.
