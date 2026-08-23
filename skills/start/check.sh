#!/usr/bin/env bash
# Report what a student has for water park's Start here. Never changes anything.
# Prints JSON when jq is present, otherwise key=value lines. Works on bash 3.2.
set -u
have() { command -v "$1" >/dev/null 2>&1; }
first() { "$@" 2>/dev/null | head -1; }
FOUNTAIN_URL="${FOUNTAIN_URL:-http://localhost:4000}"
# floci env sets AWS_ENDPOINT_URL to http://localhost.floci.io:4566, which resolves to 127.0.0.1. either works
FLOCI_URL="${AWS_ENDPOINT_URL:-http://localhost:4566}"
TOOLS="docker fountain floci aws jq gh"

version_of() {
  case "$1" in
    docker) first docker --version;; fountain) first fountain --version;; floci) first floci --version;;
    aws) first aws --version;; jq) first jq --version;; gh) first gh --version;;
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
fountain_logged_in=false; have fountain && fountain auth status >/dev/null 2>&1 && fountain_logged_in=true
# the URL the CLI will actually use, env first, then the profile in ~/.fountain/credentials
profile="${FOUNTAIN_PROFILE:-default}"
cred_url=$(awk -v p="[$profile]" '$0==p{f=1;next} /^\[/{f=0} f && $1=="base_url"{gsub(/"/,"",$3); print $3}' "$HOME/.fountain/credentials" 2>/dev/null | head -1)
cli_url="${FOUNTAIN_BASE_URL:-${cred_url:-}}"
gh_logged_in=false; have gh && gh auth status >/dev/null 2>&1 && gh_logged_in=true
os_name=$(uname -s 2>/dev/null || echo unknown)
pkg=""; for m in brew apt-get dnf pacman zypper winget scoop choco; do have "$m" && pkg="$pkg $m"; done; pkg=${pkg# }

if have jq; then
  tools='{}'
  for t in $TOOLS; do
    if have "$t"; then tools=$(jq -c --arg t "$t" --arg v "$(version_of "$t")" '. + {($t):{installed:true,version:$v}}' <<<"$tools")
    else tools=$(jq -c --arg t "$t" '. + {($t):{installed:false}}' <<<"$tools"); fi
  done
  jq -n --argjson tools "$tools" --argjson wp_checkout "$wp_checkout" --arg wp_root "$wp_root" --arg wp_commit "$wp_commit" \
    --arg fountain_url "$FOUNTAIN_URL" --argjson fountain_reachable "$fountain_reachable" --argjson fountain_logged_in "$fountain_logged_in" --arg cli_url "$cli_url" --arg profile "$profile" \
    --arg floci_url "$FLOCI_URL" --argjson floci_reachable "$floci_reachable" --argjson gh_logged_in "$gh_logged_in" --arg os "$os_name" --arg pkg "$pkg" \
    '{waterpark:{checkout:$wp_checkout,root:$wp_root,commit:$wp_commit}, os:$os, package_managers:($pkg|split(" ")|map(select(.!=""))), tools:$tools, fountain:{url:$fountain_url,reachable:$fountain_reachable,logged_in:$fountain_logged_in,cli_url:$cli_url,profile:$profile}, floci:{url:$floci_url,reachable:$floci_reachable}, github:{logged_in:$gh_logged_in}}'
else
  echo "waterpark_checkout=$wp_checkout root=$wp_root commit=$wp_commit"
  echo "os=$os_name package_managers=$pkg"
  for t in $TOOLS; do if have "$t"; then echo "$t=true $(version_of "$t")"; else echo "$t=false"; fi; done
  echo "fountain_url=$FOUNTAIN_URL reachable=$fountain_reachable logged_in=$fountain_logged_in cli_url=$cli_url profile=$profile"
  echo "floci_url=$FLOCI_URL reachable=$floci_reachable"
  echo "gh_logged_in=$gh_logged_in"
fi
