#!/bin/bash

set -o errexit
set -o xtrace
PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

export TOP=${PROJECT_DIR}/config
export PolyjuiceDir=${PROJECT_DIR}/godwoken-examples

export LUMOS_CONFIG_FILE=${PROJECT_DIR}/config/lumos-config.json
export PRIVKEY=deploy/private_key
export ckb_rpc=http://ckb:8114
export RUST_BACKTRACE=1

# prepare lumos config file for polyjuice
cp $TOP/lumos-config.json $PolyjuiceDir/packages/runner/configs/

# wait for polyjuice complete preparing money before godwoken deployment, avoiding cell comsuming conflict.
cd $PolyjuiceDir
yarn workspace @godwoken-examples/runner clean:temp
yarn prepare-money
cd ../../

# wait for suffice fund to deploy godwoken scriptsx
while true; do
    sleep 3;
    MINER_BALANCE=$(ckb-cli --url ${ckb_rpc} wallet get-capacity --wait-for-sync --address ckt1qyqy84gfm9ljvqr69p0njfqullx5zy2hr9kq0pd3n5)
    MYTOTAL="${MINER_BALANCE##immature*:}"
    TOTAL=" ${MYTOTAL%%.*} "
    if [[ "$TOTAL" -gt 1000 ]]; then
      echo 'fund suffice, ready to deploy godwoken script.'
      break
    else
      echo 'fund unsuffice ${TOTAL}, keep waitting.'
    fi
done

# deploy scripts
cd ${PROJECT_DIR}/godwoken
./target/debug/gw-tools deploy-scripts -r ${ckb_rpc} -i deploy/scripts-deploy.json -o deploy/scripts-deploy-result.json -k ${PRIVKEY}
#cargo run --bin gw-tools deploy-scripts -r ${ckb_rpc} -i deploy/scripts-deploy.json -o deploy/scripts-deploy-result.json -k ${PRIVKEY}

# depoly genesis block
./target/debug/gw-tools deploy-genesis -r ${ckb_rpc} -d deploy/scripts-deploy-result.json -p deploy/poa-config.json -u deploy/rollup-config.json -o deploy/genesis-deploy-result.json -k ${PRIVKEY}
#cargo run --bin gw-tools deploy-genesis -r ${ckb_rpc} -d deploy/scripts-deploy-result.json -p deploy/poa-config.json -u deploy/rollup-config.json -o deploy/genesis-deploy-result.json -k ${PRIVKEY}

# copy polyjuice build file
# todo: We should use real validator in the later version
cp ${PROJECT_DIR}/godwoken-polyjuice/build/generator ${PROJECT_DIR}/godwoken/deploy/polyjuice-generator
cp scripts/release/always-success ${PROJECT_DIR}/godwoken/deploy/polyjuice-validator
#cp ${PROJECT_DIR}/godwoken-polyjuice/build/validator ${PROJECT_DIR}/godwoken/deploy/polyjuice-validator

# generate config file
./target/debug/gw-tools generate-config -r ${ckb_rpc} -g deploy/genesis-deploy-result.json -s deploy/scripts-deploy-result.json -p deploy -o config.toml
#cargo run --bin gw-tools generate-config -r ${ckb_rpc} -g deploy/genesis-deploy-result.json -s deploy/scripts-deploy-result.json -p deploy -o config.toml

# Update block_producer.wallet_config section to your own lock.
cp ${PROJECT_DIR}/config/edit_godwoken_config.sh edit_godwoken_config.sh
./edit_godwoken_config.sh
rm edit_godwoken_config.sh 

# prepare runner config file for polyjuice
cp ${PROJECT_DIR}/godwoken/deploy/scripts-deploy-result.json ${PROJECT_DIR}/godwoken-examples/packages/runner/configs/scripts-deploy-result.json
cp ${PROJECT_DIR}/godwoken/config.toml ${PROJECT_DIR}/godwoken-examples/packages/runner/configs/config.toml
# generate godwoken config file for polyjuice
cd ${PROJECT_DIR}/godwoken-examples && yarn gen-config && cd ${PROJECT_DIR}/godwoken 


# start ckb-indexer
# todo: should remove to another service. but the port mapping some how not working.
${PROJECT_DIR}/indexer-data/ckb-indexer -s ${PROJECT_DIR}/indexer-data/ckb-indexer-data -c ${ckb_rpc} > ${PROJECT_DIR}/indexer-data/indexer-log & 

# start godwoken
RUST_LOG=debug ./target/debug/godwoken
#cargo run --bin godwoken