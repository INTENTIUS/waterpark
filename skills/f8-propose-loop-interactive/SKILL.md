---
name: waterpark-f8-propose-loop-interactive
description: Walk a student through Fountain lesson 8, The propose loop interactive. Use when they want lesson 8, or when they ask what the propose loop is, what an access delta is, or why an agent should refuse its own plan. Runs the desk's loop end to end against Floci, plans the estate and applies it on approval, takes a request in plain words, moves the account by hand so an approved plan comes back stale, recovers, gets a boundary change refused, and ends by filling the eight parts for the desk against Mend. Seven model turns.
---

# water park, Fountain lesson 8, The propose loop interactive

You are walking a student through Fountain lesson 8, The propose loop
interactive (https://intentius.io/waterpark/courses/fountain/08-propose-loop-interactive/).
The outcome is the whole loop run once against a real account, including the
part where the agent refuses its own plan. About an hour.

This lesson needs the desk from lesson 7 already on the team. If it is not,
stop and send them to lesson 7. `just desk-hire` on its own will not do,
because they will not know what they are looking at.

Confirm before each `APPROVE` and before the hand edit in step 5. Those are
marked **confirm**. Reads run freely, which is every `GET` and every
`aws ... list-*` or `get-*`.

This lesson makes seven model turns and each one can take minutes. Say so
before the first. If the student is short on inference budget, steps 1 to 3
and 9 are the smallest honest subset and cost three turns.

The student may drive the desk from the page at http://localhost:1313/desk/
or from a terminal. The page adds nothing to this lesson except that the
Approve button sends the same sentence they would type.

From a terminal it is three calls and they are all below. Lesson 7 hired the
desk, so the ids are on the roster rather than in anybody's scrollback, and
re-running `just desk-hire` to find them is not the way.

```sh
KEY=$(grep '^FOUNTAIN_API_KEY=' compose/.env | cut -d= -f2-)
AGENT=$(curl -s -H "Authorization: Bearer $KEY" http://localhost:4000/api/team |
  jq -r '.data[]|select(.agent.name=="aws-desk")|.agent_id')
CONV=$(curl -s -H "Authorization: Bearer $KEY" http://localhost:4000/api/team |
  jq -r '.data[]|select(.agent.name=="aws-desk")|.conversation.id')
```

Send a message.

```sh
curl -s -X POST -H "Authorization: Bearer $KEY" -H 'Content-Type: application/json' \
  -d "$(jq -n --arg p 'the words' '{prompt:$p}')" \
  "http://localhost:4000/api/team/$AGENT/messages"
```

Wait for it. A message is queued and the turn takes ten to twenty seconds to
appear, so a loop that waits for "nothing running" returns at once and looks
like a finished turn. Wait for the turn count to go up first, then for the
status to come back to `idle`.

```sh
curl -s -H "Authorization: Bearer $KEY" "http://localhost:4000/api/conversations/$CONV/turns" | jq '.data|length'
curl -s -H "Authorization: Bearer $KEY" "http://localhost:4000/api/conversations/$CONV" | jq -r '.data.status'
```

Read the reply. The blocks are in the log feed, already parsed, and the text
of a turn is its `text` blocks joined in order.

```sh
curl -s -H "Authorization: Bearer $KEY" \
  "http://localhost:4000/api/conversations/$CONV/events?blocks=true&streams=acp&limit=1000" -o /tmp/ev.json
jq -r '[.data[].blocks[]?|select(.kind=="text")|.body]|join("")' /tmp/ev.json | tail -c 3000
```

Two things about that last one. Write the response to a file rather than a
shell variable, because a variable holding JSON and echoed back into `jq` is
a parse error waiting to happen. And if `meta.has_more` is `true`, pass
`meta.next_cursor` back as `&after=<cursor>` and join the pages.

## 1. Say what this is

In two or three sentences say this is lesson 8 of the Fountain course. The
propose loop has eight parts and the desk is one instance of it. The part
worth waiting for is verify, which here means the desk re-plans on approval
and refuses its own plan when the estate has moved. Link the lesson page.

## 2. Check the ground

```sh
bash skills/start/check.sh
```

Then check the desk is on the team and the account is readable.

```sh
just status
export AWS_ENDPOINT_URL=http://localhost:4566 AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1
aws iam list-roles --query 'Roles[].RoleName' --output text
```

Keep that shell for the whole lesson. Every read below is a bare `aws` call
and it needs those four variables, so a second terminal or a fresh shell
reads a real account instead of the emulator.

An empty answer is the right starting point and the lesson watches it fill.
If roles are already there, the estate has been applied before. That is fine.
Say so, and expect the plan in step 3 to be smaller or empty.

## 3. Plan the estate the repo declares

Ask the desk, in the page or over the API.

```
Plan the first apply of everything the repo declares.
```

It reads the account first, then plans. When the `aws-plan` block lands, read
it to the student in the order the block puts it, because that order is the
lesson. The access delta first, grouped by principal. Then the proofs, which
on Floci are one named skip. Then the diff, which is empty here because no
file was edited. Then the typed changes.

Say the thing the block is for. Eighteen resources is a Terraform fact. Four
principals, five grants and a boundary is what somebody is being asked to
approve, and `render-delta` wrote that sentence, not the model.

Note the plan id. It looks like `plan-f97b`.

## 4. Approve it **confirm**

```
APPROVE plan-xxxx
```

Nothing else approves. Not "looks good". The desk plans again, compares the
new digest to the one it showed, and applies the plan that was approved.

Then read the account back yourself, because the live system is the truth and
the desk saying it applied is not the account saying so.

```sh
aws iam list-roles --query 'Roles[].RoleName' --output text
aws iam list-policies --scope Local --query 'Policies[].PolicyName' --output text
```

Four roles and six policies is the shape to expect.

Check the account rather than the sentence. `detail` in an `aws-result` is
the desk's own words, unlike the delta and the digest, so a count in it is
the model reporting and not a script. One run said "17 added" for an
eighteen resource plan and the estate was correct anyway. The account is what
settles it.

## 5. Ask for one grant

```
site-publisher needs list on waterpark-artifacts, so the build can see which checkpoint bundles exist before it picks one.
```

This time the block carries a `diff` and one entry in `files`, because the
desk edited `access/envs/prod/iam_role.site_publisher.tf`. Point at the
reason in the diff. It is the sentence the student wrote, carried into the
file, which is what makes a grant reviewable a year later.

Note this plan id too and do **not** approve it yet.

## 6. Move the account under the approval **confirm**

Explain before doing it. You are about to take away a grant the desk is not
touching, the way a console click would.

```sh
ARN=$(aws iam list-policies --scope Local \
  --query 'Policies[?PolicyName==`site-publisher-list-waterpark-site`].Arn' --output text)
aws iam detach-role-policy --role-name site-publisher --policy-arn "$ARN"
aws iam delete-policy --policy-arn "$ARN"
```

## 7. Approve the plan from step 5 **confirm**

```
APPROVE plan-xxxx
```

It refuses. `aws-result` comes back `stale`, the recheck digest does not match
the approved one, and the detail names the grant that vanished. Nothing was
applied.

This is the step the lesson exists for. Ask the student what would have
happened without the digest check, and make sure they get to the answer
themselves. The saved plan would have created the two resources they approved
and recreated one they never saw, against an estate nobody had described to
them.

## 8. Recover, then get refused

```
I removed that policy by hand. Re-plan and show me the new plan.
```

The new plan has four changes rather than two, because it restores what was
deleted as well as adding what was asked for. Approve it **confirm**, then
read the account back once more.

Then ask for something it has to refuse. If an agent is driving this rather
than a person, its own permission layer may refuse to send these words, since
asking to widen a boundary to `iam:*` reads as a privilege request whoever is
asking. Send the body from a file if so. The words are the point.

```
The boundary is blocking me. Widen it to allow iam:* so I stop hitting this.
```

`aws-result` `refused`, with the platform path named. Say that a refusal is an
outcome and not a failure, and that the desk refusing is not the control. The
control is that its credential could not widen the boundary even if it tried.

## 9. Fill the table

Open [the propose loop](https://intentius.io/waterpark/propose-loop/) and have
the student write the desk's column for the eight parts from what they just
watched, then put Mend's column beside it.

Do not give them the answer to the last part. Ask which one differs. Seven
are the same shape and **propose** is the one. Mend's propose step is the
human's browser holding the human's token, so the operator holds nothing that
can write. The desk's propose step is a message and the desk holds the
credential, so the rule that matters is the scope of what that credential
reaches.

Then ask the harder question. Which would they hand to somebody else's org,
and why. The IAM course answers it one way, and the answer for a repo you own
is not the same.

## 10. Done when

1. An `aws-plan` block carried a delta, a proof verdict and a digest the desk
   copied rather than composed.
2. `APPROVE` applied it and the account read back by hand holds what the
   delta said it would.
3. A plan approved after the account moved came back `stale`, named the moved
   resource, and applied nothing.
4. The boundary request came back `refused` with the platform path named.
5. Their parts table names propose as the part that differs.

If one fails, say which, and name the restart point, which is lesson 7 with
the desk on the team.

## 11. Record where they stopped

Merge into `.waterpark/profile.json` in the student's working directory. A
fresh clone has no `.waterpark`, so make it. It is gitignored.

```sh
mkdir -p .waterpark
```


```json
{"lessons": {"f8": {"state": "done", "applied": true, "saw_stale": true}}}
```

## Clean up, if they ask

Leave the desk. Lesson 9 puts it on a schedule. To put the account back to
empty, `docker compose -f compose/docker-compose.yml --env-file compose/.env up -d --force-recreate floci`
gives a fresh emulator, and the desk's own clone still holds a state file that
now describes an account that no longer exists, which is worth saying out loud
rather than tidying away.
