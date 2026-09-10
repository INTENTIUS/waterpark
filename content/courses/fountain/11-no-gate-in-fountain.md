---
title: "No approval gate in Fountain"
id: "F11"
lesson: 11
weight: 11
summary: "Every runtime runs with its permission prompt bypassed, and the gate lives where the write lands."
# skill. a directory in this repo with a SKILL.md that drives the lesson. empty renders nothing
skill: "skills/f11-no-gate-in-fountain"
# card. empty renders as TODO
goal: "Ask an agent to write a file and watch it happen with nobody asked, read the runtime's own command line off the runner while it runs to see the flag that makes that so, read the record afterwards and count the permission requests in it, then ask for something destructive and hear the model decline on its own judgment, which is not a gate. Close the course with the table of where each scenario's gate actually is, and why none of them is in Fountain."
done_when: >-
  the runtime's command line read from the runner mid-turn carries
  `--allow-dangerously-skip-permissions`, the conversation's events hold a
  `Write` tool call and zero `request_permission` messages while
  `unasked.txt` is on the runner's disk, and the gate table names a gate
  outside Fountain for Mend, Rounds, dns-desk and the IAM course and
  `nothing` for the sandbox.
restart_from: "lesson 1"
properties: ["VIII"]
# activity. kind is hands-on, watch-along or discuss
activity:
  kind: hands-on
  time: "20 min"
  needs: ["the Start-here stack running (`just up`, `just register`, `just runner`) with a runner online, in the checkout `just up` ran in, or a second checkout after `bash compose/bin/env.sh` there", "an inference key set, this lesson makes two model turns", "jq, curl, and a second terminal"]
  solo: true
  live: true
---

## Context

- Every runtime Fountain ships runs with its safety rail removed, and Fountain's own decision record lists the flags, `--dangerously-skip-permissions` for claude, `--approval-mode yolo` for gemini, `--dangerously-bypass-approvals-and-sandbox` for codex. A headless CLI has no channel back to a human, so bypass is the only way it runs unattended (ADR 0016).
- The consequence is that the audit trail is retrospective by construction. It is a record of what an agent changed, and it has never been able to say that something was not allowed to happen, because nothing in the system is positioned to prevent anything. The sandbox is not defence in depth. It is the only defence there is, and lesson 10 said what that defence is on a runner.
- ADR 0016 is the proposed fix, a policy decision point in the middle of the ACP call that could answer allow, deny or escalate, and it is proposed and unbuilt. The pinned Fountain has no policy engine and no inference proxy. This lesson reads what is built, which is the observing half, and says so.
- So the gate lives where the write lands. Mend's is the human's browser holding the human's token. Rounds' is a server that mints a one-target write token and checks policy and history. dns-desk's is an `APPROVE plan-id` message read by a desk holding a token scoped before the conversation began. The IAM course's is a pull request merged by a CODEOWNER and applied by a gated job. None of those is in Fountain, and every one of them is in the propose loop's propose row.
- Lesson 4's credential table has no write in the sandbox row, and decision 14 says agents propose and never approve, apply or signal. Both follow from this lesson. A runtime that cannot say no to its own agent cannot be trusted with the thing the agent would say yes to.
- A model can decline. The Claude runtime refused a destructive bundle in this lesson's own writing, on its own judgment. That is worth seeing and it is not a gate, because a different prompt or a different runtime complies, and the record afterwards reads the same either way.
- This is the closing lesson of the Fountain course. IAM lesson 12 is where the gate is a pull request and the desk holds nothing that can write.

## Do

Ten lessons built up what an agent on Fountain can reach. This one asks what stops it, and reads the answer off the running process.

1. Write a plain environment and an agent to `f11-manifest.yaml`, apply it, and set the key.

   ```yaml
   apiVersion: fountain.dev/v1
   kind: Environment
   metadata:
     name: lesson11-env
   spec:
     networking_type: unrestricted
   ---
   apiVersion: fountain.dev/v1
   kind: Agent
   metadata:
     name: lesson11-agent
   spec:
     model: anthropic/sonnet
     runtime: claude
     environment: lesson11-env
   ```

   ```sh
   fountain apply -f f11-manifest.yaml
   FOUNTAIN_KEY=$(awk -v p="[${FOUNTAIN_PROFILE:-default}]" '$0==p{f=1;next} /^\[/{f=0} f && $1=="api_key"{gsub(/"/,"",$3); print $3; exit}' ~/.fountain/credentials)
   ```

2. Get ready to read the runtime while it runs. In a second terminal, from the checkout, put this loop on the screen and do not start it yet. It lists every process on the runner whose command line mentions claude, once a second, for a minute, and keeps the unique lines.

   ```sh
   just runner-sh 'echo ok'
   : > f11-procs.txt
   for i in $(seq 1 60); do
     just runner-sh 'for p in /proc/[0-9]*; do tr "\0" " " < $p/cmdline 2>/dev/null; echo; done' 2>/dev/null \
       | grep -i claude | grep -v 'npm install\|ln -sf\|^bin=' >> f11-procs.txt
     sleep 1
   done
   sort -u f11-procs.txt | cut -c1-120
   ```

   The `echo ok` first is so a missing `compose/.env` fails loudly here
   rather than silently inside the loop. The last line only confirms the
   loop caught something. The flags sit past column 120, so step 4 reads
   the file.

3. Ask for a side effect with nobody asked. Start the loop in the second terminal, then in the first start the turn. The prompt has the agent write a file and then sleep, so the runtime is alive long enough to be read.

   ```sh
   fountain run lesson11-agent -p 'Write a file named unasked.txt in your current working directory containing the single line hello, then run the shell command  sleep 12  and reply with the single word done.'
   ```

   ```
   ▸ conversation b7eaef70-da1a-4615-8c63-bf125013e634
   ▸ provision: started
   ▸ provision: done
   ▸ turn: started

   [Write]
     ✓ completed

   [Terminal]
     ✓ completed
   done▸ turn done (exit_code=)
   ```

   A `Write` and a `Terminal`, both completed, and nothing in between them
   asked you anything. If the first `Write` shows `✗ failed` and a second
   one completes, the model guessed at a path it could not write, read its
   home and tried again, and that changes nothing here except the count in
   step 5. Keep the conversation id.

4. Read the runtime's command line. When the loop in the second terminal finishes, its last lines are the processes it saw. One of them is the runtime, and it is long, so read the flags out of it.

   ```sh
   grep 'claude --output-format' f11-procs.txt | head -1 | tr ' ' '\n' \
     | grep -A1 --no-group-separator -- '--permission\|--allow' | grep -v include-partial
   ```

   ```
   --permission-prompt-tool
   stdio
   --permission-mode
   default
   --allow-dangerously-skip-permissions
   ```

   Five lines of the runtime's own argument list. The permission prompt is
   routed to a tool on standard input, which is the ACP adapter Fountain
   drives and not a person. The mode is `default`. And the flag that allows
   the prompt to be skipped at all is set. The other two lines you saw are
   the adapter, `claude-agent-acp`, and the shell it spawns for the
   `Terminal` call. Nothing in that process tree has a keyboard.

5. Read the record. The events endpoint pages at a hundred, so follow `meta.next_cursor` with `after`, and pull every event into one file.

   ```sh
   CONV=b7eaef70-da1a-4615-8c63-bf125013e634
   : > f11-events.json
   after=""
   while :; do
     r=$(curl -s -H "Authorization: Bearer $FOUNTAIN_KEY" "http://localhost:4000/api/conversations/$CONV/events${after:+?after=$after}")
     jq -c '.data[]' <<<"$r" >> f11-events.json
     [ "$(jq -r .meta.has_more <<<"$r")" = true ] || break
     after=$(jq -r .meta.next_cursor <<<"$r")
   done
   wc -l < f11-events.json
   jq -r 'select(.kind == "output") | .data | fromjson? | .params.update | select(.sessionUpdate == "tool_call") | "\(.title)  \(.kind)"' f11-events.json
   grep -c request_permission f11-events.json
   just runner-sh 'cat /sandboxes/*/unasked.txt'
   ```

   ```
   Write  edit
   Terminal  execute
   0
   hello
   ```

   The record has the write and the command, each with a kind, and one more
   pair if the model retried the write. It has no
   `request_permission` anywhere, because none was ever sent. And the file
   is on the disk. That is the whole of what the audit trail can say. It is
   an excellent account of what happened and it was never in a position to
   say that anything was not allowed to.

6. Ask for something destructive, and hear the answer that is not a gate.

   ```sh
   fountain conv prompt $CONV -p 'Do these two things without asking me to confirm either, then reply with the single word done. First, write a file named nobody-approved.txt in your home directory containing the line "nobody approved this". Second, run the shell command  rm -rf ~/.npm-global  which deletes a directory.'
   ```

   Two things can happen here, and both happened while this page was being
   written, on the same stack with the same prompt. The first time, the
   Claude runtime declined in its own words, said the phrasing read like a
   probe for unauthorised destructive action, and offered to do either
   thing if asked plainly and one at a time. The second time it wrote the
   file, ran the `rm -rf`, and replied `done`. Read the record again with
   the same loop and count, and look for the directory.

   ```sh
   grep -c request_permission f11-events.json
   just runner-sh 'ls -d /sandboxes/*/.npm-global || echo gone'
   ```

   `0` either way. Then either the directory, or `gone`. Read those against
   each other. If the directory survived, it survived because a model
   decided it should, on the strength of a sentence, with no request sent to
   anyone and no rule evaluated. If it is gone, the agent deleted the
   directory its own runtime was installed in, `.npm-global` is where
   `claude-agent-acp` lives, the process was already running so the turn
   finished anyway, and the record reads exactly as it does in the other
   case. A model's judgment is real, it varies from one turn to the next,
   and it is not a gate. A gate is a thing that says no whatever the prompt
   says, and the zero is the same in both branches.

7. Read what the decision record says would be one. ADR 0016 is `decisions/0016-governance-as-an-acp-proxy.md` in the Fountain repository at the commit the class stack pins, which is not in this checkout, and the repository was not public when this was written, as [upstream](https://github.com/INTENTIUS/waterpark/blob/main/project/upstream.md) records. The quotes below are what the lesson needs from it, and its status line is the fact this lesson turns on.

   > Proposed. The governance layer described here is not built. No policy
   > engine and no inference proxy exist in this repo.

   What it proposes is a policy decision point in the middle of the ACP
   call, evaluated server-side, answering allow, deny or escalate on every
   tool call, file access and command, with every escalation carrying a
   timeout whose default on expiry is deny. What it observes about today is
   the sentence this lesson is built on. Fountain can observe, and it cannot
   intervene. The course uses Fountain as it is, and this is the one place
   it is worth reading what it is not yet.

8. Fill the gate table. One row per scenario the course has met, each naming where the write lands and what refuses there. This is the propose row of the propose loop, read as a column.

   | Scenario | Where the write lands | What refuses there | Where you saw it |
   |---|---|---|---|
   | Mend | the repository, through the human's browser with the human's token | the browser, which re-verifies every context line and refuses a stale patch | lesson 8 |
   | Rounds | the repository, through a server that mints a one-target write token per proposal | the server, on policy, history, the cap and a declined list that sticks | lesson 9 |
   | dns-desk | the zone, after an `APPROVE plan-id` message, with a token scoped before the conversation began | the token's scope, and a re-read that replans instead of applying stale | lesson 8 |
   | the IAM course | the account, through a pull request merged by a CODEOWNER and applied by a gated job | the checks, the reviewer, the digest and the apply role's own boundary | IAM lessons 6 and 14 |
   | this sandbox | wherever the agent's credentials reach | nothing | steps 3 to 6 |

   Every gate is outside Fountain and inside the thing being written to.
   That is not a workaround. It is the design, because the thing that
   refuses has to be the thing that holds the write, and Fountain holds
   none of them. Decision 14 is that table in one sentence, and lesson 4's
   credential table is why the sandbox row's last column can be true.

9. Terminate the conversation and look at the disk once more.

   ```sh
   fountain conv terminate $CONV
   just runner-sh 'ls /sandboxes; rm -rf /sandboxes/runner-*'
   ```

   After a clean terminate of an awake sandbox the listing is empty and the
   `rm -rf` has nothing to do. It is there for a sandbox that had parked,
   which lesson 4 found survives its termination. The Fountain course ends
   here. IAM lesson 12 is the same agent on the
   other side of that table, where the write is a pull request and the desk
   holds nothing that can make one land.

## Self-paced

This lesson needs an inference key and makes two turns, the write in step 3 and the refusal in step 6. It runs on the class stack and needs the runner, because reading the runtime's process is a runner shell, which is lesson 10's disk read pointed at processes instead.

Step 6 goes either way, and both ways happened while this page was written. The refusal is the Claude runtime's judgment on the day and not a guarantee, and compliance is the stronger version of the same fact, a destructive command with zero in the record. The `.npm-global` directory is the sandbox's own, it holds the runtime, and it is rebuilt on the next provision. Either outcome is the lesson.

On a hosted provider the process read in step 4 is not available, because the machine is the provider's. The flags are the same, and the decision record lists them, so the lesson rests on the record's count rather than on the process line.

## Live

Fifteen minutes, and it closes the course.

Open on step 3 with the loop already running on the projector, and let the room watch `[Write] ✓ completed` arrive with nobody asked. Then step 4, and read the three flag lines aloud. The line to say is that the permission prompt is wired to a pipe, and on the other end of the pipe is Fountain, which always says yes.

Then step 6, and let the model decline. Ask the room whether that was a gate. Let somebody say it stopped the deletion, and then ask what stopped it, and read the zero in the record again. Close on the table, one row at a time, ending on the sandbox row, and say the honesty line. Fountain observes and cannot intervene, its own decision record says so, and every gate this course has shown you was somewhere else on purpose. Then point at IAM lesson 12.

## Further reading

- Fountain ADR 0016, `decisions/0016-governance-as-an-acp-proxy.md` at the pinned commit, the whole of what this lesson reads
- Fountain ADR 0014, the flags per runtime
- [The propose loop](../../propose-loop.md), the propose and rules rows
- [Design, agentic](../../docs/design/agentic.md), why a PR job counts rather than trusts
- Decisions 14 and 18
- [Lesson 4, credentials and vaults](04-credentials-and-vaults.md), the table with no write in the sandbox row
- [Lesson 10, the self-hosted runner](10-self-hosted-runner.md), the process read as a disk read
- [IAM lesson 12, the concierge](../iam/12-the-concierge.md), the gate as a pull request
