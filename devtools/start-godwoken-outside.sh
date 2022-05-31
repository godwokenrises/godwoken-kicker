#!/bin/bash

# Known issues:
#   - https://github.com/docker/for-mac/issues/4768

EXECUTABLE=$0
WORKSPACE="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
KICKER=$WORKSPACE/../kicker
GODWOKEN_DATA_DIR=$WORKSPACE/.tmp
mkdir -p $GODWOKEN_DATA_DIR

# export MANUAL_BUILD_WEB3_INDEXER=true
# export WEB3_GIT_URL=https://github.com/keroro520/godwoken-web3
# export WEB3_GIT_CHECKOUT=indexer-acquire-gw-node-info
# $KICKER init

# `kicker start` ensures godwoken deployment finished
$KICKER start

# Stop services we will hack later
$KICKER stop
$KICKER -- up -d postgres redis ckb ckb-miner ckb-indexer

# Copy compiled scripts to host machine
$KICKER -- run \
  --no-deps \
  --volume=$GODWOKEN_DATA_DIR/scripts:/.tmp/scripts \
  --entrypoint='"cp -r /scripts/ /.tmp/"' godwoken

# Generate modified $GODWOKEN_DATA_DIR/godwoken-config.toml
cat $WORKSPACE/../docker/layer2/config/godwoken-config.toml \
  | sed 's#ckb-indexer:8116#127.0.0.1:8116#' \
  | sed 's#ckb:8114#127.0.0.1:8114#' \
  | sed "s#/var/lib/layer2/data#$GODWOKEN_DATA_DIR/data#" \
  | sed "s#/scripts/#$GODWOKEN_DATA_DIR/scripts/#" \
  | sed "s#/accounts/#$WORKSPACE/../accounts/#" > $GODWOKEN_DATA_DIR/godwoken-config.toml

echo "Godwoken starting..."
screen -d -m godwoken run -c $GODWOKEN_DATA_DIR/godwoken-config.toml
timeout 10s $(while true; do
    echo '{
      "id": 42,
      "jsonrpc": "2.0",
      "method": "gw_get_mem_pool_state_ready",
      "params": []
    }' \
    | tr -d '\n' \
    | curl --silent -H 'content-type: application/json' -d @- \
    http://127.0.0.1:8119 \
    | awk 'BEGIN { FS=":"; RS="," }; { if ($1 == "\"result\"") {print $2} }' \
    | egrep true && break
done)

# Make docker services can access the outside godwoken
echo '
version: "3.8"
services:
  web3:
    environment:
      GODWOKEN_JSON_RPC: http://host.docker.internal:8119
  web3-indexer:
    environment:
      godwoken_rpc_url: http://host.docker.internal:8119
      ws_rpc_url: http://host.docker.internal:8120
' > $WORKSPACE/../docker/override.compose.yml

echo "Web3 & Web3-Indexer starting..."
$KICKER -- -f $WORKSPACE/../docker/override.compose.yml up -d --no-deps web3 web3-indexer
