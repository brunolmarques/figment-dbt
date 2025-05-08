#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
	CREATE SCHEMA sources;

	CREATE TABLE sources.ethereum_rewards_raw
		(network                  text
		,protocol                 text
		,reward_type              text
		,type                     text
		,address                  text
		,timestamp                text
		,claimed_reward_currency  text
		,claimed_reward_exp       integer
		,claimed_reward_numeric   bigint
		,claimed_reward_text      text
		,mark                     integer
		,epoch                    integer
		,processed_at             text
		,time                     text);

	copy sources.ethereum_rewards_raw FROM PROGRAM 'gzip -dc /home/data/ethereum_rewards_raw.csv.gz' DELIMITER ',' CSV HEADER NULL '';

EOSQL
