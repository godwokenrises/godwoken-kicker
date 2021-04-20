#!/bin/bash

set -o errexit
set -o xtrace
PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd ${PROJECT_DIR}/godwoken

#apt update
# apt install curl -y
# apt install build-essential -y
# apt install g++ -y
# curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -y | sh 
# PATH=/root/.cargo/bin:$P

#g++ --version
#apt-cache policy libc6

#apt update
#apt install libgcc-s1 -y
#apt install libcrypt1 -y

#apt update
#apt install -y gcc
#apt --fix-broken install -y
#apt install aptitude -y 
#aptitude install g++ -y
#apt install g++
#ln -s /usr/lib/x86_64-linux-gnu /usr/lib64

#curl http://security.ubuntu.com/ubuntu/pool/main/g/gcc-10/libgcc-s1_10-20200411-0ubuntu1_amd64.deb --output libgcc-s1_10-20200411-0ubuntu1_amd64.deb && dpkg -i libgcc-s1_10-20200411-0ubuntu1_amd64.deb
#curl http://ftp.br.debian.org/debian/pool/main/g/glibc/libc6_2.31-11_amd64.deb --output libc6_2.31-11_amd64.deb && dpkg -i libc6_2.31-11_amd64.deb 
#apt-cache policy libc6

#sudo apt update


#sudo cargo install moleculec --version 0.6.1

#sudo apt-get --fix-broken -y install libunwind-dev

#sudo apt update && sudo apt -y upgrade
#cargo install moleculec --version 0.6.1
#export PATH=/root/.cargo/bin:$PATH
which cargo
#moleculec --version
moleculec --version
# build godwoken
RUST_BACKTRACE=full cargo build

# create scripts-deploy.json
mkdir -p deploy && cd deploy
cp -r ${PROJECT_DIR}/config/scripts scripts
cat << EOF > scripts-deploy.json
{
  "programs": {
    "custodian_lock": "/scripts/release/always-success",
    "deposition_lock": "/scripts/release/always-success",
    "withdrawal_lock": "/scripts/release/always-success",
    "challenge_lock": "/scripts/release/always-success",
    "stake_lock": "/scripts/release/always-success",
    "state_validator": "/scripts/release/always-success",
    "l2_sudt_validator": "/scripts/release/always-success",
    "meta_contract_validator": "/scripts/release/always-success",
    "eth_account_lock": "/scripts/release/always-success",
    "polyjuice_validator": "/scripts/release/always-success",
    "state_validator_lock": "/scripts/release/always-success",
    "poa_state": "/scripts/release/always-success"
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
