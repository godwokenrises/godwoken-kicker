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

# sleep 120
# export API_URL=http://ckb:8114
# ckb-cli wallet get-capacity --address ckt1qyqy84gfm9ljvqr69p0njfqullx5zy2hr9kq0pd3n5
# cargo install moleculec --version 0.6.1

# deploy scripts
export LUMOS_CONFIG_FILE=${PROJECT_DIR}/config/lumos-config.json
export PRIVKEY=deploy/private_key
export ckb_rpc=http://ckb:8114
export RUST_BACKTRACE=1
cd ${PROJECT_DIR}/godwoken
#./target/debug/gw-tools deploy-scripts -r ${ckb_rpc} -i deploy/scripts-deploy.json -o deploy/scripts-deploy-result.json -k ${PRIVKEY}


# depoly genesis block
#./target/debug/gw-tools deploy-genesis -r ${ckb_rpc} -d deploy/scripts-deploy-result.json -p deploy/poa-config.json -u deploy/rollup-config.json -o deploy/genesis-deploy-result.json -k ${PRIVKEY}

# copy polyjuice build file
# todo: We should use real one in the later version
#cp ${PROJECT_DIR}/godwoken-polyjuice/build/generator ${PROJECT_DIR}/godwoken/deploy/polyjuice-generator
#cp scripts/release/always-success deploy/polyjuice-validator

# generate config file
#./target/debug/gw-tools generate-config -r ${ckb_rpc} -g deploy/genesis-deploy-result.json -s deploy/scripts-deploy-result.json -p deploy -o config.toml

# Update block_producer.wallet_config section to your own lock.
#cp ${PROJECT_DIR}/config/edit_godwoken_config.sh edit_godwoken_config.sh
#./edit_godwoken_config.sh 

# prepare runner config file for polyjuice
# cp $TOP/runner_config.json $PolyjuiceDir/packages/runner/configs/
# todo

# start ckb-indexer
# todo: should remove to another service. but the port mapping some how not working.
${PROJECT_DIR}/indexer-data/ckb-indexer -s ${PROJECT_DIR}/indexer-data/ckb-indexer-data -c http://ckb:8114 > ${PROJECT_DIR}/indexer-data/indexer-log & 

# start godwoken
#cp ./target/debug/godwoken /usr/bin/
#export PATH=/usr/bin/godwoken:$PATH
RUST_LOG=debug RUST_BACKTRACE=full ./target/debug/godwoken
#RUST_BACKTRACE=full godwoken
#RUST_LOG=debug RUST_BACKTRACE=full cargo run --bin godwoken