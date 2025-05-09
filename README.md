# Figment Take-Home Test

Minimal dbt + Postgres stack with Dev Container, unit-tests and CI.

---

## 🚀 Quick Start (VS Code Dev Container)

1. Press **F1 → “Dev Containers: Reopen in Container”**
   VS Code builds `.devcontainer/Dockerfile`, which already includes:

   * Python 3.11, **pipenv**, dbt 1.7 +, pytest
   * Postgres service wired to `profiles.yml`

2. When the build finishes the integrated terminal drops you into an
   activated **Pipenv** environment.
   Run your usual commands:

   ```bash
   pytest -q                       # Python unit-tests
   dbt build --full-refresh        # seeds → run → test
   ```

That’s it—no extra installs; everything is baked into the image.

---

## ⚙️ CI

* **Workflow:** `.github/workflows/ci.yml`
* **Steps:** checkout → build Dev Container → `pytest` → `dbt build --warn-error`
* Passes or blocks every push / pull-request to `main`.

---

## 🗂️ Key Files

```
.devcontainer/   # Dockerfile + devcontainer.json (dependencies baked in)
docker/          # Postgres build context + init script
docker-compose.yml
models/          # staging/ → intermediate/ → marts/
macros/          # reusable Jinja + generic tests
tests/           # pytest specs + CSV fixtures
seeds/
.github/workflows/ci.yml
```

---

## 🔧 Common Commands

```bash
dbt build                        # compile + run + test
dbt build -s staging.            # only staging layer
pytest -q                        # run unit-tests
```

Everything is idempotent and atomic—rerun at will.


## Project Structure
```
dbt_project/                
├── .devcontainer/            # Dev Containers
│   ├── devcontainer.json
│   └── Dockerfile
├── .github/
│   └── workflows/            
│       └── ci.yml            # CI (lint, dbt build, unit-tests)
├── docker/
│   ├── postgres/             # Local Postgres image build context
│   │   ├── Dockerfile
│   │   └── init-db.sh        # Init script
│   └── dbt/                  # Slim dbt-runner image
│       └── Dockerfile
├── docker-compose.yml        # Spins up Postgres + dbt
├── Pipfile                   # Python dependencies
├── profiles.yml              # Maps to Postgres service
├── dbt_project.yml           # Dbt configs
├── macros/                   # Re-usable SQL macros
├── models/                   # Data models
│   ├── staging/              # Staging cleanse
│   │   ├── ethereum/
│   │   │   ├── _staging_ethereum__sources.yml
│   │   │   ├── stg_ethereum_rewards.sql
│   │   │   └── stg_ethereum_schema.yml
│   │   └── staging_generic_tests.yml
│   ├── intermediate/         # Intermediate tables
│   │   ├── ethereum/
│   │   │   ├── int_ethereum_rewards.sql
│   │   │   └── int_ethereum__schema.yml
│   │   └── _intermediate__generic_tests.yml
│   └── marts/                # Incremental daily model
│       ├── ethereum/
│       │   ├── fct_ethereum_rewards_daily.sql
│       │   └── fct_ethereum_rewards_daily__schema.yml
│       └── _marts__generic_tests.yml
├── tests/                    # Unit tests
│   ├── data/                 # CSV fixtures for dbt seed+tests
│   └── test_rewards.py
├── seeds/                    # Reference seeds
├── snapshots/                # Slowly-changing dimensions
├── analyses/                 # Ad-hoc or interview write-ups
└── README.md                 # How to run locally (dev-container)
```
