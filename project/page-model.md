What a content page is made of, so lessons can be written, filmed, and
scheduled independently. Everything lives in front matter; the layouts in
`layouts/partials/page/` render it; an empty field renders as a TODO
marker rather than disappearing, so a half-written lesson is visibly
half-written.

## Kinds of page

| Kind | Where | Layout | Has |
|---|---|---|---|
| home | `content/_index.md` | `index.html` | intro, optional video, Start here, the course cards |
| start | `content/start.md` | `single.html` (page) | setup, self-paced vs live, order |
| courses index | `content/courses/_index.md` | `list.html` | intro, course cards |
| course | `content/courses/<course>/_index.md` | `list.html` | intro (text or video), optional activity, the lesson list |
| lesson | `content/courses/<course>/NN-slug.md` | `single.html` (lesson) | card (properties, goal, done when, restart from, mode + time), optional skill link, optional video, optional activity, body, pager |
| page | `content/propose-loop.md`, `content/docs/**` | `single.html` (page) | optional video, optional activity, body |

A lesson may have a video, an activity, or both. A lesson with neither is
a read, and should be rare.

## Lesson front matter

```yaml
title: "The egress allowlist"
id: "F3"                        # stable id used by the back office
lesson: 3                       # number within the course
weight: 3                       # ordering (= lesson)
summary: "…"                    # one line under the title in lists
skill: "skills/f3"              # optional. a directory in this repo with a SKILL.md that walks a student through the lesson
# the card (empty => TODO on the page)
goal: ""                        # one paragraph, imperative, what you'll do
done_when: ""                   # the check
restart_from: "lesson 1"        # where to restart if it breaks
properties: ["VI"]              # Accessible Ops roman numerals; rendered with names and links
closes: ["P4"]                  # prescriptions closed (IAM course)
# media
video:
  provider: todo                # youtube | vimeo | file | todo
  id: ""                        # youtube/vimeo id
  src: ""                       # file: path under static/
  poster: ""                    # file: optional
  title: ""                     # caption
  length: ""                    # "6 min"
# activity
activity:
  kind: hands-on                # hands-on | watch-along | discuss
  time: ""                      # "10 min"
  needs: []                     # ["a Fountain instance", "a repo you own"]
  solo: true                    # runs self-paced
  live: true                    # runs live with a facilitator
```

Omit `video:` or `activity:` entirely when a lesson has none; the block is
not rendered. `provider: todo` renders a placeholder frame.

## Lesson body

Headings in this order; a section may be dropped if it does not apply.

```
## Context       short bullets: what's underneath, sources, constraints — not final copy
## Watch         the video's script or talking points (if there is a video)
## Do            the activity: numbered steps, imperative, one job
## Self-paced    what Floci / your own machine can and cannot show
## Live          what the room sees; timing; the honesty line
## Further reading   links into content/docs for depth
```

## Markers

`{{</* todo "note" */>}}` renders a visible TODO chip. Use it for anything
unwritten; the build does not fail on it, so a TODO that ships is a
choice, not an accident. `just todos` lists them.

## Scaffolding

`just new iam 16 I16 "Title"` writes a lesson file with this front matter
and these headings.

## Skills

A page with `skill:` set shows a "Run with an agent" block linking the
skill directory and the install commands. Skills live in [`skills/`](https://github.com/INTENTIUS/waterpark/tree/main/skills),
one per section or lesson, each a `SKILL.md` and its scripts, following the
contract there. `just skills` lists them and checks the frontmatter.

## Authoring checklist, learned from lesson 1

What made lesson 1 land, in order. Every later lesson follows it.

1. Read the upstream source, then verify every command on a live stack
   before writing it. The upstream doc was wrong once already (list-form
   secrets silently apply as zero, the contract is a map). Trust runs,
   not docs.
2. Write the lesson page first. The skill copies the page's exact
   filenames, object names and commands. The student-run found that a
   `manifest.yaml` vs `f1-manifest.yaml` mismatch between page and skill
   is a stumble even when each is internally consistent.
3. Ids are not names. `fountain env show` takes an id, `env list` does
   not print one by default. Any step that says "find the id" must show
   the exact command that produces it, verified.
4. The skill's done-when must verify the same fact the page's done_when
   states, against the same endpoint.
5. No visible TODO ships on a student-path page. Video blocks and Watch
   sections are added when a video exists, not before.
6. The lesson is done only after an adversarial student run: a fresh
   clone, site-only knowledge, every stumble filed and fixed, re-run
   clean. Budget roughly one fix round.
7. Prose bans em dashes, colons and semicolons outside code. Check
   mechanically, not by eye.
