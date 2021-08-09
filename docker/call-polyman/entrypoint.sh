#!/bin/bash

set -o errexit
#set -o xtrace
PROJECT_DIR=/code
GODWOKEN_RPC_URL="http://godwoken:8119"

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

# generate godwoken configs for polyman using current workspace
cp /code/workspace/deploy/lumos-config.json packages/runner/configs/lumos-config.json && echo 'cp lumos-config from workspace' || echo 'lumos-config.json not found. use brand new one.';

yarn init_placeholder_config

# start the callPolyman preparation http server in background
yarn workspace @godwoken-polyman/runner start-call-polyman

