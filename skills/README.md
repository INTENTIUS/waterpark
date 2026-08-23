# Skills

One skill per section or lesson. A skill is a `SKILL.md` (frontmatter `name`
and `description`, then instructions) plus any scripts it calls, in
`skills/<id>/`. An agent that loads it walks a student through the section
like a wizard. It asks for what it needs, runs the checks, does or explains
each step, verifies the lesson's *done when*, and records where the student
stopped.

## Use

Claude Code, in a checkout of this repo, loads skills from the repo when
they are linked under `.claude/skills/`. Or copy one.

```sh
mkdir -p ~/.claude/skills && cp -r skills/start ~/.claude/skills/waterpark-start
```

The skills.sh CLI can install from the repo directly.

```sh
npx skills add INTENTIUS/waterpark
```

A Fountain agent takes the same repo as a GitHub-sourced skill.

```yaml
spec:
  skills:
    - source: INTENTIUS/waterpark
```

## Contract

Every skill follows the same shape so a student knows what to expect.

1. Say which lesson this is and what *done when* means for it.
2. Ask only for what the lesson needs. Offer defaults. Accept "skip".
3. Run the lesson's checks with the scripts in the skill directory. Show the
   output. Never guess at state the script can report.
4. Do the steps. Confirm with the student before anything that installs
   software, starts a service, writes a file, spends money, touches a real
   account, or approves. Mark those steps **confirm** in the skill so the
   agent's caution and the skill's flow line up.
5. Never fetch and execute code from a URL. Clone the repo, then run its
   scripts from the checkout, and say in the skill what each script does.
6. Never ask the agent to discover a repo location from a web page. Name
   the location. If it is unreachable, stop and ask the student.
7. Verify *done when*. If it fails, name the restart point from the card.
8. Write progress to `.waterpark/profile.json` in the student's working
   directory so the next skill can pick up.

## Link from a page

A lesson's front matter names its skill. The page shows a one-line prompt
with a copy button that has the agent fetch the raw `SKILL.md` with curl
and follow it, and links the file for humans.

```yaml
skill: "skills/start"
```

## Status

| Skill | Drives | State |
|---|---|---|
| `start` | Start here. Clone water park, install and log in to Fountain, Floci for self-paced. | first draft |
