#!/bin/bash

set -o errexit
set -o xtrace
PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# setup database
cd ${PROJECT_DIR}/lumos
git checkout v0.14.2-rc6
yarn
cd packages/sql-indexer
cat << EOF > knexfile.js
module.exports = {
  development: {
    client: 'postgresql',
    connection: {
      host: 'postgres',
      database: 'lumos',
      user:     'user',
      password: 'password'
    },
    pool: {
      min: 2,
      max: 10
    },
    migrations: {
      tableName: 'knex_migrations'
    }
  }
};
EOF
npx knex migrate:up