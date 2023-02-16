#!/bin/bash

# NOTE: In `config/rollup-config.json`, `l1_sudt_cell_dep` identifies the l1_sudt cell located at the genesis block of CKB. Please type `ckb -C docker/layer1/ckb list-hash` for more information.

set -o errexit

WORKSPACE="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
CONFIG_DIR="$WORKSPACE/config"
ACCOUNTS_DIR="${ACCOUNTS_DIR:-"ACCOUNTS_DIR is required"}"
CKB_MINER_PID=""
GODWOKEN_PID=""
CHAIN_ID=71400

function start_ckb_miner_at_background() {
    ckb -C $CONFIG_DIR miner &> /dev/null &
    CKB_MINER_PID=$!
    log "ckb-miner is mining..."
}

function stop_ckb_miner() {
    log "Kill the ckb-miner process"
    if [ ! -z "$CKB_MINER_PID" ]; then
        kill $CKB_MINER_PID
        CKB_MINER_PID=""
    fi
}

function wait_for_godwoken_started() {
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
function stop_godwoken() {
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

# The scripts-config.json file records the names and locations of all scripts
# that have been compiled in docker image. These compiled scripts will be
# deployed, and the deployment result will be stored into scripts-deployment.json.
# 
# To avoid redeploying, this command skips scripts-deployment.json if it already
# exists.
#
# More info: https://github.com/godwokenrises/godwoken-docker-prebuilds/blob/97729b15093af6e5f002b46a74c549fcc8c28394/Dockerfile#L42-L54
function deploy_scripts() {
    log "Start"
    if [ -s "$CONFIG_DIR/scripts-deployment.json" ]; then
        log "$CONFIG_DIR/scripts-deployment.json already exists, skip"
        return 0
    fi

    start_ckb_miner_at_background
    RUST_BACKTRACE=full gw-tools deploy-scripts \
        --ckb-rpc http://ckb:8114 \
        --ckb-indexer-rpc http://ckb-indexer:8116 \
        -i $CONFIG_DIR/scripts-config.json \
        -o $CONFIG_DIR/scripts-deployment.json \
        -k $ACCOUNTS_DIR/rollup-scripts-deployer.key
    stop_ckb_miner

    log "Generate file \"$CONFIG_DIR/scripts-deployment.json\""
    log "Finished"
}

function deploy_rollup_genesis() {
    log "start"
    if [ -s "$CONFIG_DIR/rollup-genesis-deployment.json" ]; then
        log "$CONFIG_DIR/rollup-genesis-deployment.json already exists, skip"
        return 0
    fi

    start_ckb_miner_at_background
    RUST_BACKTRACE=full gw-tools deploy-genesis \
        --ckb-rpc http://ckb:8114 \
        --ckb-indexer-rpc http://ckb-indexer:8116 \
        --scripts-deployment-path $CONFIG_DIR/scripts-deployment.json \
        --rollup-config $CONFIG_DIR/rollup-config.json \
        -o $CONFIG_DIR/rollup-genesis-deployment.json \
        -k $ACCOUNTS_DIR/godwoken-block-producer.key
    stop_ckb_miner
    log "Generate file \"$CONFIG_DIR/rollup-genesis-deployment.json\""
}

function generate_godwoken_config() {
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
        --node-mode fullnode \
        --store-path $STORE_PATH \
        -c $CONFIG_DIR/scripts-config.json \
        --scripts-deployment-path $CONFIG_DIR/scripts-deployment.json \
        -g $CONFIG_DIR/rollup-genesis-deployment.json \
        --rollup-config $CONFIG_DIR/rollup-config.json \
        -o $CONFIG_DIR/godwoken-config.toml \
        --rpc-server-url 0.0.0.0:8119 \
        --privkey-path $ACCOUNTS_DIR/godwoken-block-producer.key \
        --block-producer-address 0x2e9df163055245bfadd35e3a1f05f06096447c85 \
        --p2p-listen /ip4/0.0.0.0/tcp/9999 \
        --output-withdrawal-to-v1-config $CONFIG_DIR/withdrawal-to-v1.toml

    log "Generate file \"$CONFIG_DIR/godwoken-config.toml\""
}

function create_polyjuice_root_account() {
    log "start"
    if [ -s "$CONFIG_DIR/polyjuice-root-account-id" ]; then
        log "$CONFIG_DIR/polyjuice-root-account-id already exists, skip"
        return 0
    fi

    start_ckb_miner_at_background

    # Deposit for block_producer
    #
    # Use rollup-scripts-deployer so that this transaction isn't in conflict
    # with submission txs or v0 deployment/submission txs.
    log "Deposit for block_producer"
    RUST_BACKTRACE=full gw-tools deposit-ckb \
        --privkey-path $ACCOUNTS_DIR/rollup-scripts-deployer.key \
        --eth-address 0x2e9df163055245bfadd35e3a1f05f06096447c85 \
        --godwoken-rpc-url http://127.0.0.1:8119 \
        --ckb-rpc http://ckb:8114 \
        --ckb-indexer-rpc http://ckb-indexer:8116 \
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

    stop_ckb_miner

    tail -n 1 /var/tmp/gw-tools.log | grep -oE '[0-9]+$' > $CONFIG_DIR/polyjuice-root-account-id
    log "Generate file \"$CONFIG_DIR/polyjuice-root-account-id\""
}

function generate_web3_indexer_config() {
    log "Start"
    if [ -s "$CONFIG_DIR/web3-indexer-config.toml" ]; then
        log "$CONFIG_DIR/web3-indexer-config.toml already exists, skip"
        return 0
    fi

    if ! command -v jq &> /dev/null; then
        apt-get install -y jq &>/dev/null
    fi

    # see: https://github.com/godwokenrises/godwoken-web3#start-indexer
    cat <<EOF > $CONFIG_DIR/web3-indexer-config.toml
godwoken_rpc_url="http://godwoken-readonly:8119"
pg_url="postgres://user:password@postgres:5432/lumos"
EOF

    log "Generate file \"$CONFIG_DIR/web3-indexer-config.toml\""
    log "Finished"
}

function post_godwoken_start_setup() {
    wait_for_godwoken_started

    # Should make sure that the Polyjuice root account was created and the layer2 block was synced
    create_polyjuice_root_account

    generate_web3_indexer_config
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

    # Setup Godwoken at the first time
    deploy_scripts
    deploy_rollup_genesis
    generate_godwoken_config

    # Exec godwoken and finish setup in the background.
    post_godwoken_start_setup &

    exec godwoken run -c $CONFIG_DIR/godwoken-config.toml
}

main "$@"
