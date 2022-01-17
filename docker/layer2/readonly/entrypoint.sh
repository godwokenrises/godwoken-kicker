#!/bin/bash

set -o errexit

PROJECT_DIR="/code"
GODWOKEN_CONFIG_TOML_FILE=${PROJECT_DIR}/workspace/config.toml
GODWOKEN_READONLY_TOML_FILE=${PROJECT_DIR}/workspace/readonly-config.toml

GW_RPC=http://godwoken:8119
CKB_RPC=http://ckb:8114
GODWOKEN_BIN=${PROJECT_DIR}/workspace/bin/godwoken
GW_TOOLS_BIN=${PROJECT_DIR}/workspace/bin/gw-tools

# import some helper function
source ${PROJECT_DIR}/gw_util.sh

function runGodwoken(){
  # wait for ckb rpc server to start
  while true; do
      sleep 0.2;
      if isCkbRpcRunning "$CKB_RPC";
      then
        break;
      else echo "keep waitting for ckb rpc..."
      fi
  done
  # running godwoken
  RUST_LOG=info,gw_mem_pool=trace,gw_block_producer=info,gw_generator=debug,gw_web3_indexer=debug $GODWOKEN_BIN run -c $GODWOKEN_READONLY_TOML_FILE 
}

# wait for Godwoken Fullnode rpc server to start
while true; do
  sleep 0.2;
  if isGodwokenRpcRunning "$GW_RPC";
  then
    break;
  else echo "keep waitting for godwoken fullnode rpc..."
  fi
done
 
# check if godwoken full node config.toml exist 
if test -f "$GODWOKEN_CONFIG_TOML_FILE"; then
  : 
else 
  echo "godwoken config.toml not found! exit..."
  exit
fi

# check if godwoken readonly node config.toml exist 
if test -f "$GODWOKEN_READONLY_TOML_FILE"; then
  : 
else 
  echo "godwoken readonly-config.toml not found! create new one by copying from full node.."
  cp $GODWOKEN_CONFIG_TOML_FILE $GODWOKEN_READONLY_TOML_FILE 
  # Update block_producer.wallet_config section to your own lock.
  edit_godwoken_config_toml $GODWOKEN_READONLY_TOML_FILE
fi

# start godwoken
cd ${PROJECT_DIR}/workspace
runGodwoken


