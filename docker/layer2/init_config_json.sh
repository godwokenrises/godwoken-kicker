# please invoke this script in the project root dir
cd workspace/deploy

cat << EOF > scripts-deploy.json
{
  "programs": {
    "custodian_lock": "scripts/release/custodian-lock",
    "deposit_lock": "scripts/release/deposit-lock",
    "withdrawal_lock": "scripts/release/withdrawal-lock",
    "challenge_lock": "scripts/release/challenge-lock",
    "stake_lock": "scripts/release/stake-lock",
    "state_validator": "scripts/release/state-validator",
    "l2_sudt_validator": "scripts/release/sudt-validator",
    "meta_contract_validator": "scripts/release/meta-contract-validator",
    "eth_account_lock": "scripts/release/eth-account-lock",
    "tron_account_lock": "scripts/release/tron-account-lock",
    "polyjuice_validator": "scripts/release/polyjuice-validator",
    "eth_addr_reg_validator": "scripts/release/eth_addr_reg_validator"
  },
  "lock": {
    "code_hash": "0x0000000000000000000000000000000000000000000000000000000000000000",
    "hash_type": "data",
    "args": "0x"
  },
  "built_scripts": {
    "eth_account_lock": "scripts/release/eth-account-lock",
    "deposit_lock": "scripts/release/deposit-lock",
    "polyjuice_generator": "deploy/polyjuice-backend/polyjuice-generator.aot",
    "l2_sudt_validator": "scripts/release/sudt-validator",
    "meta_contract_validator": "scripts/release/meta-contract-validator",
    "custodian_lock": "scripts/release/custodian-lock",
    "l2_sudt_generator": "deploy/backend/sudt-generator",
    "challenge_lock": "scripts/release/challenge-lock",
    "meta_contract_generator": "deploy/backend/meta-contract-generator",
    "always_success": "scripts/release/always-success",
    "state_validator": "scripts/release/state-validator",
    "polyjuice_validator": "scripts/release/polyjuice-validator",
    "stake_lock": "scripts/release/stake-lock",
    "withdrawal_lock": "scripts/release/withdrawal-lock",
    "eth_addr_reg_generator": "deploy/polyjuice-backend/eth_addr_reg_generator",
    "eth_addr_reg_validator": "deploy/polyjuice-backend/eth_addr_reg_validator",
    "tron_account_lock": "scripts/release/tron-account-lock"
  }
}
EOF
