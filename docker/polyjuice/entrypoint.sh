#!/bin/bash

set -o errexit
set -o xtrace
PROJECT_DIR=/code
GODWOKEN_RPC_URL="http://godwoken:8119"

# import some helper function
source ${PROJECT_DIR}/gw_util.sh

# detect which mode to start godwoken_web3
if [ "$MANUAL_BUILD_POLYMAN" = true ] ; then 
  echo "manual mode.."
  cd /code/godwoken-polyman
else
  echo "prebuild mode.."
  cd /godwoken-polyman
fi

yarn workspace @godwoken-polyman/runner clean

# start the callPolyman preparation http server in background
yarn workspace @godwoken-polyman/runner start-call-polyman &

# wait for godwoken rpc server to start
while true; do
    sleep 5;
    if isGodwokenRpcRunning "${GODWOKEN_RPC_URL}";
    then
      break;
    else echo "keep waitting..."
    fi
done

# start the main http server of polyman
yarn workspace @godwoken-polyman/runner start
