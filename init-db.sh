#!/bin/bash
set -euo pipefail          # safer

# bail out early if the table already exists (script got re-run manually)
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<'EOSQL'
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_namespace WHERE nspname = 'sources') THEN
    CREATE SCHEMA sources;
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS sources.ethereum_rewards_raw (
  network                  text,
  protocol                 text,
  reward_type              text,
  type                     text,
  address                  text,
  "timestamp"              text,
  claimed_reward_currency  text,
  claimed_reward_exp       integer,
  claimed_reward_numeric   bigint,
  claimed_reward_text      text,
  mark                     integer,
  epoch                    integer,
  processed_at             text,
  "time"                   text,
  validator                text
);

COPY sources.ethereum_rewards_raw
FROM PROGRAM 'gzip -dc /home/data/ethereum_rewards_raw.csv.gz'
WITH (FORMAT csv, HEADER true, NULL '');
EOSQL
