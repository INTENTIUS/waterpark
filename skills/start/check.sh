#!/usr/bin/env bash
# Report what a student has for water park's Start here. Never changes anything.
# Prints JSON when jq is present, otherwise key=value lines. Works on bash 3.2.
# `check.sh doctor` prints a human report instead, with the install or fix line
# for whatever is missing (the just-doctor idea from fountain-ops).
set -u
have() { command -v "$1" >/dev/null 2>&1; }
first() { "$@" 2>/dev/null | head -1; }
# with the compose stack on a non-default port, follow compose/.env unless FOUNTAIN_URL says otherwise
wp_top=$(git -C "$(dirname "$0")" rev-parse --show-toplevel 2>/dev/null || true)
compose_port=$(grep -E '^PORT=' "$wp_top/compose/.env" 2>/dev/null | cut -d= -f2)
FOUNTAIN_URL="${FOUNTAIN_URL:-http://localhost:${compose_port:-4000}}"
compose_floci_port=$(grep -E '^FLOCI_PORT=' "$wp_top/compose/.env" 2>/dev/null | cut -d= -f2)
# floci env sets AWS_ENDPOINT_URL to http://localhost.floci.io:4566, which resolves to 127.0.0.1. either works
FLOCI_URL="${AWS_ENDPOINT_URL:-http://localhost:${compose_floci_port:-4566}}"
TOOLS="docker fountain floci aws jq gh just"

version_of() {
  case "$1" in
    docker) first docker --version;; fountain) first fountain --version;; floci) first floci --version;;
    aws) first aws --version;; jq) first jq --version;; gh) first gh --version;; just) first just --version;;
  esac
}
# any HTTP status means something answered. a refused connection gives 000 and a non-zero exit
reach() { local c; c=$(curl -s -o /dev/null -m 5 -w '%{http_code}' "$1" 2>/dev/null) || c=000; [ "$c" != "000" ] && echo true || echo false; }

wp_root=$(git -C "$(dirname "$0")" rev-parse --show-toplevel 2>/dev/null || true)
wp_checkout=false; wp_commit=""
if [ -n "$wp_root" ] && [ -f "$wp_root/skills/start/SKILL.md" ] && [ -f "$wp_root/hugo.toml" ]; then
  wp_checkout=true; wp_commit=$(git -C "$wp_root" rev-parse --short HEAD 2>/dev/null || true)
fi
fountain_reachable=$(reach "$FOUNTAIN_URL/health")
floci_reachable=$(reach "$FLOCI_URL/")
fountain_logged_in=false
# the URL the CLI will actually use, env first, then the profile in ~/.fountain/credentials
profile="${FOUNTAIN_PROFILE:-default}"
cred_url=$(awk -v p="[$profile]" '$0==p{f=1;next} /^\[/{f=0} f && $1=="base_url"{gsub(/"/,"",$3); print $3}' "$HOME/.fountain/credentials" 2>/dev/null | head -1)
cred_key=$(awk -v p="[$profile]" '$0==p{f=1;next} /^\[/{f=0} f && $1=="api_key"{gsub(/"/,"",$3); print $3}' "$HOME/.fountain/credentials" 2>/dev/null | head -1)
cli_url="${FOUNTAIN_BASE_URL:-${cred_url:-}}"
# logged_in means the token works right now: an authenticated call answers.
# a credentials file from a wiped instance stays on disk with a dead token, so the file proves nothing
inference_set=false; onboarded=false; runner_online=false; me_email=""
if [ -n "${cred_key:-}" ] && [ -n "$cli_url" ]; then
  me=$(curl -fs -m 5 -H "Authorization: Bearer $cred_key" "$cli_url/api/auth/me" 2>/dev/null || true)
  if [ -n "$me" ]; then
    fountain_logged_in=true
    me_email=$(echo "$me" | sed -n 's/.*"email":"\([^"]*\)".*/\1/p')
    echo "$me" | grep -q '"onboarding_completed":true' && onboarded=true
    creds=$(curl -fs -m 5 -H "Authorization: Bearer $cred_key" "$cli_url/api/account/inference-credentials" 2>/dev/null || true)
    echo "$creds" | grep -q true && inference_set=true
    runners=$(curl -fs -m 5 -H "Authorization: Bearer $cred_key" "$cli_url/api/runners" 2>/dev/null || true)
    echo "$runners" | grep -q '"online":true' && runner_online=true
  fi
fi
gh_logged_in=false; have gh && gh auth status >/dev/null 2>&1 && gh_logged_in=true
os_name=$(uname -s 2>/dev/null || echo unknown)
pkg=""; for m in brew apt-get dnf pacman zypper winget scoop choco; do have "$m" && pkg="$pkg $m"; done; pkg=${pkg# }

if [ "${1:-}" = "doctor" ]; then
  : # human report printed below
elif have jq; then
  tools='{}'
  for t in $TOOLS; do
    if have "$t"; then tools=$(jq -c --arg t "$t" --arg v "$(version_of "$t")" '. + {($t):{installed:true,version:$v}}' <<<"$tools")
    else tools=$(jq -c --arg t "$t" '. + {($t):{installed:false}}' <<<"$tools"); fi
  done
  jq -n --argjson tools "$tools" --argjson wp_checkout "$wp_checkout" --arg wp_root "$wp_root" --arg wp_commit "$wp_commit" \
    --arg fountain_url "$FOUNTAIN_URL" --argjson fountain_reachable "$fountain_reachable" --argjson fountain_logged_in "$fountain_logged_in" --arg cli_url "$cli_url" --arg profile "$profile" --argjson inference_set "$inference_set" --argjson onboarded "$onboarded" --argjson runner_online "$runner_online" --arg me_email "$me_email" \
    --arg floci_url "$FLOCI_URL" --argjson floci_reachable "$floci_reachable" --argjson gh_logged_in "$gh_logged_in" --arg os "$os_name" --arg pkg "$pkg" \
    '{waterpark:{checkout:$wp_checkout,root:$wp_root,commit:$wp_commit}, os:$os, package_managers:($pkg|split(" ")|map(select(.!=""))), tools:$tools, fountain:{url:$fountain_url,reachable:$fountain_reachable,logged_in:$fountain_logged_in,cli_url:$cli_url,profile:$profile,inference_set:$inference_set,onboarded:$onboarded,runner_online:$runner_online,email:$me_email}, floci:{url:$floci_url,reachable:$floci_reachable}, github:{logged_in:$gh_logged_in}}'
elif [ "${1:-}" != "doctor" ]; then
  echo "waterpark_checkout=$wp_checkout root=$wp_root commit=$wp_commit"
  echo "os=$os_name package_managers=$pkg"
  for t in $TOOLS; do if have "$t"; then echo "$t=true $(version_of "$t")"; else echo "$t=false"; fi; done
  echo "fountain_url=$FOUNTAIN_URL reachable=$fountain_reachable logged_in=$fountain_logged_in cli_url=$cli_url profile=$profile inference_set=$inference_set onboarded=$onboarded runner_online=$runner_online email=$me_email"
  echo "floci_url=$FLOCI_URL reachable=$floci_reachable"
  echo "gh_logged_in=$gh_logged_in"
fi

if [ "${1:-}" = "doctor" ]; then
  ok() { printf '  \xe2\x9c\x93 %s\n' "$1"; }
  bad() { printf '  \xe2\x9c\x97 %s\n      fix: %s\n' "$1" "$2"; }
  case "$pkg" in
    *brew*) DOCKER='brew install --cask docker   (then open Docker.app once)'; TOOLS='brew install awscli jq gh'; JUST='brew install just';;
    *winget*|*scoop*) DOCKER='winget install Docker.DockerDesktop   (WSL 2 backend)'; TOOLS='winget install Amazon.AWSCLI jqlang.jq GitHub.cli'; JUST='winget install Casey.Just   (or scoop install just)';;
    *apt-get*) DOCKER="your distribution's docker packages, then usermod -aG docker \$USER"; TOOLS='sudo apt-get install awscli jq gh'; JUST='the release binary from https://github.com/casey/just';;
    *) DOCKER='https://www.docker.com/products/docker-desktop/'; TOOLS='awscli, jq and gh from their own sites'; JUST='https://github.com/casey/just#installation';;
  esac
  echo "water park doctor ($os_name, package managers: ${pkg:-none})"
  [ "$wp_checkout" = true ] && ok "water park checkout ($wp_root @ $wp_commit)" || bad "water park checkout" "git clone https://github.com/INTENTIUS/waterpark && cd waterpark"
  have just && ok "just ($(first just --version))" || bad "just" "$JUST"
  have docker && ok "docker ($(first docker --version))" || bad "docker" "$DOCKER"
  [ "$fountain_reachable" = true ] && ok "Fountain answering at $FOUNTAIN_URL" || bad "Fountain at $FOUNTAIN_URL" "just up   (or set FOUNTAIN_URL to the class instance)"
  [ "$fountain_logged_in" = true ] && ok "logged in as $me_email (profile $profile)" || bad "logged in" "just register you@example.com   (prompts for a password)"
  [ "$inference_set" = true ] && ok "inference key set" || bad "inference key" "sign in at ${cli_url:-$FOUNTAIN_URL} and finish onboarding, or the step-7 curl from the start skill"
  [ "$runner_online" = true ] && ok "a runner is online" || bad "runner" "just runner   (only needed when the stack's runner is the provider)"
  [ "$floci_reachable" = true ] && ok "Floci answering at $FLOCI_URL" || bad "Floci at $FLOCI_URL" "just up   (self-paced only; live students skip this)"
  for t in aws jq gh; do have "$t" && ok "$t" || bad "$t" "$TOOLS"; done
  exit 0
fi
