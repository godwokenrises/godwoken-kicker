#!/bin/bash

set -o errexit
#set -o xtrace

yarn knex migrate:latest
yarn run start:prod
