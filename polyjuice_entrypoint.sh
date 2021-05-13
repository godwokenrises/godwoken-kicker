#!/bin/bash
# TODO: delete this file

set -o errexit
set -o xtrace
PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

export TOP=${PROJECT_DIR}/config

# cd ${PROJECT_DIR}/godwoken-examples
# yarn workspace @godwoken-examples/runner clean
# yarn workspace @godwoken-examples/runner start
# TODO: remove
# yarn prepare-money
# cd packages/runner
# yarn start