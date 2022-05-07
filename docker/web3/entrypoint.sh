#!/bin/bash

set -o errexit
#set -o xtrace

WORKSPACE=/godwoken-web3

CONFIG_DIR=$CONFIG_DIR
cp $CONFIG_DIR/web3-config.env $WORKSPACE/packages/api-server/.env

# create folder for address mapping store
mkdir -p /usr/local/godwoken-web3/address-mapping

cd $WORKSPACE
yarn run start
