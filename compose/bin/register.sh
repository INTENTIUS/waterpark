#!/usr/bin/env bash
# Register an account on the compose Fountain, mint an API key, log the CLI in, and give the runner the key.
# Usage: bin/register.sh you@example.com ['password'] [profile] [base-url]
# With no password argument it prompts silently (or reads WP_PASSWORD), keeping it out of history and ps.
# Only for a class or laptop instance. Accounts self-verify there (EMAIL_DELIVERY=none).
set -euo pipefail
cd "$(dirname "$0")/.."
email=${1:?email}; password=${2:-${WP_PASSWORD:-}}; profile=${3:-default}
if [ -z "$password" ]; then
  # keep it out of shell history and ps. just register you@example.com prompts here
  printf 'password (at least 8 characters, not echoed): ' >&2; read -rs password; echo >&2
  [ -n "$password" ] || { echo "empty password" >&2; exit 1; }
fi
port=$(grep -E '^PORT=' .env 2>/dev/null | cut -d= -f2); port=${port:-4000}
base="${4:-http://localhost:$port}"

echo "waiting for $base/health"
for i in $(seq 1 60); do curl -fs "$base/health" >/dev/null 2>&1 && break; sleep 2; done
curl -fs "$base/health" >/dev/null || { echo "Fountain is not answering at $base" >&2; exit 1; }

code=$(curl -s -o /tmp/wp-register.json -w '%{http_code}' -X POST "$base/api/auth/register" \
  -H 'Content-Type: application/json' -d "{\"email\":\"$email\",\"password\":\"$password\"}")
# Fountain answers 422 both for an address already taken and for a password
# it refuses, so the body decides which. Only the first is safe to carry on
# from. A refused password is printed as Fountain phrased it, because "assuming
# the account exists" followed by a failed login says nothing a student can act
# on.
case "$code" in
  2*) echo "registered $email";;
  409) echo "register answered 409, the account exists, continuing";;
  422)
    if grep -q "already been taken" /tmp/wp-register.json; then
      echo "register answered 422, the account exists, continuing"
    else
      echo "register refused: $(cat /tmp/wp-register.json)" >&2
      echo "Fountain wants a password of at least 8 characters." >&2
      exit 1
    fi;;
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
