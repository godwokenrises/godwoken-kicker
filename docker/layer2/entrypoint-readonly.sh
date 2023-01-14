#!/bin/bash

set -o errexit

WORKSPACE="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
CONFIG_DIR="$WORKSPACE/config"

function generate_godwoken_readonly_config() {
    log "start"
    if [ -s "$CONFIG_DIR/godwoken-config-readonly.toml" ]; then
        log "$CONFIG_DIR/godwoken-config-readonly.toml already exists, skip"
        return 0
    fi

    RUST_BACKTRACE=full gw-tools generate-config \
        --ckb-rpc http://ckb:8114 \
        --ckb-indexer-rpc http://ckb-indexer:8116 \
        --node-mode "readonly" \
        --store-path $STORE_PATH \
        -c $CONFIG_DIR/scripts-config.json \
        --scripts-deployment-path $CONFIG_DIR/scripts-deployment.json \
        -g $CONFIG_DIR/rollup-genesis-deployment.json \
        --rollup-config $CONFIG_DIR/rollup-config.json \
        -o $CONFIG_DIR/godwoken-config-readonly.toml \
        --rpc-server-url 0.0.0.0:8119 \
        --p2p-dial /dns4/godwoken/tcp/9999

    log "Generate file \"$CONFIG_DIR/godwoken-config-readonly.toml\""
}

function log() {
    echo "[${FUNCNAME[1]}] $1"
}

function main() {
    godwoken --version
    gw-tools --version

    # Setup Godwoken-readonly at the first time
    generate_godwoken_readonly_config

    exec godwoken run -c $CONFIG_DIR/godwoken-config-readonly.toml
}

main "$@"
