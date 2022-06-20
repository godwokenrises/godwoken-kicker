#!/bin/bash

set -o errexit

WORKSPACE="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
CONFIG_DIR="$WORKSPACE/config"
ACCOUNTS_DIR="${ACCOUNTS_DIR:-"ACCOUNTS_DIR is required"}"
CKB_DIR="${CKB_DIR:-"CKB_DIR is required"}"
CKB_LIST_HASHES=$(cat $CKB_DIR/list-hashes.json)
CKB_MINER_PID=""
GODWOKEN_PID=""
CHAIN_ID=71400

function start-ckb-miner-at-background() {
    ckb -C $CONFIG_DIR miner &> /dev/null &
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

function wait-for-godwoken-started() {
    log "Starting"
    start_time=$(date +%s)
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

# Notice: Be careful, if you you try to stop Godwoken in the early phase,
# you should make sure that the Polyjuice root account is created and the layer2 block is synced.
#
# Try to avoid restarting Godwoken if you can.
function stop-godwoken() {
    log "Killing the Godwoken process"
    if [ ! -z "$GODWOKEN_PID" ]; then
        kill $GODWOKEN_PID
        GODWOKEN_PID=""
    fi
    while true; do
        log "Wait until Godwoken exitted" && sleep 2
        result=$(curl http://127.0.0.1:8119 &> /dev/null && echo "Godwoken is running")
        if [ "$result" != "Godwoken is running" ]; then
            break
        fi 
    done
    log "Done"
}

# More info: https://github.com/nervosnetwork/godwoken-docker-prebuilds/blob/97729b15093af6e5f002b46a74c549fcc8c28394/Dockerfile#L42-L54
function generate-scripts-deployment() {
    log "Start"
    if [ -s "$CONFIG_DIR/scripts-deployment.json" ]; then
        log "$CONFIG_DIR/scripts-deployment.json already exists, skip"
        return 0
    fi

    if [ "$MANUAL_BUILD_POLYJUICE" = "true" || "$MANUAL_BUILD_SCRIPTS" = "true" ]; then
        start-ckb-miner-at-background
        RUST_BACKTRACE=full gw-tools deploy-scripts \
            --ckb-rpc http://ckb:8114 \
            -i $CONFIG_DIR/scripts-config.json \
            -o $CONFIG_DIR/scripts-deployment.json \
            -k $ACCOUNTS_DIR/rollup-scripts-deployer.key
        stop-ckb-miner
    else
        echo "{
    $(get-script-deployment "challenge_lock"    "/v1-scripts/godwoken-scripts/challenge-lock"),
    $(get-script-deployment "custodian_lock"    "/v1-scripts/godwoken-scripts/custodian-lock"),
    $(get-script-deployment "deposit_lock"      "/v1-scripts/godwoken-scripts/deposit-lock"),
    $(get-script-deployment "eth_account_lock"  "/v1-scripts/godwoken-scripts/eth-account-lock"),
    $(get-script-deployment "l2_sudt_validator" "/v1-scripts/godwoken-scripts/sudt-validator"),
    $(get-script-deployment "meta_contract_validator"   "/v1-scripts/godwoken-scripts/meta-contract-validator"),
    $(get-script-deployment "polyjuice_validator"       "/v1-scripts/godwoken-polyjuice/validator"),
    $(get-script-deployment "stake_lock"        "/v1-scripts/godwoken-scripts/stake-lock"),
    $(get-script-deployment "state_validator"   "/v1-scripts/godwoken-scripts/state-validator"),
    $(get-script-deployment "tron_account_lock" "/v1-scripts/godwoken-scripts/tron-account-lock"),
    $(get-script-deployment "withdrawal_lock"   "/v1-scripts/godwoken-scripts/withdrawal-lock"),
    $(get-script-deployment "eth_addr_reg_validator"    "/v1-scripts/godwoken-scripts/eth-addr-reg-validator"),
    $(get-script-deployment "omni_lock"         "/v1-scripts/godwoken-scripts/omni_lock")
    }" \
        | jq > $CONFIG_DIR/scripts-deployment.json
    fi

    log "Generate file \"$CONFIG_DIR/scripts-deployment.json\""
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
        --omni-lock-config-path $CONFIG_DIR/scripts-deployment.json \
        --rollup-config $CONFIG_DIR/rollup-config.json \
        -o $CONFIG_DIR/rollup-genesis-deployment.json \
        -k $ACCOUNTS_DIR/godwoken-block-producer.key
    stop-ckb-miner
    log "Generate file \"$CONFIG_DIR/rollup-genesis-deployment.json\""
}

function generate-rollup-config() {
    log "Start"
    if [ -s "$CONFIG_DIR/rollup-config.json" ]; then
        log "$CONFIG_DIR/rollup-config.json already exists, skip"
        return 0
    fi

    cat $CONFIG_DIR/rollup-config.json.template \
        | jq --argjson cell_dep "$(get-cell-dep l1_sudt)" '.l1_sudt_cell_dep = $cell_dep' \
        | jq --argjson l1_sudt_script_type_hash $(get-type-hash l1_sudt) '.l1_sudt_script_type_hash = $l1_sudt_script_type_hash' \
        > $CONFIG_DIR/rollup-config.json

    log "Generate file \"$CONFIG_DIR/rollup-config.json\""
    log "Finished"
}

function generate-godwoken-config() {
    log "start"
    if [ -s "$CONFIG_DIR/godwoken-config.toml" ]; then
        log "$CONFIG_DIR/godwoken-config.toml already exists, skip"
        return 0
    fi

    # Node: 0x2e9df163055245bfadd35e3a1f05f06096447c85 is the eth_address of
    # `godwoken-block-producer.key`
    RUST_BACKTRACE=full gw-tools generate-config \
        --ckb-rpc http://ckb:8114 \
        --ckb-indexer-rpc http://ckb-indexer:8116 \
        -c $CONFIG_DIR/scripts-config.json \
        --scripts-deployment-path $CONFIG_DIR/scripts-deployment.json \
        --omni-lock-config-path $CONFIG_DIR/scripts-deployment.json \
        -g $CONFIG_DIR/rollup-genesis-deployment.json \
        --rollup-config $CONFIG_DIR/rollup-config.json \
        -o $CONFIG_DIR/godwoken-config.toml \
        --rpc-server-url 0.0.0.0:8119 \
        --privkey-path $ACCOUNTS_DIR/godwoken-block-producer.key \
        --block-producer-address 0x2e9df163055245bfadd35e3a1f05f06096447c85

    # some dirty modification
    if [ ! -z "$GODWOKEN_MODE" ]; then
        sed -i 's#^node_mode = .*$#node_mode = '"'$GODWOKEN_MODE'"'#' $CONFIG_DIR/godwoken-config.toml
    fi
    if [ ! -z "$STORE_PATH" ]; then
        sed -i 's#^path = .*$#path = '"'$STORE_PATH'"'#' $CONFIG_DIR/godwoken-config.toml
    fi
    cat >> $CONFIG_DIR/godwoken-config.toml <<EOF

[p2p_network_config]
listen = "/ip4/0.0.0.0/tcp/9999"
EOF
    sed -i 's#enable_methods = \[\]#err_receipt_ws_listen = '"'0.0.0.0:8120'"'#' $CONFIG_DIR/godwoken-config.toml

    log "Generate file \"$CONFIG_DIR/godwoken-config.toml\""
}

function create-polyjuice-root-account() {
    log "start"
    if [ -s "$CONFIG_DIR/polyjuice-root-account-id" ]; then
        log "$CONFIG_DIR/polyjuice-root-account-id already exists, skip"
        return 0
    fi

    start-ckb-miner-at-background

    # Deposit for block_producer
    #
    # Here we deposit from ckb-miner-and-faucet.key instead of
    # godwoken-block-producer.key to avoid double spending cells locked by the
    # latter -- godwoken has already started and may spend them too for block
    # submission etc.
    log "Deposit for block_producer"
    RUST_BACKTRACE=full gw-tools deposit-ckb \
        --privkey-path $ACCOUNTS_DIR/ckb-miner-and-faucet.key \
        --eth-address 0x2e9df163055245bfadd35e3a1f05f06096447c85 \
        --godwoken-rpc-url http://127.0.0.1:8119 \
        --ckb-rpc http://ckb:8114 \
        --scripts-deployment-path $CONFIG_DIR/scripts-deployment.json \
        --config-path $CONFIG_DIR/godwoken-config.toml \
        --capacity 2000

    # Create Polyjuice root account (this is a layer2 transaction)
    log "Create Polyjuice root account"
    RUST_BACKTRACE=full gw-tools create-creator-account \
        --privkey-path $ACCOUNTS_DIR/godwoken-block-producer.key \
        --godwoken-rpc-url http://127.0.0.1:8119 \
        --scripts-deployment-path $CONFIG_DIR/scripts-deployment.json \
        --config-path $CONFIG_DIR/godwoken-config.toml \
        --sudt-id 1 \
    2>&1 | tee /var/tmp/gw-tools.log

    stop-ckb-miner

    tail -n 1 /var/tmp/gw-tools.log | grep -oE '[0-9]+$' > $CONFIG_DIR/polyjuice-root-account-id
    log "Generate file \"$CONFIG_DIR/polyjuice-root-account-id\""
}

function generate-web3-indexer-config() {
    log "Start"
    if [ -s "$CONFIG_DIR/web3-indexer-config.toml" ]; then
        log "$CONFIG_DIR/web3-indexer-config.toml already exists, skip"
        return 0
    fi

    cat <<EOF > $CONFIG_DIR/web3-indexer-config.toml
chain_id=$CHAIN_ID
l2_sudt_type_script_hash="$(jq -r '.l2_sudt_validator.script_type_hash' $CONFIG_DIR/scripts-deployment.json)"
polyjuice_type_script_hash="$(jq -r '.polyjuice_validator.script_type_hash' $CONFIG_DIR/scripts-deployment.json)"
rollup_type_hash="$(jq -r '.rollup_type_hash' $CONFIG_DIR/rollup-genesis-deployment.json)"
eth_account_lock_hash="$(jq -r '.eth_account_lock.script_type_hash' $CONFIG_DIR/scripts-deployment.json)"

godwoken_rpc_url="http://godwoken-readonly:8119"
ws_rpc_url="ws://godwoken:8120"

pg_url="postgres://user:password@postgres:5432/lumos"
EOF

    log "Generate file \"$CONFIG_DIR/web3-indexer-config.toml\""
    log "Finished"
}

function post-godwoken-start-setup() {
    wait-for-godwoken-started

    # Should make sure that the Polyjuice root account was created and the layer2 block was synced
    create-polyjuice-root-account

    generate-web3-indexer-config
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

function log() {
    echo "[${FUNCNAME[1]}] $1"
}

function main() {
    godwoken --version
    gw-tools --version

    if [ -f "$CONFIG_DIR/web3-indexer-config.toml" ]; then
        exec godwoken run -c $CONFIG_DIR/godwoken-config.toml
    fi

    install-prerequired-toolchains

    generate-scripts-deployment
    generate-rollup-config
    deploy-rollup-genesis
    generate-godwoken-config

    # Exec godwoken and finish setup in the background.
    post-godwoken-start-setup &

    exec godwoken run -c $CONFIG_DIR/godwoken-config.toml
}

main "$@"
