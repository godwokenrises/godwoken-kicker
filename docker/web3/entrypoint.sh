#!/bin/bash

set -o errexit
#set -o xtrace

# create folder for address mapping store
mkdir -p /usr/local/godwoken-web3/address-mapping

# WORKSPACE=/godwoken-web3
cd /godwoken-web3

yarn knex migrate:latest
yarn run start:prod
