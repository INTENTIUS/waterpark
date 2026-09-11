---
title: "Driving an agent from an app"
id: "F7"
lesson: 7
weight: 7
summary: "An app drives a teammate through fenced blocks and the team stream."
# skill. a directory in this repo with a SKILL.md that drives the lesson. empty renders nothing
skill: "skills/f7-driving-an-agent-from-an-app"
# card. empty renders as TODO
goal: "Give the AWS desk its three objects and a seat on the team, which opens the fourth, open the page this repo ships at /desk/, sign in with Fountain and watch a one time code become an API key. Ask the desk in plain words what the estate holds, watch it answer in prose with a fenced block underneath, and see the page render that block as the Estate pane. Then reload and find the same view rebuilt from the conversation, rename the block on the page's side of the protocol and watch the pane go empty while the desk's words stay, and let the repo's own check refuse the rename."
done_when: >-
  `GET /api/auth/api-keys` lists a key named `oauth:aws-desk` that the page
  got without you pasting anything, one question asked in plain words puts an
  `aws-state` block in the conversation and the Estate pane shows what it
  holds, which on an empty account is nothing and on a built one is every role
  and bucket, a reload of the page rebuilds that pane with nothing in the
  browser but the Fountain URL, the teammate name and the key, and renaming
  `aws-state` in `desk/protocol.js` empties the pane while the desk's prose
  stays, which `just desk-check` then refuses by name.
restart_from: "lesson 5"
properties: ["IX"]
# activity. kind is hands-on, watch-along or discuss
activity:
  kind: hands-on
  time: "45 min"
  needs: ["the Start-here stack running (`just up`, `just register`, `just runner`) with a runner online", "an inference key set, this lesson makes one model turn", "a browser, and `just serve` in a second terminal", "jq and curl"]
  solo: true
  live: true
---

## Context

- An app that drives an agent needs two facts from the server and nothing else. `API_CORS_ORIGINS` admits the origin the page is served from, because a browser calling another origin's API makes a CORS request and it is off by default. `OAUTH_CLIENTS` names the app that may offer Sign in with Fountain, with its redirect URI exact. Both are set for you in `compose/docker-compose.yml`, for `http://localhost:1313` and `http://localhost:8080`, which are `just serve` and `just docker-run`, and for the copy of this page published on the site, which drives your own stack because a static page carries no server of its own.
- Sign in with Fountain is OAuth 2.0 authorization code with PKCE, and the app is a public client with no secret. `GET /oauth/authorize` remembers the request and sends you to login, the consent page names the app asking, and allowing it issues a one time code that lives five minutes and works once. `POST /api/oauth/token` swaps that code plus the verifier for a key. The key **is** an API key, full scope, thirty days, listed under Account and API keys as `oauth:<client_id>`, and a sign out revokes it. A client or a redirect nobody registered is rendered as an error and redirected nowhere.
- The protocol is fenced blocks in the agent's replies. The desk emits `aws-state`, `aws-plan` and `aws-result`, each a fenced code block whose info string is the block name and whose body is one JSON object. `desk/PROMPT.md` is the desk's half of that agreement and `desk/protocol.js` is the page's half, and `desk/bin/check-protocol` fails the build when the two stop naming the same blocks.
- The page holds no state a server could lose. Everything on screen is derived from the conversation's turns and its log events, which is why a reload rebuilds it. What the browser keeps is the Fountain URL, the teammate name and the key, in `localStorage`, and nothing else.
- `?blocks=true` is what makes that cheap. Fountain parses the runtime's dialect on the server into `text`, `thinking`, `tool_use` and the rest, so the page joins the text blocks of a turn and looks for fences in the result. Before that existed, the team app shipped a two hundred line port of Fountain's own parser.
- One connection covers every teammate. `GET /api/team/stream` carries each teammate's log events with `conversation_id` and `agent_id` on each, so the page routes an event to a row and looks nothing up. Fountain closes an idle stream after a minute, so a client reattaches rather than going quiet.
- The desk is [the AWS desk](../../docs/aws-desk.md), and this lesson only makes it talk. What it does with a request is lesson 8.

## Do

Lessons 1 to 6 drove agents from a terminal. This one drives one from a page, and the page is a file in this repo rather than a thing you have to build.

1. Read what the server admits, and prove it. Both settings are already in `compose/docker-compose.yml` under the `fountain` service, so read them there first.

   ```sh
   grep -E '^ +(API_CORS_ORIGINS|OAUTH_CLIENTS):' compose/docker-compose.yml
   ```

   Then ask the API what it says to a browser on the page's origin, and to one it has never heard of.

   ```sh
   curl -s -D - -o /dev/null -X OPTIONS \
     -H 'Origin: http://localhost:1313' \
     -H 'Access-Control-Request-Method: GET' \
     -H 'Access-Control-Request-Headers: authorization' \
     http://localhost:4000/api/auth/me | grep -i 'access-control-allow-origin'
   ```

   That prints `access-control-allow-origin: http://localhost:1313`. Run it again with `-H 'Origin: http://example.com'` and the header is absent, which is a browser being told no. The bearer key is what the request carries either way, because a cookie never crosses an origin.

2. Give the desk its objects. It applies three of lesson 1's four primitives, generated from `desk/PROMPT.md` rather than written by hand, so read both. The fourth is the Conversation, and step 3 opens it.

   ```sh
   just desk-apply
   ```

   The Environment says where the account is, which is not a secret. The Vault holds the credential that reaches it, which is. The Agent carries the prompt as its `system`, and its model is an alias, for the reason lesson 1 gives.

3. Put the desk on the team, which opens its one thread and gives it a computer. This is lesson 5's call with the vault bound to the conversation at creation, which is lesson 4's rule.

   ```sh
   just desk-hire
   ```

   It prints two ids, the agent's and the conversation's. Keep both. Later steps read that conversation, and the agent id is how you talk to the desk from a terminal instead of from the page.

   The conversation reads `pending` and stays that way until somebody sends a message, because status is about turns and there have not been any yet. Its presence and its sandbox may say `online` and `ready` beside that, which is a computer that is up with nothing to do. There is nothing to wait for here. Step 6 is what gives it work.

4. Serve the page and open it. In a second terminal run `just serve`, which you can stop when the lesson ends, then open <http://localhost:1313/desk/>. The settings bar wants the Fountain URL, which is `http://localhost:4000`, and the teammate, which is `aws-desk`.

5. Sign in with Fountain. Press the button rather than pasting a key. You are sent to login, the consent page names **The AWS desk** as the app asking, and allowing it sends you back to the page signed in. Then read what you were given, with your own key, which the stack wrote into `compose/.env` when you registered.

   ```sh
   KEY=$(grep '^FOUNTAIN_API_KEY=' compose/.env | cut -d= -f2-)
   curl -s -H "Authorization: Bearer $KEY" \
     http://localhost:4000/api/auth/api-keys | jq -r '.data[].name'
   ```

   One of those names is `oauth:aws-desk`. The page never saw your password and Fountain never gave it one, and the thing in the browser's `localStorage` is a key you can revoke from that same listing. Other names in there are not yours. A key called `sprite:` and eight hex characters is one Fountain minted for a sandbox to call home with, named after its conversation.

6. Ask the desk what the estate holds, in the box at the bottom of the page. Words, not a command.

   ```
   Set up your clone and read the estate. Tell me what the account holds.
   ```

   How long this takes varies. The desk clones this repo and reads the account every time, and it fetches the Terraform provider only when it has to plan, so this turn has landed in under a minute and it has taken six. Watch the commands line count climb in the Activity pane while it works. Then its prose arrives, and under it the Estate pane shows what the account holds.

   On a fresh stack the account is empty, so the block comes back with `complete` true and `resources` empty, and the Estate pane says it has nothing to show. That is the right answer and not a failure. The account is empty and the desk read it successfully, which are two different facts and the block carries both. `complete` goes false only when a read did not finish, and then the desk names what it could not reach. Lesson 8 is what fills the pane, by having the desk plan the estate this repo declares and apply it on your approval.

7. Prove the conversation is the record. Reload the page. The Estate pane comes back, the whole exchange comes back, and nothing was stored to make that happen. Then read the same block yourself, out of the log feed the page reads.

   ```sh
   CONV=<the thread id just desk-hire printed>
   curl -s -H "Authorization: Bearer $KEY" \
     "http://localhost:4000/api/conversations/$CONV/events?blocks=true&streams=acp&limit=1000" |
     jq -r '[.data[].blocks[]? | select(.kind=="text") | .body] | join("")' | grep -A3 'aws-state'
   ```

   The block is in the conversation. The page is one reading of it.

   If that prints nothing, read `meta` in the same response. A turn usually fits in one page and `has_more` is `false`, which means the block is not there yet rather than further along. When `has_more` is `true`, `limit` caps at a thousand and passing `&after=<cursor>` with `meta.next_cursor` gets the rest. The desk page pages to the end either way, because a long turn does eventually need it.

8. Break the protocol on purpose. In `desk/protocol.js`, rename the key `"aws-state"` to `"aws-estate"` and reload the page. The Estate pane is empty, because the page is now looking for a block nobody emits, and the block itself has not vanished. It is sitting in the Activity pane as a lump of raw JSON, because a block nobody recognizes is just text. Then ask the repo what it thinks.

   ```sh
   just desk-check
   ```

   It fails, names the block the prompt teaches and the page no longer reads, and the same check runs in CI on every push. Put the name back, reload, and the pane fills again.

## Self-paced

Everything in this lesson runs on the Start-here stack. The one model turn is a real one from your own inference key.

The desk reads a real account in step 6, which on this path is the Floci emulator the stack runs. What a real account would add is nothing this lesson shows, because the protocol, the sign in and the page are the same either way. Lesson 8 is where the difference starts to matter.

If you would rather not sign in, the settings bar still takes a pasted API key, and everything after step 5 works the same. You lose the only part of the lesson that shows how an app gets a credential without asking for a password.

## Live

Fifteen minutes. Put the page on the screen beside a terminal tailing `just logs`. Press Sign in with Fountain and let the room watch the round trip, then ask the desk the question in step 6 and let the silence sit while the tool lines climb. Say this when the block lands.

Nothing on this page is stored anywhere. Every pixel of it was rebuilt from the conversation, and the agent has no idea a page exists.

Then do step 8 live. The pane empties, the words stay, and the repo's own check names what broke. That is what a protocol with two halves buys you.

## Further reading

- [The AWS desk](../../docs/aws-desk.md), the design this page is v0 of
- `desk/README.md` and `desk/PROMPT.md` in this repo
- Fountain `docs/build/team-chat.md`, the app pattern this page follows
- Fountain `decisions/0021`, why the OAuth token is an API key
