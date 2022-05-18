#!/bin/bash

set -o errexit

cd /godwoken-web3
yarn knex migrate:latest
