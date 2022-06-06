#!/bin/bash

set -o errexit
#set -o xtrace
PROJECT_DIR="/code"
GODWOKEN_SERVER_RPC_URL="http://godwoken:8119"
INDEXER_BIN=${PROJECT_DIR}/workspace/bin/gw-web3-indexer
CONFIG=${PROJECT_DIR}/workspace/indexer-config.toml


# import some helper function
source ${PROJECT_DIR}/gw_util.sh

# wait for web3 generate indexer config
while true; do
    sleep 3;
    if [[ -f "$CONFIG" ]]; then
      echo 'web3 indexer config toml file exits. continue.'
      break
    else
      echo 'keep waitting for web3 indexer config toml file...'
    fi
done

# wait for godwoken rpc server to start
while true; do
    sleep 2;
    if isGodwokenRpcRunning "${GODWOKEN_SERVER_RPC_URL}";
    then
      break;
    else echo "keep waitting..."
    fi
done

runWeb3Indexer(){
  RUST_LOG=debug $INDEXER_BIN 
}

# start web3 indexer
cd ${PROJECT_DIR}/workspace 
runWeb3Indexer
