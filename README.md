# water park

An IAM project repo that comes with courses. The project is `splashdown/access`:
a fictional water-park operator's AWS access, managed as a repo anyone can
PR (one resource type per file, PR-only writes, guardrails in the editor,
drift watched, delegation bounded by IAM itself), with an agent working
on it as concierge and watcher. The courses are about the
[Accessible Ops](https://accessibleops.net) properties, demonstrated on
[Fountain](https://github.com/BinaryBourbon/fountain) (the agent side)
and plain AWS (CloudFormation JSON, Access Analyzer; no toolchain); the
IAM project is the worked example because it exercises both. Live at
[intentius.io/waterpark](https://intentius.io/waterpark/).

- [content/courses/fountain/](content/courses/fountain/) — course 1, the agent side (F1–F11)
- [content/courses/iam/](content/courses/iam/) — course 2, the IAM repo as plain CloudFormation JSON (I1–I15)
- [content/docs/aws-desk.md](content/docs/aws-desk.md) — the Fountain AWS desk: the agent app the courses build (dns-desk's form on a CloudFormation estate)
- [content/propose-loop.md](content/propose-loop.md) — how the agent side works: the loop abstracted from Mend, Rounds and dns-desk
- [content/docs/page-model.md](content/docs/page-model.md) — what a lesson page is made of: card, video, activity, body
- [content/docs/](content/docs/) — the back office: plan, decisions, principles, prescriptions, live session guide, upstream pins, threat model, design notes
- [content/start.md](content/start.md) — setup, self-paced vs live, order
- [skills/](skills/README.md) — one skill per section or lesson, an agent that walks a student through it (`skills/start` first)
- Run the site offline: `docker run --rm -p 8080:80 ghcr.io/intentius/waterpark` (built by CI from the `Dockerfile`)
- `just serve` · `just ci` · `just lessons` · `just todos` · `just new iam 16 I16 "Title"`

Naming: *water park* is the project (this repo, `waterpark`); in the
kit-era docs it also names the IAM access-repo kit those docs designed,
which is course 2's backlog. splashdown is the fictional company. Fountain and plain AWS are the
vehicles; chant and Terraform are backends in the back office only
(decisions 23, 31).
