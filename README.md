# water park

An educational courses repo that is also the worked example. The courses
teach how to run an agent against real infrastructure safely, on the
[Accessible Ops](https://accessibleops.net) properties. Course 1 is
[Fountain](https://github.com/BinaryBourbon/fountain), the agent runtime.
Course 2 builds water park's own AWS access as a repo anyone can PR (one
resource per file, PR-only writes, guardrails in the editor, drift
watched, delegation bounded by IAM itself), with an agent working it as
concierge and watcher. water park is a pattern, not a tool, so any agent
runtime and any declarative applier can drive it. This course pairs
Fountain with Terraform (decision 31). Live at
[intentius.io/waterpark](https://intentius.io/waterpark/).

- [content/courses/fountain/](content/courses/fountain/) — course 1, the agent side (F1–F11)
- [content/courses/iam/](content/courses/iam/) — course 2, the access repo as Terraform (I1–I15)
- [content/docs/](content/docs/) — the student-facing design docs (ledger, rules, prescriptions, threat model, design notes)
- [content/docs/aws-desk.md](content/docs/aws-desk.md) — the Fountain AWS desk, the agent app the courses build (dns-desk's form on a Terraform estate)
- [content/propose-loop.md](content/propose-loop.md) — how the agent side works: the loop abstracted from Mend, Rounds and dns-desk
- [content/docs/estate.md](content/docs/estate.md) — the estate the IAM course manages, which is water park's own
- [project/page-model.md](project/page-model.md) — what a lesson page is made of: card, video, activity, body
- [content/start.md](content/start.md) — setup, self-paced vs live, order
- [compose/](compose/README.md) — the one-shot class stack: Fountain, Postgres, Floci and a containerized sandbox runner (`just up`, `just register`, `just runner`)
- [skills/](skills/README.md) — one skill per section or lesson, an agent that walks a student through it (`skills/start` first)
- Run the site offline: `docker run --rm -p 8080:80 ghcr.io/intentius/waterpark` (built by CI from the `Dockerfile`)
- `just serve` · `just ci` · `just lessons` · `just todos` · `just new iam 16 I16 "Title"`

Naming: *water park* is this repo. It is the courses and it is the access
repo the courses build, and there is no third name to keep track of.
Fountain is the agent runtime and Terraform is the applier; both are
course choices rather than properties of the pattern (decisions 23, 31).
Some docs under `content/docs/` were written when water park was an
access-repo kit rather than a course and still read that way.
