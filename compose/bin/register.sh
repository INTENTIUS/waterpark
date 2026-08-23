#!/usr/bin/env bash
# Register an account on the compose Fountain, mint an API key, log the CLI in, and give the runner the key.
# Usage: bin/register.sh you@example.com 'password' [profile] [base-url]
# Only for a class or laptop instance. Accounts self-verify there (EMAIL_DELIVERY=none).
set -euo pipefail
cd "$(dirname "$0")/.."
email=${1:?email}; password=${2:?password}; profile=${3:-default}
port=$(grep -E '^PORT=' .env 2>/dev/null | cut -d= -f2); port=${port:-4000}
base="${4:-http://localhost:$port}"

echo "waiting for $base/health"
for i in $(seq 1 60); do curl -fs "$base/health" >/dev/null 2>&1 && break; sleep 2; done
curl -fs "$base/health" >/dev/null || { echo "Fountain is not answering at $base" >&2; exit 1; }

code=$(curl -s -o /tmp/wp-register.json -w '%{http_code}' -X POST "$base/api/auth/register" \
  -H 'Content-Type: application/json' -d "{\"email\":\"$email\",\"password\":\"$password\"}")
case "$code" in
  2*) echo "registered $email";;
  409|422) echo "register answered $code, assuming the account exists and continuing";;
  *) echo "register failed ($code): $(cat /tmp/wp-register.json)" >&2; exit 1;;
esac

key=$(curl -fs -X POST "$base/api/auth/token" -H 'Content-Type: application/json' \
  -d "{\"email\":\"$email\",\"password\":\"$password\"}" | sed -n 's/.*"api_key":"\([^"]*\)".*/\1/p')
[ -n "$key" ] || { echo "could not mint an API key (wrong password, or the account is not verified)" >&2; exit 1; }

# the CLI's credentials file, same shape fountain auth login writes
mkdir -p "$HOME/.fountain"; f="$HOME/.fountain/credentials"; touch "$f"
python3 - "$f" "$profile" "$key" "$base" <<'PY' 2>/dev/null || {
import sys,re
f,profile,key,base=sys.argv[1:]
s=open(f).read()
block=f'[{profile}]\napi_key = "{key}"\nbase_url = "{base}"\n'
pat=re.compile(r'\['+re.escape(profile)+r'\]\n(?:(?!\[).*\n?)*')
s=pat.sub(block,s) if pat.search(s) else (s.rstrip('\n')+('\n\n' if s.strip() else '')+block)
open(f,'w').write(s)
PY
  printf '\n[%s]\napi_key = "%s"\nbase_url = "%s"\n' "$profile" "$key" "$base" >> "$f"; }
chmod 600 "$f"
echo "CLI logged in (profile $profile, $base)"

# the runner service reads this. only for the local stack
case "$base" in
  http://localhost:*)
    sed -i.bak "s|^FOUNTAIN_API_KEY=.*|FOUNTAIN_API_KEY=$key|" .env && rm -f .env.bak
    echo "FOUNTAIN_API_KEY written to .env. start the runner with: docker compose --profile runner up -d";;
  *) echo "remote instance, nothing written to .env";;
esac
