#!/bin/bash

set -o errexit

WORKSPACE="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
CONFIG_DIR="$WORKSPACE/config"
ACCOUNTS_DIR="${ACCOUNTS_DIR:-"ACCOUNTS_DIR is required"}"
CKB_DIR="${CKB_DIR:-"CKB_DIR is required"}"
CKB_LIST_HASHES=$(cat $CKB_DIR/list-hashes.json)
V1_CONFIG_DIR="$WORKSPACE/v1config"
V1_GODWOKEN_CONFIG="$WORKSPACE/v1config/godwoken-config.toml"

function log() {
    echo "[${FUNCNAME[1]}] $1"
}

function generate-scripts-deployment() {
    log "Start"
    if [ -s "$CONFIG_DIR/scripts-deployment.json" ]; then
        log "$CONFIG_DIR/scripts-deployment.json already exists, skip"
        return 0
    fi

    echo "{
    $(get-script-deployment "custodian_lock"    "/v0-scripts/godwoken-scripts/custodian-lock"),
    $(get-script-deployment "deposit_lock"      "/v0-scripts/godwoken-scripts/deposit-lock"),
    $(get-script-deployment "withdrawal_lock"   "/v0-scripts/godwoken-scripts/withdrawal-lock"),
    $(get-script-deployment "challenge_lock"    "/v0-scripts/godwoken-scripts/challenge-lock"),
    $(get-script-deployment "stake_lock"        "/v0-scripts/godwoken-scripts/stake-lock"),
    $(get-script-deployment "state_validator"   "/v0-scripts/godwoken-scripts/state-validator"),
    $(get-script-deployment "l2_sudt_validator" "/v0-scripts/godwoken-scripts/sudt-validator"),
    $(get-script-deployment "eth_account_lock"  "/v0-scripts/godwoken-scripts/eth-account-lock"),
    $(get-script-deployment "tron_account_lock" "/v0-scripts/godwoken-scripts/tron-account-lock"),
    $(get-script-deployment "meta_contract_validator"   "/v0-scripts/godwoken-scripts/meta-contract-validator"),
    $(get-script-deployment "polyjuice_validator"       "/v0-scripts/godwoken-polyjuice/validator"),
    $(get-script-deployment "state_validator_lock"      "/v0-scripts/clerkb/poa"),
    $(get-script-deployment "poa_state"                 "/v0-scripts/clerkb/state")
}" \
    | jq > $CONFIG_DIR/scripts-deployment.json

    log "Generate file \"$CONFIG_DIR/scripts-deployment.json\""
    log "Finished"
}

function generate-rollup-config() {
    log "Start"
    if [ -s "$CONFIG_DIR/rollup-config.json" ]; then
        log "$CONFIG_DIR/rollup-config.json already exists, skip"
        return 0
    fi

    l1_sudt_cell_dep=$(cat $V1_CONFIG_DIR/rollup-config.json | jq '.l1_sudt_cell_dep')
    l1_sudt_script_type_hash=$(cat $V1_CONFIG_DIR/rollup-config.json | jq '.l1_sudt_script_type_hash')

    cat $CONFIG_DIR/rollup-config.json.template \
        | jq --argjson l1_sudt_cell_dep "$l1_sudt_cell_dep" '.l1_sudt_cell_dep = $l1_sudt_cell_dep' \
        | jq --argjson l1_sudt_script_type_hash $l1_sudt_script_type_hash '.l1_sudt_script_type_hash = $l1_sudt_script_type_hash' \
        > $CONFIG_DIR/rollup-config.json

    log "Generate file \"$CONFIG_DIR/rollup-config.json\""
    log "Finished"
}

function deploy-rollup-genesis() {
    log "start"
    if [ -s "$CONFIG_DIR/rollup-genesis-deployment.json" ]; then
        log "$CONFIG_DIR/rollup-genesis-deployment.json already exists, skip"
        return 0
    fi

    start-ckb-miner-at-background
    RUST_BACKTRACE=full gw-tools deploy-genesis \
        --ckb-rpc http://ckb:8114 \
        --scripts-deployment-path $CONFIG_DIR/scripts-deployment.json \
        -p $CONFIG_DIR/poa-config.json \
        --rollup-config $CONFIG_DIR/rollup-config.json \
        -o $CONFIG_DIR/rollup-genesis-deployment.json \
        -k $ACCOUNTS_DIR/ckb-miner-and-faucet.key
    stop-ckb-miner

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

    log "check godwoken v1 config file exists"
    start_time=$(date +%s)
    while true; do
        sleep 1
        if [ -f "${V1_GODWOKEN_CONFIG}" ]; then
            break
        fi
        elapsed=$(( $(date +%s) - start_time ))
        if [ $elapsed -gt 1200 ]; then
            log "ERROR: Godwoken v1 config file not found"
            exit 2
        fi
    done

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

function start-ckb-miner-at-background() {
    ckb -C $V1_CONFIG_DIR miner &> /dev/null &
    CKB_MINER_PID=$!
    log "ckb-miner is mining..."
}

function stop-ckb-miner() {
    log "Kill the ckb-miner process"
    if [ ! -z "$CKB_MINER_PID" ]; then
        kill $CKB_MINER_PID
        CKB_MINER_PID=""
    fi
}

function get-system-cell() {
    path=$1
    echo "$CKB_LIST_HASHES" \
        | jq ".ckb_dev.system_cells | map(select(.path | match(\".*$path.*\"))) | .[0]"
}

function get-index() {
    path=$1
    echo $(get-system-cell $path) | jq '.index' | xargs -I {} printf "\"0x%x\"" {}
}

function get-tx-hash() {
    path=$1
    echo $(get-system-cell $path) | jq '.tx_hash'
}

function get-type-hash() {
    path=$1
    echo $(get-system-cell $path) | jq '.type_hash'
}

function get-cell-dep() {
    path=$1
    echo "{
        \"dep_type\": \"code\",
        \"out_point\": {
            \"tx_hash\": $(get-tx-hash $path),
            \"index\": $(get-index $path)
        }
    }"
}

function get-script-deployment() {
    name=$1
    path=$2
    echo "\"$name\": {
        \"cell_dep\": $(get-cell-dep $path),
        \"script_type_hash\": $(get-type-hash $path)
    }"
}

function install-prerequired-toolchains() {
    if ! command -v jq &> /dev/null; then
        apt-get install -y jq
    fi
}

function main() {
    godwoken --version
    gw-tools --version

    install-prerequired-toolchains

    generate-scripts-deployment
    generate-rollup-config
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
