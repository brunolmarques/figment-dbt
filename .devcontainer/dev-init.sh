#!/usr/bin/env bash
set -euo pipefail

#---------------------------------------------------------------------------
# 1. Clean & recreate virtualenv
#---------------------------------------------------------------------------
echo "🧹  Removing any stale virtualenv…"
pipenv --rm 2>/dev/null || true
rm -rf .venv

export PIPENV_VENV_IN_PROJECT=1
export PIPENV_IGNORE_VIRTUALENVS=1

echo "🐍  Creating a fresh in-project virtualenv…"
pipenv --python "$(command -v python3)"

#---------------------------------------------------------------------------
# 2.  Install Python & dbt deps
#---------------------------------------------------------------------------
echo "📦  Installing project dependencies…"
pipenv install --dev

if [[ -f dbt_project.yml ]]; then
  echo "📦  Pulling dbt packages (dbt deps)…"
  pipenv run dbt deps
fi

#---------------------------------------------------------------------------
# 3.  Wait for Postgres to be ready
#---------------------------------------------------------------------------
echo "⏳  Waiting for Postgres to accept connections…"
until pg_isready -h db -p 5432 -U figment >/dev/null 2>&1; do
  sleep 2
done
echo "✅  Postgres is up"

#---------------------------------------------------------------------------
# 4.  Done
#---------------------------------------------------------------------------
echo "🎉  Dev-container init complete"
