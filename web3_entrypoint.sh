#!/bin/bash

set -o errexit
set -o xtrace
PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# todo: move to init process, maybe the main docker image
apt update && apt install jq -y

# read eth_lock_hash from json config file
LOCKSCRIPTS=${PROJECT_DIR}/godwoken/deploy/scripts-deploy-result.json
EthAccountLockCodeHash=$(jq -r '.eth_account_lock.script_type_hash' $LOCKSCRIPTS)

# read rollup type hash from config.toml file
CONFIGTOML=${PROJECT_DIR}/godwoken/config.toml
RollupTypeHash=$(awk -F'[ ="]+' '$1 == "rollup_type_hash" { print $2 }' $CONFIGTOML | sed 's/\x27//g')


cd ${PROJECT_DIR}/godwoken-web3

cat > ./packages/api-server/.env <<EOF
DATABASE_URL=postgres://user:password@postgres:5432/lumos
GODWOKEN_JSON_RPC=http://godwoken:8119
ETH_ACCOUNT_LOCK_HASH=$EthAccountLockCodeHash
ROLLUP_TYPE_HASH=$RollupTypeHash
EOF

yarn workspace @godwoken-web3/godwoken tsc
yarn workspace @godwoken-web3/api-server start
