---
title: "The team"
id: "F5"
lesson: 5
weight: 5
summary: "A teammate is one conversation on the team channel."
# skill. a directory in this repo with a SKILL.md that drives the lesson. empty renders nothing
skill: "skills/f5-the-team"
# card. empty renders as TODO
goal: "Add an agent to the team with one API call and watch that call open one conversation on a reserved channel and nothing else. Read the roster, the presence and the stream as views over that conversation, message the teammate and see the turn land in its thread and on the stream tagged with its agent id, let it sleep and wake it, take the runner away and read what presence says, then remove it and find the conversation unbound and still on the record."
done_when: >-
  `GET /api/team` returns the teammate with `presence.state` `online` and
  `preview.text` equal to the reply it gave, `GET
  /api/conversations?channel_id=fountain:team` returns exactly that one
  conversation, the open `/api/team/stream` holds a `turn` stage event
  carrying that `agent_id` and `conversation_id`, and after `DELETE
  /api/team/<agent_id>` both listings are empty while `fountain conv list`
  still shows the conversation as `terminated`.
restart_from: "lesson 1"
properties: ["IX"]
# activity. kind is hands-on, watch-along or discuss
activity:
  kind: hands-on
  time: "25 min"
  needs: ["the Start-here stack running (`just up`, `just register`, `just runner`) with a runner online, in the checkout `just up` ran in", "an inference key set, this lesson makes three model turns", "jq, curl, and a second terminal for the stream"]
  solo: true
  live: true
---

## Context

- A teammate is an Agent with one Conversation that continues, bound to the reserved channel `fountain:team`. That is the whole mechanism. There is no team table and no teammate record, and `POST /api/team` creates no new kind of object. It binds a conversation to the channel, and the rest of the team API reads and writes that conversation.
- The roster, presence, unread state and the preview are views over that conversation. Presence is a label Fountain derives from the sandbox's state, `starting`, `online`, `working`, `asleep`, `machine_offline` and the rest, and the stream is the log events of every teammate's conversation on one connection, each tagged with `conversation_id` and `agent_id`.
- One agent has one team conversation. Two people who message the same teammate talk to the same thread and the same machine, and adding an agent that is already on the team answers `200` with the conversation it already has. That is what makes a teammate's work attributable, which is Accessible Ops IX. Every turn is in one thread under one agent id, and the stream says which.
- A message is a follow-up turn in that conversation. A parked sandbox wakes on it, a conversation past resuming is replaced by a fresh one under the same binding, and a message sent while a turn is running is refused with `400 conversation_busy` rather than queued behind it.
- The CLI has no team commands at v0.12.0, so this lesson is `curl` against the API with the Bearer key from Start here, and the web UI's `/team` page for the same facts drawn as a chat client.
- The class stack's sandbox is a runner. When the runner is down, presence reads `machine_offline` and a message is accepted with `202` and delivered when the runner reconnects. Issue 85 expected a `503 runner_offline` there, and the stack does not do that, which [upstream](https://github.com/INTENTIUS/waterpark/blob/main/project/upstream.md) records.
- Removing a teammate terminates the live conversation, its sandbox with it, and unbinds every conversation the agent had under the channel. The rows stay in the conversation list, because the record is the conversation and not the binding.
- Schedules are lesson 6, and they run on the teammate this lesson makes.

## Do

Lessons 1 to 4 started conversations one at a time and each one was a fresh machine. This lesson makes one that persists and is addressed by the agent's name, and then shows that nothing new was made to do it.

1. Write a plain environment and an agent to `f5-manifest.yaml` and apply it. Nothing about this agent says team.

   ```yaml
   apiVersion: fountain.dev/v1
   kind: Environment
   metadata:
     name: lesson5-env
   spec:
     networking_type: unrestricted
   ---
   apiVersion: fountain.dev/v1
   kind: Agent
   metadata:
     name: lesson5-agent
   spec:
     model: anthropic/sonnet
     runtime: claude
     environment: lesson5-env
   ```

   ```sh
   fountain apply -f f5-manifest.yaml
   ```

   `env  +  lesson5-env` and `agent  +  lesson5-agent`. Then put your key and
   the agent's id in the shell, because every call from here is `curl`.

   ```sh
   FOUNTAIN_KEY=$(awk -v p="[${FOUNTAIN_PROFILE:-default}]" '$0==p{f=1;next} /^\[/{f=0} f && $1=="api_key"{gsub(/"/,"",$3); print $3; exit}' ~/.fountain/credentials)
   AGENT=$(fountain agent list --json | jq -r '.[] | select(.name=="lesson5-agent") | .id')
   echo $AGENT
   ```

2. Open the team stream in a second terminal and leave it open for the whole lesson. It needs the same two variables, so set them there too.

   ```sh
   curl -sN -H "Authorization: Bearer $FOUNTAIN_KEY" http://localhost:4000/api/team/stream | tee f5-stream.log
   ```

   `: connected`, then nothing, because there is no teammate yet. The
   stream is one connection carrying every teammate's events, and it closes
   after sixty idle seconds so a client reconnects. If it closes while you
   read, run it again.

3. Add the agent to the team, back in the first terminal.

   ```sh
   curl -s -X POST -H "Authorization: Bearer $FOUNTAIN_KEY" -H 'Content-Type: application/json' \
     -d "{\"agent_id\":\"$AGENT\"}" http://localhost:4000/api/team \
     | jq '.data | {name, agent_id, presence, conversation: {id: .conversation.id, status: .conversation.status, channel_id: .conversation.channel_id}}'
   ```

   ```json
   {
     "name": "lesson5-agent",
     "agent_id": "49fce507-9868-4cb6-b035-83c85353b91d",
     "presence": {
       "label": "starting computer",
       "state": "starting"
     },
     "conversation": {
       "id": "2377ec3e-c4e8-44d5-b5d6-abd2bdf4254c",
       "status": "pending",
       "channel_id": "fountain:team"
     }
   }
   ```

   That is `201`, and read what came back. A conversation, with a status
   and a channel id, and a presence label derived from it. Keep the
   conversation id. In the second terminal the stream printed a `team`
   event with `{"reason":"changed"}`, then `provision started` and
   `provision done` as stage events, each carrying your agent id. The add
   opened the conversation and the conversation provisioned a sandbox, the
   way lesson 1's did.

4. Read the roster, and then read the same fact from the other side.

   ```sh
   curl -s -H "Authorization: Bearer $FOUNTAIN_KEY" http://localhost:4000/api/team \
     | jq -c '.data[] | {name, presence, conversation: .conversation.id}'
   curl -s -H "Authorization: Bearer $FOUNTAIN_KEY" "http://localhost:4000/api/conversations?channel_id=fountain:team" \
     | jq -c '.data[] | {id, status, channel_id, agent_id}'
   ```

   ```
   {"name":"lesson5-agent","presence":{"label":"ready · waiting for a turn","state":"online"},"conversation":"2377ec3e-c4e8-44d5-b5d6-abd2bdf4254c"}
   {"id":"2377ec3e-c4e8-44d5-b5d6-abd2bdf4254c","status":"pending","channel_id":"fountain:team","agent_id":"49fce507-9868-4cb6-b035-83c85353b91d"}
   ```

   The roster's one entry and the conversation list filtered to the channel
   name the same id. The second call went nowhere near the team API. There
   is no fifth object, and `/team` in the web UI, which redirects to the
   team app, draws these two answers as a roster on the left and a thread on
   the right.

5. Message the teammate, and watch the turn land in three places.

   ```sh
   curl -s -X POST -H "Authorization: Bearer $FOUNTAIN_KEY" -H 'Content-Type: application/json' \
     -d '{"prompt":"Reply with the single word hello."}' http://localhost:4000/api/team/$AGENT/messages
   ```

   `{"status":"queued","conversation_id":"2377ec3e-..."}` and `202`. The
   response names the conversation the message went to, which matters when a
   conversation past resuming has been replaced by a fresh one under the same
   binding. While it runs, send a second one.

   ```sh
   curl -s -w ' %{http_code}\n' -X POST -H "Authorization: Bearer $FOUNTAIN_KEY" -H 'Content-Type: application/json' \
     -d '{"prompt":"Reply with the single word again."}' http://localhost:4000/api/team/$AGENT/messages
   ```

   `{"error":"conversation_busy"} 400`. One thread, one turn at a time, and
   the second caller is told rather than queued. If the first turn finished
   before you sent this, it answers `202` instead, and you have seen the
   thread accept a second turn, which is the same fact from the other side.

   Now the three places. The second terminal streamed `turn started`, a run
   of `output` events with the runtime's text arriving in pieces, and
   `turn done`, each carrying `agent_id` and `conversation_id`. The roster
   shows the reply as the preview.

   ```sh
   sleep 20
   curl -s -H "Authorization: Bearer $FOUNTAIN_KEY" http://localhost:4000/api/team \
     | jq -c '.data[] | {presence, last_turn: {status: .last_turn.status, prompt: .last_turn.prompt}, preview}'
   ```

   ```
   {"presence":{"label":"online","state":"online"},"last_turn":{"status":"completed","prompt":"Reply with the single word hello."},"preview":{"text":"hello","kind":"them"}}
   ```

   And the conversation itself holds the turn, which `fountain conv show`
   with the full id prints the way it printed lesson 1's. Three views, one
   record.

6. Prove there is one thread per agent. Add the same agent again.

   ```sh
   curl -s -w ' %{http_code}\n' -X POST -H "Authorization: Bearer $FOUNTAIN_KEY" -H 'Content-Type: application/json' \
     -d "{\"agent_id\":\"$AGENT\"}" http://localhost:4000/api/team | jq -c '.data.conversation.id'
   ```

   The same conversation id, and `200` where step 3 was `201`. Two people
   who message this teammate talk to the same thread on the same machine,
   and everything it did is under one agent id in one place. That is
   Accessible Ops IX, attributable, done by construction.

7. Let it sleep, then wake it. The class stack parks a sandbox two minutes after its last turn. Poll the roster until presence changes.

   ```sh
   until curl -s -H "Authorization: Bearer $FOUNTAIN_KEY" http://localhost:4000/api/team | jq -e '.data[0].presence.state == "asleep"' >/dev/null; do sleep 10; done
   curl -s -H "Authorization: Bearer $FOUNTAIN_KEY" http://localhost:4000/api/team | jq -c '.data[0].presence'
   ```

   `{"label":"asleep · wakes on message","state":"asleep"}`, about two and
   a half minutes after the reply. The stream printed a `sandbox` stage
   event whose message says the sandbox was suspended after two minutes
   idle. Presence is that event, read as a word. Now message it.

   ```sh
   curl -s -X POST -H "Authorization: Bearer $FOUNTAIN_KEY" -H 'Content-Type: application/json' \
     -d '{"prompt":"Reply with the single word awake."}' http://localhost:4000/api/team/$AGENT/messages
   sleep 2
   curl -s -H "Authorization: Bearer $FOUNTAIN_KEY" http://localhost:4000/api/team | jq -c '.data[0].presence'
   ```

   `{"label":"working","state":"working"}`, and twenty seconds later
   `online` with `awake` as the preview. Same sandbox, same disk, same
   thread, which is lesson 2's wake with a name on it.

8. Take the runner away and read what presence says. This one is optional and it is worth doing once, because it shows presence is a view over something real.

   ```sh
   docker compose -f compose/docker-compose.yml --env-file compose/.env --profile runner stop runner
   sleep 8
   curl -s -H "Authorization: Bearer $FOUNTAIN_KEY" http://localhost:4000/api/team | jq -c '.data[0].presence'
   curl -s -w ' %{http_code}\n' -X POST -H "Authorization: Bearer $FOUNTAIN_KEY" -H 'Content-Type: application/json' \
     -d '{"prompt":"Reply with the single word back."}' http://localhost:4000/api/team/$AGENT/messages
   ```

   `{"label":"machine offline · wakes when the runner reconnects","state":"machine_offline"}`,
   and then `{"status":"queued",...} 202`. The message is accepted and
   waits. The stream printed another `team` event when the runner dropped,
   because presence changed for every teammate on it. Bring the runner
   back and watch it catch up.

   ```sh
   docker compose -f compose/docker-compose.yml --env-file compose/.env --profile runner start runner
   until curl -s -H "Authorization: Bearer $FOUNTAIN_KEY" http://localhost:4000/api/team | jq -e '.data[0].presence.state != "machine_offline"' >/dev/null; do sleep 3; done
   curl -s -H "Authorization: Bearer $FOUNTAIN_KEY" http://localhost:4000/api/team | jq -c '.data[0] | {presence, preview}'
   ```

   `online`, and once the queued turn has run, `back` as the preview.
   Nothing you did touched the conversation. The runner reconnected, the
   sandbox came back with it, and the thread picked up.

9. Remove the teammate, and find the conversation.

   ```sh
   curl -s -o /dev/null -w '%{http_code}\n' -X DELETE -H "Authorization: Bearer $FOUNTAIN_KEY" http://localhost:4000/api/team/$AGENT
   curl -s -H "Authorization: Bearer $FOUNTAIN_KEY" http://localhost:4000/api/team | jq '.data | length'
   curl -s -H "Authorization: Bearer $FOUNTAIN_KEY" "http://localhost:4000/api/conversations?channel_id=fountain:team" | jq '.data | length'
   fountain conv list
   ```

   `204`, then `0`, then `0`, then the conversation in the list with status
   `terminated`. The live conversation ended and its sandbox went with it,
   the binding came off, and the row stayed. The stream printed one more
   `team` event and then went quiet. What you removed was a binding. What
   you keep is the record, every turn of it, under the agent's id.

   Close the stream in the second terminal with Ctrl-C. `f5-stream.log` is
   the whole lesson as events, and the count of `team` events in it is the
   number of times the roster changed.

   ```sh
   grep -c '^event: team' f5-stream.log
   ```

   `4` if you did step 8, one each for the add, the runner dropping, the
   runner reconnecting and the remove. `2` if you skipped it.

## Self-paced

This lesson needs an inference key and makes three short model turns, one word each, in steps 5, 7 and 8. Floci plays no part.

Everything the lesson shows, it shows on the class stack. The one place a hosted provider differs is step 8. A runner is the only backend that can be stopped from your laptop, so `machine_offline` is a presence state you will see here and not on Sprites or E2B, where the sandbox is somebody else's machine. The queued message in that step is worth a second look. Issue 85 expected the stack to refuse a message while the runner is down with a `503`, and the build the class stack pins accepts it and delivers it on reconnect instead, which the [upstream](https://github.com/INTENTIUS/waterpark/blob/main/project/upstream.md) notes record. A message to an offline machine that is silently accepted is a design choice with a cost, and the cost is that the caller has to read presence to know it will wait.

The second message in step 5 races the first. On a fast turn the first finishes before you type the second, and you get a `202` where the page shows a `400`. Both are the same rule. One thread takes one turn at a time and says so.

## Live

Twenty minutes, with the stream on the projector the whole time and the roster beside it.

Open on step 3. One `POST`, and let the room watch a `team` event and then `provision started` arrive on the stream before the response has been read aloud. Then step 4, both calls. The line to say is that the second call never mentioned the team, and it found the same conversation, because the team is a filter on conversations and nothing else.

Then step 5 with the `400`, which lands better live because the facilitator can send the second message the moment the first is queued. Then step 6, and ask the room what two people messaging the same teammate would see. The answer is the same thread, and that is the point rather than a limitation.

Step 8 is the one to do live if there is time, with the runner container stopped in front of the room. The honesty line belongs here. A runner is a computer you can turn off, and Fountain will tell you it is off and hold your message until it is back. A hosted sandbox provider would show you `online` until it was not, and this lesson is where you learn to read the word rather than trust it.

## Further reading

- Fountain `docs/concepts/teammates.md`, why a teammate is not a fifth primitive
- Fountain's own OpenAPI at `/api/openapi.json` on your instance, the Team section, which is where every field here is defined
- [The propose loop](../../propose-loop.md), where the teammate becomes the operator
- [Lesson 2, the sandbox lifecycle](02-sandbox-lifecycle.md), the park and wake presence reports
- [Lesson 6, schedules](06-schedules.md), which run on this teammate
- [Upstream](https://github.com/INTENTIUS/waterpark/blob/main/project/upstream.md), the queued message
