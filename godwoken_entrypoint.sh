#!/bin/bash

set -o errexit
set -o xtrace
PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

export TOP=${PROJECT_DIR}/config
export PolyjuiceDir=${PROJECT_DIR}/godwoken-examples

# prepare lumos config file for polyjuice
cp $TOP/lumos-config.json $PolyjuiceDir/packages/runner/configs/

# wait for polyjuice complete preparing money before godwoken deployment, avoiding cell comsuming conflict.
cd $PolyjuiceDir
yarn workspace @godwoken-examples/runner clean:temp
yarn prepare-money
cd ../../

cd ${PROJECT_DIR}/godwoken

# deploy
export LUMOS_CONFIG_FILE=${PROJECT_DIR}/config/lumos-config.json
export PRIVKEY=0xdd50cac37ec6dd12539a968c1a2cbedda75bd8724f7bcad486548eaabb87fc8b
ts-node-dev ./packages/tools/src/deploy_scripts.ts -r http://ckb:8114 --private-key ${PRIVKEY} -f $TOP/deployment.json -o $TOP/deployment-results.json -s postgresql://user:password@postgres:5432/lumos
ts-node-dev ./packages/tools/src/deploy_genesis.ts -r http://ckb:8114 --private-key ${PRIVKEY} -d $TOP/deployment-results.json -c $TOP/godwoken_config.json -o $TOP/runner_config.json -s "postgresql://user:password@postgres:5432/lumos"

# prepare runner config file for polyjuice
cp $TOP/runner_config.json $PolyjuiceDir/packages/runner/configs/

# start godwoken
ts-node-dev ./packages/runner/src/index.ts --private-key ${PRIVKEY} -c $TOP/runner_config.json -s "postgresql://user:password@postgres:5432/lumos"