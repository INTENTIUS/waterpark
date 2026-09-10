---
name: waterpark-f11-no-gate-in-fountain
description: Walk a student through Fountain lesson 11, No approval gate in Fountain, the closing lesson of the course. Use when they want lesson 11, or when they ask what stops an agent on Fountain. Has an agent write a file with nobody asked, reads the runtime's command line off the runner mid-turn for the bypass flag, pages the conversation's events and counts zero permission requests, asks for something destructive and hears the model decline on its own judgment, reads ADR 0016's status, and fills the gate table. Two model turns.
---

# water park, Fountain lesson 11, No approval gate in Fountain

You are walking a student through Fountain lesson 11, No approval gate in
Fountain
(https://intentius.io/waterpark/courses/fountain/11-no-gate-in-fountain/).
The outcome is the runtime's own flag read off the running process, a record
with a write in it and no permission request, a model's refusal read as
what it is, and the table of where every gate the course has met actually
is. About 20 minutes, and it closes the Fountain course.

Confirm with the student before applying the manifest, before each of the
two turns, before the terminate, and before the `rm -rf` on the runner.
Those steps are marked **confirm**. Reads run freely, which is the process
loop, the events paging, the disk reads and `fountain conv list`.

This lesson makes two model turns, the write in 3c and the refusal in 3f.
Say so before the first one. Say also that the second prompt asks for a
deletion inside the sandbox's own directory, that the directory is rebuilt
on the next provision, and that the runtime is expected to decline it.

## 1. Say what this is

In two or three sentences say this is the last lesson of the Fountain
course, that every runtime Fountain ships runs with its permission prompt
bypassed because a headless CLI has no channel back to a human, that the
audit trail is therefore a record and never a refusal, and that the gate
lives where the write lands. Link the lesson page above.

## 2. Check the ground

Run the same check Start here uses.

```sh
bash skills/start/check.sh
```

Also read `.waterpark/profile.json` at the checkout root if it exists.
Trust what it says about the student only when the check's own
`fountain.logged_in` is `true` and `fountain.email` matches the profile's
`email`. A profile file is a claim from a previous run. The check's live
call is the truth, so when they disagree believe the check.

Require, from the check's `fountain` object, `reachable` true, `logged_in`
true, `runner_online` true and `inference_set` true. If `inference_set` is
false, send the student to Start here step 7 and wait. Never ask the
student for an inference key and never go looking for one.

`jq` and `curl` are needed, and `just runner-sh` reads `compose/.env`, so
this runs in the checkout `just up` ran in, or in a second checkout after
`bash compose/bin/env.sh` there. Ask the student to open a second terminal
for the process loop.

Run `fountain conv list` before starting. An account holds two sandboxes at
once and this lesson uses one. If an earlier lesson left a conversation
that is not `terminated`, offer to terminate it by its full id first.

## 3. The lesson

### 3a. A plain agent

The student writes `f11-manifest.yaml` from step 1 of the lesson page,
which is `content/courses/fountain/11-no-gate-in-fountain.md` in this
checkout. Read it from there.

**confirm**, then

```sh
fountain apply -f f11-manifest.yaml
```

`env  +  lesson11-env` and `agent  +  lesson11-agent`. Then the key, from
step 1.

(PowerShell reads the credentials file with
`Select-String -Path "$env:USERPROFILE\.fountain\credentials" -Pattern api_key`
and sets `$env:FOUNTAIN_KEY` from the match. The curl calls are identical
on every OS.)

### 3b. The loop, ready

Have the student put the process loop from step 2 of the page on the
second terminal, from the checkout root, and not start it yet. Say what it
does, which is list every process on the runner whose command line mentions
claude, once a second for a minute, and keep the unique lines.

### 3c. A side effect with nobody asked

**confirm**, then have the student start the loop in the second terminal
and, in the first, the run from step 3. `[Write] ✓ completed`,
`[Terminal] ✓ completed`, `done`. Say that nothing between those two lines
asked anyone anything. Keep the conversation id.

### 3d. The runtime's command line

When the loop finishes, the `grep` from step 4 on `f11-procs.txt`. Five
lines, `--permission-prompt-tool` then `stdio`, `--permission-mode` then
`default`, and `--allow-dangerously-skip-permissions`. Walk them. The
permission prompt is wired to standard input, and on the other end is the
ACP adapter Fountain drives, not a person. The mode is default. The flag
that allows skipping is set. If the grep finds nothing, the loop started
after the turn's twelve-second sleep ended, and the fix is to run 3c again
with the loop started first.

### 3e. The record

The paging loop from step 5, then the three reads. `Write  edit` and
`Terminal  execute`, then `0` for `request_permission`, then `hello` from
the disk. Say that this is the whole of what the audit trail can say, an
account of what happened that was never positioned to say anything was not
allowed to.

### 3f. The refusal that is not a gate

**confirm**, then the prompt from step 6. The runtime declines, in its own
words, and say what it said when the page was written, that the phrasing
read like a probe and it would do either thing if asked plainly. Then the
count and the directory listing. Still `0`, and `.npm-global` still there.

Walk the two facts apart. The directory survived because a model decided
it should, on the strength of a sentence. No request went to anyone and no
rule was evaluated. A different prompt or runtime deletes it with the same
zero in the record. A gate says no whatever the prompt says.

If the runtime complies instead of declining, say the lesson has shown the
stronger form of the same fact, and that the directory is the sandbox's own
and comes back on the next provision.

### 3g. The decision record

Read the ADR 0016 status quote from step 7 with the student, and the two
sentences it turns on, Fountain can observe and it cannot intervene, and
the governance layer is not built. Say that the course uses Fountain as it
is and this is the one place it reads what it is not yet.

### 3h. The gate table

Show the student the table in step 8 and read it one row at a time,
ending on the sandbox row. Say that every gate is outside Fountain and
inside the thing being written to, that this is the design and not a
workaround, and that decision 14 is the table in one sentence.

### 3i. Tidy up

**confirm**, then the terminate from step 9. **confirm**, then the runner
shell line with the `rm -rf`. Say that the Fountain course ends here and
point at IAM lesson 12.

## 4. Done when

All three have to be true, checked against the files rather than the
student's memory.

- `f11-procs.txt` holds a line with `--allow-dangerously-skip-permissions`.
- `f11-events.json` holds a `tool_call` with title `Write` and
  `grep -c request_permission` on it is `0`, and the runner disk had
  `unasked.txt` reading `hello` before the tidy up.
- The gate table names a gate outside Fountain for Mend, Rounds, dns-desk
  and the IAM course, and `nothing` for the sandbox, and the student can
  say where each is.

If the first fails, restart from 3c with the loop running before the turn.
If the events file is short, the paging loop stopped early, run it again.

## 5. Record

**confirm**, then update `.waterpark/profile.json` at the checkout root,
appending `"f11"` to its `completed` array, keeping everything already in
it, creating the file and the array if either is missing. Leave every other
field untouched.

```json
{"...": "...", "completed": ["start", "f1", "f2", "f3", "f4", "f5", "f6", "f10", "f11"]}
```

## 6. Hand off

Say the Fountain course is complete apart from lessons 7 to 9, which wait
on the AWS desk and are not written yet, and that the next step is IAM
lesson 12, the concierge
(https://intentius.io/waterpark/courses/iam/12-the-concierge/), where the
gate is a pull request. Tell the student plainly that lesson 12 is not
written yet either, so the link is a placeholder, and that IAM lessons 1
to 11 are.
