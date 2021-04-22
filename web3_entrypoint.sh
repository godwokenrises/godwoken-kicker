#!/bin/bash

set -o errexit
set -o xtrace
PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd ${PROJECT_DIR}/godwoken-web3

cat > ./packages/api-server/.env <<EOF
DATABASE_URL=postgres://user:password@postgres:5432/lumos
GODWOKEN_JSON_RPC=http://godwoken:8119
EOF

yarn workspace @godwoken-web3/godwoken tsc
yarn workspace @godwoken-web3/api-server reset_database
yarn workspace @godwoken-web3/api-server start
