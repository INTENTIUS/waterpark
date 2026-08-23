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
4. Do the steps, or tell the student the exact command when the step must be
   theirs (anything that spends money, touches a real account, or approves).
5. Verify *done when*. If it fails, name the restart point from the card.
6. Write progress to `.waterpark/profile.json` in the student's working
   directory so the next skill can pick up.

## Link from a page

A lesson's front matter names its skill. The page links the raw `SKILL.md`
so an agent can read it directly, and shows the one line to paste.

```yaml
skill: "skills/start"
```

## Status

| Skill | Drives | State |
|---|---|---|
| `start` | Start here. Clone water park, install and log in to Fountain, Floci for self-paced. | first draft |
