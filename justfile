# water park — local site tasks. `just` lists them.

set shell := ["bash", "-euo", "pipefail", "-c"]

port := "1313"

default:
    @just --list

# Serve the site locally with live reload: http://localhost:1313
serve:
    hugo server --port {{port}} --buildDrafts --disableFastRender --navigateToChanged

# Serve on all interfaces, for a phone or another machine on the LAN
serve-lan:
    hugo server --port {{port}} --bind 0.0.0.0 --baseURL "http://$(ipconfig getifaddr en0 2>/dev/null || hostname -I | awk '{print $1}'):{{port}}/" --buildDrafts --disableFastRender

# Build to ./public as CI does (gc, minify); any Hugo warning fails the build
build:
    hugo --gc --minify --panicOnWarning

# Build, then verify every internal link in the rendered site resolves
check: build
    python3 scripts/check_site_links.py

# Verify every relative link in the markdown sources points at a real file
check-md:
    python3 scripts/check_md_links.py

# The prose rule over the lesson pages. No em dashes, colons or semicolons
check-prose *paths:
    python3 scripts/check_prose.py {{paths}}

# Hold the desk's prompt, its page and its generated manifest to each other
desk-check:
    desk/bin/check-protocol

# Create the desk's Environment, Vault and Agent on the local stack
desk-apply:
    desk/bin/render-manifest
    fountain apply -f desk/fountain.yaml

# Put the desk on the team. Opens its one thread and binds its vault to it
desk-hire:
    @set -euo pipefail; \
    key=$(grep -E '^FOUNTAIN_API_KEY=' compose/.env | cut -d= -f2-); \
    port=$(grep -E '^PORT=' compose/.env | cut -d= -f2); port=${port:-4000}; \
    [ -n "$key" ] || { echo "no FOUNTAIN_API_KEY in compose/.env. just register first"; exit 1; }; \
    base="http://localhost:$port"; \
    agent=$(curl -fsS -H "Authorization: Bearer $key" "$base/api/agents" | jq -r '.data[]|select(.name=="aws-desk")|.id'); \
    vault=$(curl -fsS -H "Authorization: Bearer $key" "$base/api/vaults" | jq -r '.data[]|select(.name=="aws-desk-floci")|.id'); \
    [ -n "$agent" ] || { echo "no aws-desk agent. just desk-apply first"; exit 1; }; \
    curl -fsS -X POST -H "Authorization: Bearer $key" -H 'Content-Type: application/json' \
      -d "{\"agent_id\":\"$agent\",\"vault_id\":\"$vault\",\"name\":\"AWS desk\"}" \
      "$base/api/team" | jq -r '"on the team\n  agent        \(.data.agent_id)\n  conversation \(.data.conversation.id)"'

# Everything CI would care about
ci: check check-md check-prose desk-check

# Print the lesson list: course, number, id, title
lessons:
    @for c in fountain iam; do \
      echo "== $c"; \
      for f in content/courses/$c/*.md; do \
        case "$f" in */_index.md) continue;; esac; \
        n=$(sed -n 's/^lesson: \(.*\)/\1/p' "$f"); \
        i=$(sed -n 's/^id: "\(.*\)"/\1/p' "$f"); \
        t=$(sed -n 's/^title: "\(.*\)"/\1/p' "$f"); \
        printf '%s\t%s\t%s\n' "$n" "$i" "$t"; \
      done | sort -n; \
    done

# New lesson page from the template: just new iam 16 I16 "Title of the lesson"
new course lesson id title:
    scripts/new_lesson.sh {{course}} {{lesson}} {{id}} "{{title}}"

# List every TODO marker and empty card field across the content
todos:
    @grep -rn --include='*.md' -e '{{{{< todo' -e '^goal: ""' -e '^done_when: ""' -e 'provider: todo' content | sed 's|^content/||' || true
    @echo; echo "$(grep -rho --include='*.md' '{{{{< todo' content | wc -l | tr -d ' ') todo markers"

# List skills and check each SKILL.md has name and description frontmatter
skills:
    @for d in skills/*/; do \
      f="$d/SKILL.md"; \
      if [ ! -f "$f" ]; then echo "MISSING $f"; continue; fi; \
      n=$(sed -n 's/^name: //p' "$f" | head -1); \
      grep -q '^description: ' "$f" && ok=ok || ok="NO DESCRIPTION"; \
      printf '%s\t%s\t%s\n' "$d" "$n" "$ok"; \
    done

# Build the site image locally
docker-build:
    docker build -t waterpark:local .

# Run the site from the image at http://localhost:8080
docker-run:
    docker run --rm -p 8080:80 waterpark:local

# Log the fountain CLI in to a local instance once. The URL is saved in ~/.fountain/credentials
fountain-login url="http://localhost:4000":
    FOUNTAIN_BASE_URL={{url}} fountain auth login

# What do I have, and the install line for whatever is missing
doctor:
    @bash skills/start/check.sh doctor

# One-shot local stack. Fountain, Postgres, Floci. Ends by proving both answer
up:
    compose/bin/env.sh
    @port=$(grep -E '^PORT=' compose/.env | cut -d= -f2); port=${port:-4000}; \
    code=$(curl -s -o /dev/null -m 3 -w '%{http_code}' "http://localhost:$port/" 2>/dev/null) || code=000; \
    if [ "$code" != "000" ]; then \
      running=$(docker compose -f compose/docker-compose.yml --env-file compose/.env ps -q fountain 2>/dev/null); \
      [ -n "$running" ] || { echo "port $port is in use, set PORT in compose/.env"; exit 1; }; \
    fi
    docker compose -f compose/docker-compose.yml --env-file compose/.env up -d
    @port=$(grep -E '^PORT=' compose/.env | cut -d= -f2); port=${port:-4000}; \
    fport=$(grep -E '^FLOCI_PORT=' compose/.env | cut -d= -f2); fport=${fport:-4566}; \
    printf 'waiting for Fountain on :%s ' "$port"; \
    up=""; \
    for i in $(seq 1 150); do curl -fs "http://localhost:$port/health" >/dev/null 2>&1 && { up=1; break; }; printf .; sleep 2; done; echo; \
    if [ -z "$up" ]; then \
      echo "  Fountain did not come up within 5 minutes."; \
      docker inspect --format '  state: {{{{.State.Status}}  restarts: {{{{.RestartCount}}' compose-fountain-1 2>/dev/null; \
      echo "  last 15 lines of compose-fountain-1:"; \
      docker logs --tail 15 compose-fountain-1 2>&1 | sed 's/^/    /'; \
      exit 1; \
    fi; \
    printf '  \342\234\223 Fountain /health answered on :%s\n' "$port"; \
    curl -fs -o /dev/null "http://localhost:$fport/" && printf '  \342\234\223 Floci answered on :%s\n' "$fport" || { echo "  Floci did not come up. just logs"; exit 1; }; \
    echo "next: just register you@example.com   then: just runner"

# Everything in the stack, then the doctor's view
status:
    docker compose -f compose/docker-compose.yml --env-file compose/.env --profile runner ps
    @just doctor

# Register a class account, log the CLI in, give the runner its key.
# just register you@example.com          prompts for the password, keeping it out of history
register email password="" profile="default":
    compose/bin/register.sh {{email}} "{{password}}" {{profile}}

# Start the containerized runner (after just register). Pulls the published image
runner:
    docker compose -f compose/docker-compose.yml --env-file compose/.env --profile runner up -d --pull missing --no-build

# Build the runner image locally (needs compose/runner/bin/fountain-linux-<arch>, see the Dockerfile)
runner-build:
    docker compose -f compose/docker-compose.yml --env-file compose/.env --profile runner up -d --build

# Stop the local stack (keeps data). just down-all removes volumes too
down:
    docker compose -f compose/docker-compose.yml --env-file compose/.env --profile runner down

down-all:
    docker compose -f compose/docker-compose.yml --env-file compose/.env --profile runner down -v

# Run a shell command in the runner container, where each sandbox is a directory under /sandboxes
runner-sh +cmd:
    @docker compose -f compose/docker-compose.yml --env-file compose/.env --profile runner exec runner sh -c '{{cmd}}'

# Tail the local stack's logs
logs:
    docker compose -f compose/docker-compose.yml --env-file compose/.env --profile runner logs -f --tail=50

# The access repo's checks: fmt, validate, tflint and the rule fixtures
access-check *args:
    access/scripts/check {{args}}

# Install the tflint plugins the access checks need. Once per clone
access-init:
    cd access && tflint --init

# Remove build output
clean:
    rm -rf public resources .hugo_build.lock
