#!/usr/bin/env bash
set -euo pipefail

echo "[dev-init] Cleaning any stale virtualenv…"
# Flush any Pipenv metadata and delete the zombie .venv directory
pipenv --rm 2>/dev/null || true
rm -rf .venv

echo "[dev-init] Creating a fresh in-project virtualenv…"
# Force creation with the container's python3
export PIPENV_VENV_IN_PROJECT=1
export PIPENV_IGNORE_VIRTUALENVS=1
pipenv --python "$(command -v python3)"

echo "[dev-init] Installing project dependencies…"
pipenv install --dev

# Optional: pull dbt packages if this is a dbt repo
if [[ -f dbt_project.yml ]]; then
  echo "[dev-init] Running 'dbt deps'…"
  pipenv run dbt deps
fi

echo "[dev-init] All done ✔"
