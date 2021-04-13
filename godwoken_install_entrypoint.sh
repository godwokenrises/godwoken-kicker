#!/bin/bash

set -o errexit
set -o xtrace
PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd ${PROJECT_DIR}/godwoken
git checkout v0.1.x
cargo install moleculec --version 0.6.1
moleculec --language c --schema-file ./crates/types/schemas/godwoken.mol > ./c/build/godwoken.h
moleculec --language c --schema-file ./crates/types/schemas/blockchain.mol > ./c/build/blockchain.h

## compile godwoken meta-contract and sudt contract
cd ${PROJECT_DIR}/godwoken/c && make all && cd ..

# build
cargo build
yarn
yarn workspace @ckb-godwoken/base tsc
yarn workspace @ckb-godwoken/tools tsc