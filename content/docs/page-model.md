---
title: "Page model"
---

What a content page is made of, so shifts can be written, filmed, and
scheduled independently. Everything lives in front matter; the layouts in
`layouts/partials/page/` render it; an empty field renders as a TODO
marker rather than disappearing, so a half-written shift is visibly
half-written.

## Kinds of page

| Kind | Where | Layout | Has |
|---|---|---|---|
| home | `content/_index.md` | `index.html` | memo, optional video, the two week cards |
| weeks index | `content/weeks/_index.md` | `list.html` | intro, week cards |
| week | `content/weeks/<week>/_index.md` | `list.html` | the two-minute talk (text or video), optional activity, the shift list |
| shift | `content/weeks/<week>/NN-slug.md` | `single.html` (shift) | card, optional video, optional activity, body, pager |
| page | `content/propose-loop.md`, `content/docs/**` | `single.html` (page) | optional video, optional activity, body |

A shift may have a video, an activity, or both. A shift with neither is a
read, and should be rare.

## Shift front matter

```yaml
title: "The wristband"          # themed title
id: "F3"                        # stable id used by the back office
shift: 3                        # number within the week
weight: 3                       # ordering (= shift)
subtitle: "the egress allowlist" # the plain name, shown under the title
summary: "…"                    # meta description
# the card (empty => TODO on the page)
today: ""                       # one paragraph, imperative, what you'll do
done_when: ""                   # the check
clock_in: "shift 1"             # where to restart
rule: "Bounded blast radius (handbook VI)."
properties: ["VI"]              # handbook roman numerals
closes: ["P4"]                  # prescriptions closed (week two)
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
  live: true                    # runs with the shift lead
```

Omit `video:` or `activity:` entirely when a shift has none; the block is
not rendered. `provider: todo` renders a placeholder frame.

## Shift body

Headings in this order; a section may be dropped if it does not apply.

```
## Context            short bullets: what's underneath, sources, constraints — not final copy
## Watch              the video's script or talking points (if there is a video)
## Do                 the activity: numbered steps, imperative, one job
## Self-paced         what the practice pool can and cannot show
## With the shift lead what the crew sees; timing; the line to say
## Back office        links into content/docs for depth
```

## Markers

`{{</* todo "note" */>}}` renders a visible TODO chip. Use it for anything
unwritten; the build does not fail on it, so a TODO that ships is a
choice, not an accident. `just todos` lists them.

## Scaffolding

`just new two 16 I16 "Title"` writes a shift file with this front matter
and these headings.
