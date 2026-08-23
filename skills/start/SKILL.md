---
name: waterpark-start
description: Walk a student through water park's Start here page. Use when someone wants to begin the courses or set up. Clones water park, gets Fountain installed and logged in, checks the tools, writes .waterpark/profile.json, and points at the first lesson.
---

# water park, Start here

You are walking a student through Start here
(https://intentius.io/waterpark/start/). The outcome is a water park
checkout, a Fountain instance they are logged in to, and a profile file
the next lesson reads. About ten minutes.

Confirm with the student before each step that installs software, starts
a service, or writes a file. Those steps are marked **confirm**.

## 1. Say what this is

In three sentences say what the two courses are and that this step gets
two things in place, water park and Fountain. Ask which mode they want,
self-paced (their laptop, Floci, no AWS account) or live (a facilitator
brings accounts). Default to self-paced.

## 2. Get water park

If the current directory is not a water park checkout (no `hugo.toml` and
no `skills/start/SKILL.md`), **confirm**, then clone it and move there.

```sh
git clone https://github.com/INTENTIUS/waterpark && cd waterpark
```

If it is a checkout, `git pull`. The skills, the check script, the
student's profile and the exercises live here. The student does not need
a repo of their own.

## 3. Run the check

Run `bash skills/start/check.sh` from the checkout and show the output.
The script only reads. It reports, as JSON, whether this is a water park
checkout, which of `docker`, `fountain`, `floci`, `aws`, `jq` and `gh`
are installed with versions, whether the Fountain URL answers and the CLI
is logged in, and whether Floci answers. Read it before you run it if you
want. Do not guess at anything it can report.

## 4. Get Fountain

Ask whether the student already has a Fountain instance. If yes, take its
URL and set `FOUNTAIN_URL` for the rest of the session. If no, self-host
one.

1. The Fountain repo is https://github.com/BinaryBourbon/fountain. If it
   is not reachable, stop and ask the student where their copy is or for
   an instance URL. Do not look elsewhere for it.
2. **confirm**, then in a Fountain checkout, `cp .env.compose.example .env`,
   fill the generated keys as the file says, and `docker compose up -d`.
   The instance is at `http://localhost:4000`.
3. **confirm**, then install the CLI with `brew install BinaryBourbon/tap/fountain`
   on macOS, or the release binary from that tap.
4. `fountain auth login` against the URL. The student types their
   credentials, not you.
5. Ask the student to open the instance in a browser once and finish
   onboarding. Fountain asks for an inference key there. Never ask for
   the key and never store it.

Re-run `bash skills/start/check.sh` and confirm `fountain.reachable` and
`fountain.logged_in` are both true before moving on.

## 5. Self-paced extras

For self-paced, if `tools.floci.installed` is false, **confirm**, then
install Floci, `floci start`, and `eval $(floci env)`. Confirm
`floci.reachable`. If `aws`, `jq` or `gh` are missing, **confirm**, then
install them with the package manager the student already uses. For
live, skip this step.

## 6. Verify done when

Done when the check shows a water park checkout, Fountain reachable and
logged in, and, for self-paced, Floci reachable. If anything is false,
say which and stop. Nothing in the lessons works around a missing
Fountain.

## 7. Record and hand off

**confirm**, then write `.waterpark/profile.json` at the checkout root.

```json
{"mode":"self-paced","waterpark_root":"…","fountain_url":"…","floci":true,"completed":["start"]}
```

Say the next step is the Fountain course, lesson 1, Four primitives
(https://intentius.io/waterpark/courses/fountain/01-four-primitives/), and
that its skill reads this profile.
