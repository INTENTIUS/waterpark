#!/usr/bin/env bash
# Report what a student has for water park's Start here. Never changes anything.
# Prints JSON when jq is present, otherwise key=value lines. Works on bash 3.2.
set -u
have() { command -v "$1" >/dev/null 2>&1; }
first() { "$@" 2>/dev/null | head -1; }
FOUNTAIN_URL="${FOUNTAIN_URL:-http://localhost:4000}"
FLOCI_URL="${AWS_ENDPOINT_URL:-http://localhost:4566}"
TOOLS="docker fountain floci aws jq gh"

version_of() {
  case "$1" in
    docker) first docker --version;; fountain) first fountain version;; floci) first floci --version;;
    aws) first aws --version;; jq) first jq --version;; gh) first gh --version;;
  esac
}
reach() { local c; c=$(curl -s -o /dev/null -m 5 -w '%{http_code}' "$1" 2>/dev/null || echo 000); [ "$c" != "000" ] && echo true || echo false; }

fountain_reachable=$(reach "$FOUNTAIN_URL/api/health")
floci_reachable=$(reach "$FLOCI_URL/_floci/health")
fountain_logged_in=false; have fountain && fountain auth status >/dev/null 2>&1 && fountain_logged_in=true
gh_logged_in=false; have gh && gh auth status >/dev/null 2>&1 && gh_logged_in=true

if have jq; then
  tools='{}'
  for t in $TOOLS; do
    if have "$t"; then tools=$(jq -c --arg t "$t" --arg v "$(version_of "$t")" '. + {($t):{installed:true,version:$v}}' <<<"$tools")
    else tools=$(jq -c --arg t "$t" '. + {($t):{installed:false}}' <<<"$tools"); fi
  done
  jq -n --argjson tools "$tools" \
    --arg fountain_url "$FOUNTAIN_URL" --argjson fountain_reachable "$fountain_reachable" --argjson fountain_logged_in "$fountain_logged_in" \
    --arg floci_url "$FLOCI_URL" --argjson floci_reachable "$floci_reachable" --argjson gh_logged_in "$gh_logged_in" \
    '{tools:$tools, fountain:{url:$fountain_url,reachable:$fountain_reachable,logged_in:$fountain_logged_in}, floci:{url:$floci_url,reachable:$floci_reachable}, github:{logged_in:$gh_logged_in}}'
else
  for t in $TOOLS; do if have "$t"; then echo "$t=true $(version_of "$t")"; else echo "$t=false"; fi; done
  echo "fountain_url=$FOUNTAIN_URL reachable=$fountain_reachable logged_in=$fountain_logged_in"
  echo "floci_url=$FLOCI_URL reachable=$floci_reachable"
  echo "gh_logged_in=$gh_logged_in"
fi
