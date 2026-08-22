# water park

Short lessons on running an agent against real infrastructure safely,
taught on [Fountain](https://github.com/BinaryBourbon/fountain), themed on
the [Accessible Ops](https://accessibleops.net) properties. Each lesson
runs alone, free, or live with a group.

The basis is one loop, abstracted from the Fountain apps Mend, Rounds
and dns-desk ([docs/propose-loop.md](content/propose-loop.md)): an operator that can only
read, a plan as a diff, a verify before propose, a propose step held by
something else, rules enforced where the write happens. The foundations
teach Fountain and that loop: four primitives, what a sandbox can reach,
named credentials, the team, schedules, talking to an agent from an app,
the loop interactive and ambient, your own machine, and what Fountain
will not do for you. The scenario applies it to a problem an ops crowd
recognizes: org IAM at a fictional company, pepperoni. An agent holding
no cloud credentials builds a working AWS access repo (one resource type
per file, PR-only writes, guardrails failing in the editor, drift caught,
delegation bounded by IAM itself) with [chant](https://intentius.io/chant),
then works as its concierge (the desk's form) and its watcher (Rounds'
form). IAM is one example of the loop; it does not need to hit every
property.

Solo mode uses Floci for AWS and costs nothing. Live mode uses real AWS,
real zones, real repos, from checkpoints, with a facilitator.

- [docs/propose-loop.md](content/propose-loop.md) — the basis: the propose loop abstracted from
  Mend, Rounds and dns-desk, and how it lands on IAM
- [docs/plan.md](content/docs/plan.md) — the curriculum: the lesson template, the
  foundation and scenario tables, modes, what is next
- [docs/lessons/](content/courses/) — one file per lesson (`F` foundations,
  `I` the IAM scenario)
- [docs/demo.md](content/docs/demo.md) — the facilitator guide: session formats,
  playlists, checkpoints, honesty lines
- [docs/principles.md](content/docs/principles.md) — the IAM scenario's ten
  invariants, mapped to the Accessible Ops properties
- [docs/prescriptions.md](content/docs/prescriptions.md) — the checkable pattern
  the IAM lessons build, each prescription with its lesson
- [docs/demo-org.md](content/docs/demo-org.md) — pepperoni
- [docs/decisions.md](content/docs/decisions.md) — the ledger of why
- [docs/upstream.md](content/docs/upstream.md) — what Fountain, the Fountain apps,
  chant and Floci ship today, pinned
- [docs/issues.md](content/docs/issues.md) — the IAM scenario's backlog, by lesson
- [docs/positioning.md](content/docs/positioning.md), [docs/landscape.md](content/docs/landscape.md),
  [docs/threat-model.md](content/docs/threat-model.md), [docs/pr-automation.md](content/docs/pr-automation.md),
  [docs/design/](content/docs/design/) — depth behind the IAM lessons

Naming: *water park* is the course (this repo, `waterpark`). In the
kit-era docs under docs/ it also names the IAM access-repo kit those docs
designed; that kit is now the IAM scenario. pepperoni is the worked
example. Fountain, chant and Floci are the tools.
