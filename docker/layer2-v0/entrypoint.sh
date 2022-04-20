#!/bin/bash

set -o errexit

WORKSPACE="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
CONFIG_DIR="$WORKSPACE/config"
ACCOUNTS_DIR="${ACCOUNTS_DIR:-"ACCOUNTS_DIR is required"}"
V1_GODWOKEN_CONFIG=$WORKSPACE/v1config/godwoken-config.toml

function log() {
    echo "[${FUNCNAME[1]}] $1"
}

function deploy-scripts() {
    log "Start"
    if [ -s "$CONFIG_DIR/scripts-deployment.json" ]; then
        log "$CONFIG_DIR/scripts-deployment.json already exists, skip"
        return 0
    fi

    RUST_BACKTRACE=full gw-tools deploy-scripts \
        --ckb-rpc http://ckb:8114 \
        -i $CONFIG_DIR/scripts-config.json \
        -o $CONFIG_DIR/scripts-deployment.json \
        -k $ACCOUNTS_DIR/ckb-miner-and-faucet.key

    log "Generate file \"$CONFIG_DIR/scripts-deployment.json\""
    log "Finished"
}

function deploy-rollup-genesis() {
    log "start"
    if [ -s "$CONFIG_DIR/rollup-genesis-deployment.json" ]; then
        log "$CONFIG_DIR/rollup-genesis-deployment.json already exists, skip"
        return 0
    fi

    RUST_BACKTRACE=full gw-tools deploy-genesis \
        --ckb-rpc http://ckb:8114 \
        --scripts-deployment-path $CONFIG_DIR/scripts-deployment.json \
        -p $CONFIG_DIR/poa-config.json \
        --rollup-config $CONFIG_DIR/rollup-config.json \
        -o $CONFIG_DIR/rollup-genesis-deployment.json \
        -k $ACCOUNTS_DIR/ckb-miner-and-faucet.key
    log "Generate file \"$CONFIG_DIR/rollup-genesis-deployment.json\""
}

function generate-withdrawal-to-v1-config() {
    v1_rollup_type_hash=$(cat ${V1_GODWOKEN_CONFIG} | grep rollup_type_hash | awk '{print $3}')
    v1_deposit_lock_code_hash=$(cat ${V1_GODWOKEN_CONFIG} | grep deposit_script_type_hash | awk '{print $3}')
    v1_eth_lock_code_hash=$(cat ${V1_GODWOKEN_CONFIG} | grep -C 1 "type_ = 'eth'" | awk '{print $3}' | grep '0x')

    echo "\n[withdrawal_to_v1_config]\nv1_rollup_type_hash = ${v1_rollup_type_hash}\nv1_deposit_lock_code_hash = ${v1_deposit_lock_code_hash}\nv1_eth_lock_code_hash = ${v1_eth_lock_code_hash}\nv1_deposit_minimal_cancel_timeout_msecs = 604800000"
}

function generate-godwoken-config() {
    log "start"
    if [ -s "$CONFIG_DIR/godwoken-config.toml" ]; then
        log "$CONFIG_DIR/godwoken-config.toml already exists, skip"
        return 0
    fi

    RUST_BACKTRACE=full gw-tools generate-config \
        --ckb-rpc http://ckb:8114 \
        --ckb-indexer-rpc http://ckb-indexer:8116 \
        -c $CONFIG_DIR/scripts-config.json \
        --scripts-deployment-path $CONFIG_DIR/scripts-deployment.json \
        -g $CONFIG_DIR/rollup-genesis-deployment.json \
        --rollup-config $CONFIG_DIR/rollup-config.json \
        -o $CONFIG_DIR/godwoken-config.toml \
        --rpc-server-url 0.0.0.0:8119 \
        --privkey-path $ACCOUNTS_DIR/ckb-miner-and-faucet.key

    # some dirty modification
    if [ ! -z "$GODWOKEN_MODE" ]; then
        sed -i 's#^node_mode = .*$#node_mode = '"'$GODWOKEN_MODE'"'#' $CONFIG_DIR/godwoken-config.toml
    fi
    if [ ! -z "$STORE_PATH" ]; then
        sed -i 's#^path = .*$#path = '"'$STORE_PATH'"'#' $CONFIG_DIR/godwoken-config.toml
    fi
    sed -i 's#enable_methods = \[\]#err_receipt_ws_listen = '"'0.0.0.0:8120'"'#' $CONFIG_DIR/godwoken-config.toml

    if [ ! -z "$V1_GODWOKEN_CONFIG" ]; then
        log "godwoken v1 isn't ready"
        return 1
    fi
    printf "$(generate-withdrawal-to-v1-config)" >> $CONFIG_DIR/godwoken-config.toml

    log "Generate file \"$CONFIG_DIR/godwoken-config.toml\""
}

function start-godwoken-at-background() {
    log "Starting"
    start_time=$(date +%s)
    godwoken run -c $CONFIG_DIR/godwoken-config.toml & # &> /dev/null &
    GODWOKEN_PID=$!
    while true; do
        sleep 1
        result=$(curl http://127.0.0.1:8119 &> /dev/null || echo "Godwoken not started")
        if [ "$result" != "Godwoken not started" ]; then
            break
        fi
        elapsed=$(( $(date +%s) - start_time ))
        if [ $elapsed -gt 10 ]; then
            log "ERROR: start godwoken timeout"
            exit 2
        fi
    done
    log "Godwoken started"
}

function deposit-for-test-accounts() {
    log "Start"
    gw-tools deposit-ckb \
        --godwoken-rpc-url http://godwoken-v0:8119 \
        --ckb-rpc http://ckb:8114 \
        --scripts-deployment-path $CONFIG_DIR/scripts-deployment.json \
        --config-path $CONFIG_DIR/godwoken-config.toml \
        --privkey-path $ACCOUNTS_DIR/ckb-miner-and-faucet.key \
        --eth-address 0x966b30e576a4d6731996748b48dd67c94ef29067 \
        --capacity 10000 || echo "FIXME: gw_tools Deposit CKB error: invalid type: null, expected struct TransactionView"

    gw-tools deposit-ckb \
        --godwoken-rpc-url http://godwoken-v0:8119 \
        --ckb-rpc http://ckb:8114 \
        --scripts-deployment-path $CONFIG_DIR/scripts-deployment.json \
        --config-path $CONFIG_DIR/godwoken-config.toml \
        --privkey-path $ACCOUNTS_DIR/ckb-miner-and-faucet.key \
        --eth-address 0x4fef21f1d42e0d23d72100aefe84d555781c31bb \
        --capacity 10000 || echo "FIXME: gw_tools Deposit CKB error: invalid type: null, expected struct TransactionView"
    log "Fininshed"
}

function main() {
    godwoken --version
    gw-tools --version

    # Setup Godwoken at the first time
    deploy-scripts
    deploy-rollup-genesis
    generate-godwoken-config
    
    start-godwoken-at-background

    deposit-for-test-accounts

    # Godwoken daemon
    while true; do
        result=$(curl http://127.0.0.1:8119 &> /dev/null || echo "wake up")
        if [ "$result" == "wake up" ]; then
            godwoken run -c $CONFIG_DIR/godwoken-config.toml || echo "Godwoken exit"
        fi
        sleep 30
    done
}

main "$@"
