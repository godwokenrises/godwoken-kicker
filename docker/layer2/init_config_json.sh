# please invoke this script in the project root dir
cd godwoken/deploy

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
    "eth_account_lock": "scripts/release/always-success",
    "tron_account_lock": "scripts/release/always-success",
    "polyjuice_validator": "scripts/release/polyjuice-validator",
    "state_validator_lock": "scripts/release/poa",
    "poa_state": "scripts/release/state"
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
    "identity_size": 1,
    "round_interval_uses_seconds": true,
    "identities": [
      "0x3bab60cef4af81a87b0386f29bbf1dd0f6fe71c9fe1d84ca37096a6284d3bdaf"
    ],
    "aggregator_change_threshold": 1,
    "round_intervals": 24,
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
  ],
  "compatible_chain_id": 1
}
EOF
