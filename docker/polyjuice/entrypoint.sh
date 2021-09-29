#!/bin/bash

set -o errexit
#set -o xtrace
PROJECT_DIR=/code
GODWOKEN_RPC_URL="http://godwoken:8119"
WEB3_RPC_URL="http://web3:8024"
export INDEXER_DB=/usr/local/polyman

# import some helper function
source ${PROJECT_DIR}/gw_util.sh

# detect which mode to start godwoken_web3
if [ "$MANUAL_BUILD_POLYMAN" = true ] ; then 
  echo "manual mode.."
  cd /code/packages/godwoken-polyman
else
  echo "prebuild mode.."
  cd /godwoken-polyman
fi

yarn init_placeholder_config

# wait for godwoken rpc server to start
while true; do
    sleep 5;
    if isGodwokenRpcRunning "${GODWOKEN_RPC_URL}";
    then
      break;
    else echo "keep waitting..."
    fi
done

# generate godwoken configs for polyman using current workspace
cp /code/workspace/config.toml packages/runner/configs/config.toml && echo 'cp config.toml from workspace'
cp /code/workspace/deploy/scripts-deploy-result.json packages/runner/configs/scripts-deploy-result.json && echo 'cp scripts-deploy-result.json from workspace'
cp /code/workspace/deploy/lumos-config.json packages/runner/configs/lumos-config.json && echo 'cp lumos-config from workspace'

yarn gen-config

# wait for web3 rpc server to start
while true; do
    sleep 2;
    if isWeb3RpcRunning "${WEB3_RPC_URL}";
    then
      break;
    else echo "keep waitting..."
    fi
done

# start the main http server of polyman
yarn workspace @godwoken-polyman/runner start
