#!/bin/bash

set -o errexit
set -o xtrace
PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd ${PROJECT_DIR}/godwoken

# build godwoken
RUST_BACKTRACE=full cargo build


# prepare to some config files for godwoken chain
cp -r ${PROJECT_DIR}/config/scripts ${PROJECT_DIR}/godwoken/
mkdir -p deploy && cd deploy
cp ${PROJECT_DIR}/config/private_key private_key

# cp godwoken/c/ scripts to avoid build
cp  ${PROJECT_DIR}/config/meta-contract-validator  ${PROJECT_DIR}/godwoken/godwoken-script/c/build/
cp  ${PROJECT_DIR}/config/meta-contract-generator  ${PROJECT_DIR}/godwoken/godwoken-script/c/build/
cp  ${PROJECT_DIR}/config/sudt-validator  ${PROJECT_DIR}/godwoken/godwoken-script/c/build/
cp  ${PROJECT_DIR}/config/sudt-generator  ${PROJECT_DIR}/godwoken/godwoken-script/c/build/

# create scripts files
cat << EOF > scripts-deploy.json
{
  "programs": {
    "custodian_lock": "scripts/release/always-success",
    "deposition_lock": "scripts/release/always-success",
    "withdrawal_lock": "scripts/release/always-success",
    "challenge_lock": "scripts/release/always-success",
    "stake_lock": "scripts/release/always-success",
    "state_validator": "scripts/release/always-success",
    "l2_sudt_validator": "scripts/release/always-success",
    "meta_contract_validator": "scripts/release/always-success",
    "eth_account_lock": "scripts/release/always-success",
    "polyjuice_validator": "scripts/release/always-success",
    "state_validator_lock": "scripts/release/always-success",
    "poa_state": "scripts/release/always-success"
  },
  "lock": {
    "code_hash": "0x0000000000000000000000000000000000000000000000000000000000000000",
    "hash_type": "data",
    "args": "0x"
  }
}
EOF

cat << EOF > poa-config.json
{
  "poa_setup": {
    "identity_size": 4,
    "round_interval_uses_seconds": false,
    "identities": [
      "0x00000000",
      "0x00000000",
      "0x00000000",
      "0x00000000"
    ],
    "aggregator_change_threshold": 4,
    "round_intervals": 3,
    "subblocks_per_round": 1
  }
}
EOF

cat << EOF > rollup-config.json
{
  "l1_sudt_script_type_hash": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "burn_lock_hash": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "required_staking_capacity": 10000000000,
  "challenge_maturity_blocks": 5,
  "finality_blocks": 20,
  "reward_burn_rate": 50,
  "allowed_eoa_type_hashes": [
    "0xf0e03a329803bd033eae42e80c8cd6c6dc81b48afe9f4a630f27e78be54db14c"
  ]
}
EOF