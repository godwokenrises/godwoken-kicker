
-- Add migration script here
CREATE TABLE blocks (
    number NUMERIC PRIMARY KEY,
    hash TEXT UNIQUE NOT NULL,
    parent_hash TEXT NOT NULL,
    logs_bloom TEXT NOT NULL,
    gas_limit NUMERIC NOT NULL,
    gas_used NUMERIC NOT NULL,
    timestamp TIMESTAMPTZ NOT NULL,
    miner TEXT NOT NULL,
    size NUMERIC NOT NULL
);


-- Add migration script here
CREATE TABLE transactions (
    id BIGSERIAL PRIMARY KEY,
    hash TEXT UNIQUE NOT NULL,
    eth_tx_hash TEXT UNIQUE NOT NULL,
    block_number NUMERIC REFERENCES blocks(number) NOT NULL,
    block_hash TEXT NOT NULL,
    transaction_index INTEGER NOT NULL,
    from_address TEXT NOT NULL,
    to_address TEXT,
    value NUMERIC NOT NULL,
    nonce NUMERIC,
    gas_limit NUMERIC,
    gas_price NUMERIC,
    input TEXT,
    v NUMERIC NOT NULL,
    r TEXT NOT NULL,
    s TEXT NOT NULL,
    cumulative_gas_used NUMERIC,
    gas_used NUMERIC,
    logs_bloom TEXT NOT NULL,
    contract_address TEXT,
    status BOOLEAN NOT NULL
);

CREATE INDEX ON transactions (block_number);
CREATE INDEX ON transactions (block_hash);
CREATE INDEX ON transactions (from_address);
CREATE INDEX ON transactions (to_address);
CREATE INDEX ON transactions (contract_address);
CREATE UNIQUE INDEX block_number_transaction_index_idx ON transactions (block_number, transaction_index);
CREATE UNIQUE INDEX block_hash_transaction_index_idx ON transactions (block_hash, transaction_index);


-- Add migration script here
CREATE TABLE logs (
    id BIGSERIAL PRIMARY KEY,
    transaction_id BIGSERIAL REFERENCES transactions(id) NOT NULL,
    transaction_hash TEXT NOT NULL,
    transaction_index INTEGER NOT NULL,
    block_number NUMERIC REFERENCES blocks(number) NOT NULL,
    block_hash TEXT NOT NULL,
    address TEXT NOT NULL,
    data TEXT NOT NULL,
    log_index INTEGER NOT NULL,
    topics TEXT[] NOT NULL
);

CREATE INDEX ON logs (transaction_hash);
CREATE INDEX ON logs (block_hash);
CREATE INDEX ON logs (address);

-- Add migration script here
CREATE TABLE accounts (
    id SERIAL PRIMARY KEY,
    eth_address bytea NOT NULL,
    gw_short_address bytea NOT NULL
);

CREATE UNIQUE INDEX accounts_eth_address_unique ON accounts (eth_address);
CREATE INDEX accounts_gw_short_address_index ON accounts (gw_short_address);

-- Add migration script here
CREATE TABLE error_transactions (
    id BIGSERIAL PRIMARY KEY,
    hash TEXT UNIQUE NOT NULL,
    block_number NUMERIC NOT NULL,
    cumulative_gas_used NUMERIC,
    gas_used NUMERIC,
    status_code NUMERIC NOT NULL,
    status_reason bytea NOT NULL
);

CREATE INDEX ON error_transactions (block_number);
CREATE INDEX ON error_transactions (hash);
