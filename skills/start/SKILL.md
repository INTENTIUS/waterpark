---
name: waterpark-start
description: Walk a student through water park's Start here page. Use when someone wants to begin the courses or set up. Clones water park, gets Fountain installed and logged in, checks the tools, writes .waterpark/profile.json, and points at the first lesson.
---

# water park, Start here

You are walking a student through Start here
(https://intentius.io/waterpark/start/). The outcome is a water park
checkout, a working Fountain they are logged in to, and a profile file the
next lesson reads. Ten minutes.

## 1. Say what this is

In three sentences say what the two courses are and that this step gets
two things installed, water park and Fountain. Ask which mode they want,
self-paced (their laptop, Floci, no AWS account) or live (a facilitator
brings accounts). Default to self-paced.

## 2. Get water park

Run `bash check.sh` from this skill's directory. If `waterpark.checkout`
is false, clone it and move there.

```sh
git clone https://github.com/INTENTIUS/waterpark && cd waterpark
```

If it is true, `git pull`. The skills, the check scripts, the student's
profile and the exercises all live in this checkout. The student does not
need a repo of their own. Offline reading of the site is
`docker run --rm -p 8080:80 ghcr.io/intentius/waterpark`, optional.

## 3. Get Fountain

Ask whether they already have a Fountain instance. If yes, take its URL.
If no, self-host one.

1. Clone Fountain at the location recorded in
   https://intentius.io/waterpark/docs/upstream/ (the canonical repo is
   being verified there, so read it rather than assume).
2. In that checkout, `cp .env.compose.example .env`, fill the generated
   keys as the file says, then `docker compose up -d`. The instance is at
   `http://localhost:4000`.
3. Install the CLI. `brew install BinaryBourbon/tap/fountain` on macOS, or
   the release binary from the same tap page.
4. `fountain auth login` against the URL.
5. Open the instance once in a browser and finish onboarding. Fountain asks
   for an inference key there (Anthropic first, other providers when a
   model needs them). Do not ask the student for the key and never store it.

Re-run `check.sh` and confirm `fountain.reachable` and
`fountain.logged_in` are both true before moving on.

## 4. Self-paced extras

For self-paced, install Floci if `tools.floci.installed` is false, then
`floci start` and `eval $(floci env)`. Confirm `floci.reachable`. Install
`aws`, `jq` and `gh` with the package manager they already use if missing.
For live, skip this step.

## 5. Verify done when

Done when `check.sh` shows a water park checkout, Fountain reachable and
logged in, and, for self-paced, Floci reachable. If anything is false,
name it and stop. Nothing in the lessons works around a missing Fountain.

## 6. Record and hand off

Write `.waterpark/profile.json` at the checkout root.

```json
{"mode":"self-paced","waterpark_root":"…","fountain_url":"…","floci":true,"completed":["start"]}
```

Say the next step is the Fountain course, lesson 1, Four primitives
(https://intentius.io/waterpark/courses/fountain/01-four-primitives/), and
that its skill reads this profile.
