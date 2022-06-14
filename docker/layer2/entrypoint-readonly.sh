#!/bin/bash

set -o errexit

WORKSPACE="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
CONFIG_DIR="$WORKSPACE/config"

function generate-godwoken-readonly-config() {
    log "start"
    if [ -s "$CONFIG_DIR/godwoken-config-readonly.toml" ]; then
        log "$CONFIG_DIR/godwoken-config-readonly.toml already exists, skip"
        return 0
    fi

    cp $CONFIG_DIR/godwoken-config.toml $CONFIG_DIR/godwoken-config-readonly.toml

    sed -i 's#^node_mode = .*$#node_mode = '"'$GODWOKEN_MODE'"'#' $CONFIG_DIR/godwoken-config-readonly.toml
    sed -i 's#^path = .*$#path = '"'$STORE_PATH'"'#' $CONFIG_DIR/godwoken-config-readonly.toml
    sed -i 's@listen = "/ip4/.*"@dial = ["/dns4/godwoken/tcp/9999"]@' $CONFIG_DIR/godwoken-config-readonly.toml

    log "Generate file \"$CONFIG_DIR/godwoken-config-readonly.toml\""
}

function log() {
    echo "[${FUNCNAME[1]}] $1"
}

function main() {
    godwoken --version
    gw-tools --version

    # Setup Godwoken-readonly at the first time
    generate-godwoken-readonly-config

    exec godwoken run -c $CONFIG_DIR/godwoken-config-readonly.toml
}

main "$@"
