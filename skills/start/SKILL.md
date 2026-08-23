---
name: waterpark-start
description: Walk a student through water park's Start here page. Use when someone says they want to begin the courses, set up for them, or check what they have installed. Asks what they have, runs the checks, writes .waterpark/profile.json, and points at the first lesson.
---

# water park, Start here

You are walking a student through the Start here page of water park
(https://intentius.io/waterpark/start/). The outcome is a working setup
for the Fountain course and a profile file the next lesson can read.

## 1. Say what this is

Tell the student, in three sentences, what the two courses are and that
this step takes about ten minutes. Ask which mode they want: self-paced
(their laptop, Floci, no AWS account) or live (a facilitator brings real
accounts). Default to self-paced.

## 2. Ask for what you need

Ask, one at a time, with a default and "skip" allowed:

1. Their Fountain URL. Default `http://localhost:4000`. If they have none,
   offer the self-host path in step 4.
2. Whether they have an inference key (Anthropic or another provider).
   Do not ask for the key itself.
3. A GitHub repo they own for the Fountain course, as `owner/name`.
4. Self-paced only, whether they want Floci installed now.

## 3. Run the checks

Run `bash check.sh` from this skill's directory and show the student the
output. It reports, as JSON, whether `docker`, `fountain`, `floci`, `aws`,
`jq` and `gh` are installed and versions, whether the Fountain URL answers,
whether `fountain auth status` is logged in, and whether Floci answers on
its endpoint. Do not guess at any of these.

## 4. Fix what is missing

For each missing item, give the exact command and wait.

- Fountain, self-hosted. `cp .env.compose.example .env` then
  `docker compose up -d` in a Fountain checkout, then `fountain auth login`.
- The `fountain` CLI. `brew install BinaryBourbon/tap/fountain`.
- Floci. `floci start` from the Floci CLI, then `eval $(floci env)`.
- `aws`, `jq`, `gh`. The package manager they already use.

Re-run `check.sh` after each fix.

## 5. Verify done when

Done when `check.sh` shows Fountain reachable and logged in, and, for
self-paced, Floci answering. If not, say which item failed and stop here.

## 6. Record and hand off

Write or update `.waterpark/profile.json` in the student's working
directory:

```json
{"mode":"self-paced","fountain_url":"…","repo":"owner/name","floci":true,"completed":["start"]}
```

Then say the next step is the Fountain course, lesson 1, Four primitives
(https://intentius.io/waterpark/courses/fountain/01-four-primitives/) and
that its skill, when it exists, will read this profile.
