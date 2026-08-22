---
title: "Page model"
---

What a content page is made of, so lessons can be written, filmed, and
scheduled independently. Everything lives in front matter; the layouts in
`layouts/partials/page/` render it; an empty field renders as a TODO
marker rather than disappearing, so a half-written lesson is visibly
half-written.

## Kinds of page

| Kind | Where | Layout | Has |
|---|---|---|---|
| home | `content/_index.md` | `index.html` | intro, optional video, the course cards |
| courses index | `content/courses/_index.md` | `list.html` | intro, course cards |
| course | `content/courses/<course>/_index.md` | `list.html` | intro (text or video), optional activity, the lesson list |
| lesson | `content/courses/<course>/NN-slug.md` | `single.html` (lesson) | card, optional video, optional activity, body, pager |
| properties | `content/properties.md` | `properties.html` | the fourteen properties from `data/properties.yaml`, each with the lessons that demonstrate it |
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
## Back office   links into content/docs for depth
```

## Markers

`{{</* todo "note" */>}}` renders a visible TODO chip. Use it for anything
unwritten; the build does not fail on it, so a TODO that ships is a
choice, not an accident. `just todos` lists them.

## Scaffolding

`just new iam 16 I16 "Title"` writes a lesson file with this front matter
and these headings.
