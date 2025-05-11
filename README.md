# Figment Take-Home Test

Minimal dbt + Postgres stack with Dev Container, unit-tests and CI.

---

## 🚀 Quick Start (VS Code Dev Container)

### Requirements
- Visual Studio Code with "Dev Containers" extension
- Docker Desktop (macOS/Windows) or Docker Engine (Linux)
- Docker Compose
- Port 5432 available for PostgreSQL

1. Press **F1 → "Dev Containers: Reopen in Container"** or **select the icon on the left bottom corner of VS Code → "Open in Container"**  
   VS Code builds `.devcontainer/Dockerfile`, which already includes:

   * Python 3.11, **pipenv**, dbt 1.7 +, pytest
   * Postgres service wired to `profiles.yml`

2. When the build finishes the integrated terminal drops you into an
   **Pipenv** aware environment.
   Run your usual commands:

   ```bash
   make build                       # seeds → run → test
   make test                        # Run dbt tests
   make docs                        # Explore lineage: ethereum_rewards_raw ➜ stg_* ➜ int_* ➜ fct_*.

   ```

That's it—no extra installs; everything is baked into the image.
Devcontainer also initiates the Postegres DB.

---

## ⚙️ CI

* **Workflow:** `.github/workflows/ci.yml`
* **Steps:** checkout → build Dev Container → `pytest` → `dbt build --warn-error`
* Passes or blocks every push / pull-request to `main`.

---

## 🗂️ Key Files

```
.devcontainer/                # Dockerfile + devcontainer.json (dependencies baked in)
docker-compose.yml            # Postgres build context
models/                       # staging/ → intermediate/ → marts/ + Data and Unit tests
macros/                       # reusable Jinja 
tests/                        # Singular tests
seeds/                        # CSVs for small fixed tables used as support tables
.github/workflows/ci.yml      # Github Actions Continuous Integration workflow
```

---

## 🔧 Common Commands

```bash
pipenv run dbt build                        # compile + run + test
pipenv run dbt build -s staging.            # only staging layer
pipenv run pytest -q                        # run unit-tests
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
│   │   └── ethereum/
│   │       ├── _staging_ethereum__sources.yml
│   │       ├── stg_ethereum_rewards.sql
│   │       └── stg_ethereum_rewards_schema.yml            # generic data tests + docs
│   ├── intermediate/         # Intermediate tables
│   │   └── ethereum/
│   │       ├── int_rewards_enriched.sql
│   │       ├── int_rewards_enriched_schema.sql            # generic data tests + docs
|   |       ├── int_rewards_daily_agg.sql
│   │       └── int_rewards_daily_a_schema.yml             # generic data tests + docs
│   ├── marts/                # Incremental daily model
│   |    └── ethereum/
│   |       ├── fct_ethereum_rewards_daily.sql
│   |       └── fct_ethereum_rewards_daily_schema.yml      # generic data tests + docs
|   └── unit_tests/  
├── tests/                    # Unit tests
│   └── data/                 # Singular data tests
├── seeds/                    # Reference seeds
├── snapshots/                # Slowly-changing dimensions
├── analyses/                 # Ad-hoc or interview write-ups
└── README.md                 # How to run locally (dev-container)
```

## Why Intermediate Layer?

| Layer               | Responsibility                     | Benefit                                                         |
| ------------------- | ---------------------------------- | --------------------------------------------------------------- |
| **I1 – enriched**   | Do all *row-level* math once       | Central place for currency/exponent fixes; easier to unit-test  |
| **I2 – daily_agg**  | Pure *aggregation*                 | Keeps final model thin; reusable for other marts (e.g., weekly) |
| **Fact table**      | Incremental load & running balance | Smallest possible footprint for the expensive `merge`           |

This separation guarantees:

- Idempotency – rerunning any upstream model never double-counts; unique keys enforce that.
- Debuggability – it is possible  to demo numbers at each hop.
- Performance – only one model (ethereum_rewards_daily) is incremental/merged; others are simple selects.

## Materialization Strategy

| Type            | Pros                                          | Cons                                | Best spots                            |
| --------------- | --------------------------------------------- | ----------------------------------- | ------------------------------------- |
| **view**        | Zero storage, always fresh                    | Re-computes every read              | `int_rewards_daily_agg`               |
| **table**       | Fast downstream queries                       | Rebuild cost on `dbt run -m +model` | `stg_ethereum_rewards` and `int_rewards_enriched`                |
| **incremental** | Adds only new partitions, avoids full rebuild | Extra complexity; needs unique keys | `fact_ethereum_rewards_daily`         |
| **ephemeral**   | Inlined CTE (no object)                       | Large SQL + no re-use               | Not used – we want inspectable tables |
