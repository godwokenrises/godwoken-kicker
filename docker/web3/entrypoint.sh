#!/bin/bash

set -o errexit
#set -o xtrace

WORKSPACE=/godwoken-web3

CONFIG_DIR=$CONFIG_DIR
cp $CONFIG_DIR/web3-config.env $WORKSPACE/packages/api-server/.env

# create folder for address mapping store
mkdir -p /usr/local/godwoken-web3/address-mapping

# start web3 server
cd $WORKSPACE/packages/api-server 
yarn start
# NODE_ENV=production DEBUG=godwoken-web3-api:server pm2 start ./bin/cluster --no-daemon --name gw-web3 --max-memory-restart 1G
