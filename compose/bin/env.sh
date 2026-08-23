#!/usr/bin/env bash
# Create compose/.env from .env.example with the two generated keys filled in. Idempotent.
set -euo pipefail
cd "$(dirname "$0")/.."
[ -f .env ] || cp .env.example .env
gen() { grep -q "^$1=.\+" .env || { v=$2; sed -i.bak "s|^$1=.*|$1=$v|" .env && rm -f .env.bak; }; }
gen SECRET_KEY_BASE "$(openssl rand -base64 48 | tr -d '\n')"
gen MASTER_SECRETS_KEY "$(openssl rand 32 | base64 | tr '+/' '-_' | tr -d '=\n')"
echo ".env ready"
