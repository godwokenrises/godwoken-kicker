#!/bin/bash
set -o errexit

WORKSPACE=/var/lib/web3-indexer
CONFIG_DIR=$CONFIG_DIR

cp $CONFIG_DIR/web3-indexer-config.toml $WORKSPACE/indexer-config.toml

# Start a indexer service
gw-web3-indexer
