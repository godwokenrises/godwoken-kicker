#!/bin/bash

set -o errexit
set -o xtrace
PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

export TOP=${PROJECT_DIR}/config

cd ${PROJECT_DIR}/godwoken-examples
yarn install

cd ${PROJECT_DIR}/godwoken-web3
yarn install 

cd ${PROJECT_DIR}/lumos
#git checkout v0.14.2-rc6
yarn install