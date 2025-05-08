# This is a take home test from Figment.

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
│   │   │   └── stg_ethereum__schema.yml
│   │   └── _staging__generic_tests.yml
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
├── snapshots/                # Not required for this task (placeholder)
├── analyses/                 # Ad-hoc or interview write-ups
└── README.md                 # How to run locally (dev-container)
```
