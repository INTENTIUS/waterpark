# compose, the one-shot

Fountain, Postgres, Floci, and a containerized Fountain runner, from one
directory. For a class or a laptop. Not for the internet.

```sh
cd compose
bin/env.sh                                  # .env with the two generated keys
docker compose up -d                        # Fountain :4000, Floci :4566
bin/register.sh you@example.com 'password'  # account, API key, CLI login, runner key
docker compose --profile runner up -d       # sandboxes
```

From the repo root `just up`, `just register EMAIL PASSWORD`, `just runner`, `just down`.

What you get and what you do not.

- Fountain at `http://localhost:4000` with accounts that self-verify and
  a first account that is admin. Change `PORT` in `.env` if 4000 is taken.
- Floci at `http://localhost:4566`. The lessons' AWS variables are
  `AWS_ENDPOINT_URL=http://localhost:4566`, `AWS_DEFAULT_REGION=us-east-1`,
  `AWS_ACCESS_KEY_ID=test`, `AWS_SECRET_ACCESS_KEY=test`. The `floci` CLI is
  not needed, `floci env` works too if you have it.
- A runner, so conversations work with no sprites.dev account. The runner
  is a container with node, bun, git, the AWS CLI and jq, and its
  sandboxes are directories in it. It is trusted mode (Fountain's runners
  doc), which means one thing for the lessons. `networking_type: limited`
  does not provision on a runner, so Fountain lesson 3, the egress
  allowlist, needs a hosted sandbox provider. Set `SANDBOX_PROVIDER=sprites`
  and `SPRITES_TOKEN` in `.env` for that, and restart with `docker compose up -d`.
- Nothing else. No mail, no billing, no TLS.

`bin/register.sh` talks to the API. `POST /api/auth/register`, then
`POST /api/auth/token` for a key, then it writes `~/.fountain/credentials`
the way `fountain auth login` does and puts the key in `.env` for the
runner. The inference key is the one thing it does not do. Open the
instance once in a browser and finish onboarding, or the facilitator
hands out keys and the student enters them.

The runner image is `ghcr.io/intentius/waterpark-runner`, built from
`runner/Dockerfile` with a fountain CLI compiled from source (the runner
command is newer than the last released binary). The package must be
public on ghcr for students to pull it. `just runner-build` builds it
locally instead, which needs `runner/bin/fountain-linux-<arch>` from a
Fountain checkout, `cd cli && GOOS=linux go build -o ... ./cmd/fountain`.

Windows. Docker Desktop with the WSL 2 backend runs all of it. The two
scripts are bash, run them in WSL or Git Bash, or do the four calls by
hand in PowerShell (`Invoke-RestMethod`).
