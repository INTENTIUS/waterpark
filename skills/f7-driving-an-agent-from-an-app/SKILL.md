---
name: waterpark-f7-driving-an-agent-from-an-app
description: Walk a student through Fountain lesson 7, Driving an agent from an app. Use when they want lesson 7, or when they ask how a page talks to an agent, what a protocol block is, or how Sign in with Fountain works. Proves what CORS admits with two preflights, applies the AWS desk's objects and puts it on the team, has the student sign in from the page and verifies the key it got, asks the desk what the estate holds and finds the fenced block in the conversation, then renames the block on the page's side and lets the repo's own check refuse it. One model turn.
---

# water park, Fountain lesson 7, Driving an agent from an app

You are walking a student through Fountain lesson 7, Driving an agent from
an app (https://intentius.io/waterpark/courses/fountain/07-driving-an-agent-from-an-app/).
The outcome is the desk page open and signed in, one fenced block the desk
emitted rendered as the Estate pane, and the fact that the page stores none
of it. About 45 minutes.

This lesson has a browser in it and you do not. Steps 4, 5, 6 and 8 are the
student's hands and eyes. Ask them what they see, in their words, and verify
the API side yourself. Never claim a pane filled. Ask.

Confirm with the student before `just desk-apply`, before `just desk-hire`,
before the message in step 6 and before editing `desk/protocol.js` in step 8.
Those steps are marked **confirm**. Reads run freely, which is every `GET`,
the preflights and `just desk-check`.

This lesson makes one model turn, in step 6, and it is a long one. Say so
before it.

## 1. Say what this is

In two or three sentences say this is lesson 7 of the Fountain course. An app
that drives an agent needs two facts from the server, which are the origin it
admits and the client that may sign in, and everything else is fenced blocks
in the agent's replies. The page holds no state, because the conversation is
the record. Link the lesson page above.

## 2. Check the ground

Run the same check Start here uses.

```sh
bash skills/start/check.sh
```

Also read `.waterpark/profile.json` at the checkout root if it exists. Trust
what it says about the student only when the check's own
`fountain.logged_in` is `true` and `fountain.email` matches the profile's
`email`. A profile file is a claim from a previous run and the check's live
call is the truth, so when they disagree believe the check.

The runner has to be online for this lesson, because the desk needs a
computer. `just status` says whether it is.

## 3. What the server admits

Read the two settings where they live.

```sh
grep -A1 'API_CORS_ORIGINS\|OAUTH_CLIENTS' compose/docker-compose.yml
```

Then prove the first one, twice. The page's origin.

```sh
curl -s -D - -o /dev/null -X OPTIONS \
  -H 'Origin: http://localhost:1313' \
  -H 'Access-Control-Request-Method: GET' \
  -H 'Access-Control-Request-Headers: authorization' \
  http://localhost:4000/api/auth/me | grep -i 'access-control-allow-origin'
```

That prints `access-control-allow-origin: http://localhost:1313`. Now an
origin nobody named.

```sh
curl -s -D - -o /dev/null -X OPTIONS \
  -H 'Origin: http://example.com' \
  -H 'Access-Control-Request-Method: GET' \
  -H 'Access-Control-Request-Headers: authorization' \
  http://localhost:4000/api/auth/me | grep -ci 'access-control-allow-origin'
```

That prints `0`. Say what that means. The server did not refuse the request,
it declined to tell the browser it was allowed, and the browser is what
enforces it. Both answers carry the bearer key the caller presents and
neither carries a cookie.

## 4. Give the desk its objects, and a seat **confirm**

```sh
just desk-apply
```

It regenerates `desk/fountain.yaml` from `desk/PROMPT.md` and applies three
objects. Show the output. Offer to open `desk/fountain.yaml` and point at the
split, which is an Environment saying where the account is, a Vault holding
the credential that reaches it, and an Agent carrying the prompt as `system`.

Then put it on the team. **confirm**

```sh
just desk-hire
```

It prints the conversation id. Keep it. Every later step uses it, and it is
the desk's one thread.

## 5. The page, and signing in

Ask the student to run `just serve` in a second terminal and open
http://localhost:1313/desk/ in a browser.

Tell them what to fill in. The Fountain URL is `http://localhost:4000` and
the teammate is `aws-desk`. Then have them press **Sign in with Fountain**
rather than pasting a key.

Ask them what happened, in their words. You are looking for a login, then a
consent page that names **The AWS desk**, then the page again with the
settings bar gone. If they land on an error page instead, the client id or
the redirect URI does not match `OAUTH_CLIENTS`, and the fix is in
`compose/docker-compose.yml` followed by `docker compose up -d fountain`.

Then verify it yourself, which needs the student's own key from
`~/.fountain/credentials` or the `FOUNTAIN_API_KEY` in `compose/.env`.

```sh
curl -s -H "Authorization: Bearer $KEY" \
  http://localhost:4000/api/auth/api-keys | jq -r '.data[].name'
```

One of the names is `oauth:aws-desk`. Say what that proves. The page asked
for a credential and got one scoped to a client the server knows, the
password never went near it, and revoking it is a row in that same listing.

## 6. Ask the desk what the estate holds **confirm**

This is the model turn. Say so, then have the student type this into the box
at the bottom of the page.

```
Set up your clone and read the estate. Tell me what the account holds.
```

It takes a few minutes, because the desk clones this repo, runs
`terraform init` and reads the account. Ask the student to describe the
Activity pane while it works, where a commands line counts up.

When it settles, verify the block in the record rather than on the screen.
Page the log feed, because a first turn runs past one page of events.

```sh
curl -s -H "Authorization: Bearer $KEY" \
  "http://localhost:4000/api/conversations/$CONV/events?blocks=true&streams=acp&limit=1000" |
  jq -r '[.data[].blocks[]? | select(.kind=="text") | .body] | join("")' | grep -c 'aws-state'
```

If that prints `0`, the turn's events are past the first page. Read
`.meta.next_cursor` from the same response and pass it as `&after=<cursor>`,
then run it again. Repeat while `.meta.has_more` is `true`.

Ask the student what the Estate pane shows. On a fresh stack the account is
empty, the desk says so with `complete` false and the reason named, and the
pane is right to be empty. That is the correct outcome for this lesson and it
is lesson 8 that fills it.

## 7. The conversation is the record

Ask the student to reload the page. Ask what came back. The whole exchange
and the Estate pane should, and nothing was stored to make that happen.

Have them open the browser's storage for the page. It holds the Fountain URL,
the teammate name and the key, and no turn, no block and no plan.

## 8. Break the protocol on purpose **confirm**

In `desk/protocol.js`, rename the key `"aws-state"` to `"aws-estate"`. Ask
the student to reload the page and say what changed. Two things should have.
The Estate pane is empty, because the page is looking for a block nobody
emits. And the block is now sitting in the Activity pane as raw JSON, because
a block nobody recognizes is just text. If they report the block disappearing
altogether, that is a different bug and worth stopping on.

Then ask the repo.

```sh
just desk-check
```

It fails and names the block the prompt teaches and the page no longer reads.
Put the name back, have them reload, and the pane fills again. Run
`just desk-check` once more and it passes.

## 9. Done when

The lesson's card says this, and all four have to hold.

1. `GET /api/auth/api-keys` lists a key named `oauth:aws-desk` that the page
   got without the student pasting anything.
2. The Estate pane names what the account holds, or says the account is
   empty with the reason named, from one question asked in plain words.
3. A reload rebuilds the page from the conversation, with only the Fountain
   URL, the teammate and the key in the browser.
4. Renaming `aws-state` in `desk/protocol.js` empties the pane while the
   desk's prose stays, and `just desk-check` refuses it by name.

If one fails, say which, and name the restart point from the card, which is
lesson 5.

## 10. Record where they stopped

Write `.waterpark/profile.json` in the student's working directory, merging
rather than replacing.

```json
{"lessons": {"f7": {"state": "done", "conversation_id": "...", "signed_in": true}}}
```

## Clean up, if they ask

The desk is worth keeping, because lesson 8 uses the same teammate and the
same clone on its computer. If they want it gone, `DELETE /api/team/<agent
id>` removes it and terminates its conversation, and the key the page holds
is revoked from the API keys listing or by pressing Sign out on the page.
