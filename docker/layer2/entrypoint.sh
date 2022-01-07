#!/bin/bash

set -o errexit

PROJECT_DIR="/code"
LUMOS_CONFIG_FILE=${PROJECT_DIR}/workspace/deploy/lumos-config.json
GODWOKEN_CONFIG_TOML_FILE=${PROJECT_DIR}/workspace/config.toml

export PRIVKEY=deploy/private_key
export CKB_RPC=http://ckb:8114
export INDEXER_RPC=http://indexer:8116
export POLYMAN_RPC=http://call-polyman:6102
export DATABASE_URL=postgres://user:password@postgres:5432/lumos

export GODWOKEN_BIN=${PROJECT_DIR}/workspace/bin/godwoken
export GW_TOOLS_BIN=${PROJECT_DIR}/workspace/bin/gw-tools

function runGodwoken(){
  # wait for ckb rpc server to start
  while true; do
      sleep 0.2;
      if isCkbRpcRunning "${CKB_RPC}";
      then
        break;
      else echo "keep waitting for ckb rpc..."
      fi
  done
  # running godwoken
  RUST_LOG=info,gw_mem_pool=trace,gw_block_producer=info,gw_generator=debug,gw_web3_indexer=debug $GODWOKEN_BIN
}

# import some helper function
source ${PROJECT_DIR}/gw_util.sh

# ready to start godwoken
cd ${PROJECT_DIR}/workspace
 
# detect which mode to start godwoken
if test -f "$GODWOKEN_CONFIG_TOML_FILE"; then
  if [ "$FORCE_GODWOKEN_REDEPLOY" = true ]; then
    echo "godwoken config.toml exists, but force_godwoken_redeploy is enabled, so use fat mode."
    # fat start, re-deploy godwoken chain 
    export START_MODE="fat_start" 
  else
    echo "godwoken config.toml exists. try search rollup cell.."
    if isRollupCellExits "${GODWOKEN_CONFIG_TOML_FILE}" "${INDEXER_RPC}";
    then
      # slim start, just start godwoken, no re-deploy scripts
       export START_MODE="slim_start" 
    else
      # fat start, re-deploy godwoken chain 
      export START_MODE="fat_start"
    fi
  fi
else 
  export START_MODE="fat_start"
fi

if [ $START_MODE = "slim_start" ]; then
  runGodwoken
  echo "Godwoken stopped!"
  exit 125
else
  echo 'run deploy mode'
fi

# ========= below: run godwoken in deploy mode ============

# === check and prepare for l1-sudt-script
wait_for_polyman_prepare_rpc "$POLYMAN_RPC"
callPolyman "spilt_miner_cells?total_capacity=1000000000000000000&total_pieces=20" "$POLYMAN_RPC"
callPolyman prepare_sudt_scripts "$POLYMAN_RPC"
# save lumos-config file with new l1-sudt-script config in godwoken folder
callPolyman get_lumos_config "$POLYMAN_RPC"
echo $call_result > $LUMOS_CONFIG_FILE
sed -i -e 's/{"status":"ok","data"://g' $LUMOS_CONFIG_FILE
sed -i -e 's/}}}}/}}}/g' $LUMOS_CONFIG_FILE
# update l1_sudt_script_hash in rollup-config.json file(if it exits) with lumos script.sudt.code_hash
codeHash=$(get_lumos_config_script_key_value SUDT CODE_HASH "$LUMOS_CONFIG_FILE")
depType=$(get_lumos_config_script_key_value SUDT DEP_TYPE "$LUMOS_CONFIG_FILE")
txHash=$(get_lumos_config_script_key_value SUDT TX_HASH "$LUMOS_CONFIG_FILE")
outpointIndex=$(get_lumos_config_script_key_value SUDT INDEX "$LUMOS_CONFIG_FILE")

rollupConfig="
{
  \"l1_sudt_script_type_hash\": \"${codeHash}\",
  \"l1_sudt_cell_dep\": {
    \"dep_type\": \"code\",
    \"out_point\": {
      \"tx_hash\": \"${txHash}\",
      \"index\": \"${outpointIndex}\"
    }
  },
  \"cells_lock\": {
    \"code_hash\": \"0x49027a6b9512ef4144eb41bc5559ef2364869748e65903bd14da08c3425c0503\",
    \"hash_type\": \"type\",
    \"args\": \"0x0000000000000000000000000000000000000000\"
  },
  \"reward_lock\": {
    \"code_hash\": \"0x49027a6b9512ef4144eb41bc5559ef2364869748e65903bd14da08c3425c0503\",
    \"hash_type\": \"type\",
    \"args\": \"0x0000000000000000000000000000000000000001\"
  },
  \"burn_lock\": {
    \"code_hash\": \"0x0000000000000000000000000000000000000000000000000000000000000000\",
    \"hash_type\": \"data\",
    \"args\": \"0x\"
  },
  \"required_staking_capacity\": 10000000000,
  \"challenge_maturity_blocks\": 100,
  \"finality_blocks\": 100,
  \"reward_burn_rate\": 50,
  \"allowed_eoa_type_hashes\": []
}"

echo 'Generate deploy/rollup-config.json'
echo $rollupConfig > "deploy/rollup-config.json"

# deploy scripts
echo 'start deploying godwoken scripts, this might takes a little bit of time, please wait...'
#$GW_TOOLS_BIN deploy-scripts -r ${CKB_RPC} -i deploy/scripts-deploy.json -o deploy/scripts-deploy-result.json -k ${PRIVKEY}
deployGodwokenScripts 5 $POLYMAN_RPC "/code/workspace/deploy/scripts-deploy.json" "/code/workspace/deploy/scripts-deploy-result.json" 

# register tron lock to allow-eoa-type-hash in rollup-config.json
tronAccountLockTypeHash=$(jq -r ".tron_account_lock.script_type_hash" "deploy/scripts-deploy-result.json")
cat <<< $(jq -r '.allowed_eoa_type_hashes += ["'$tronAccountLockTypeHash'"]' "deploy/rollup-config.json") > "deploy/rollup-config.json" 

# deploy genesis block
$GW_TOOLS_BIN deploy-genesis --ckb-rpc ${CKB_RPC} --scripts-deployment-path deploy/scripts-deploy-result.json -p deploy/poa-config.json -r deploy/rollup-config.json -o deploy/genesis-deploy-result.json -k ${PRIVKEY}

# generate config file
$GW_TOOLS_BIN generate-config -d ${DATABASE_URL} --ckb-rpc ${CKB_RPC} --ckb-indexer-rpc ${INDEXER_RPC} -g deploy/genesis-deploy-result.json -r deploy/rollup-config.json --scripts-deployment-path deploy/scripts-deploy-result.json -k deploy/private_key -o config.toml -c deploy/scripts-deploy.json

# Update block_producer.wallet_config section to your own lock.
edit_godwoken_config_toml $GODWOKEN_CONFIG_TOML_FILE

# start godwoken
cd ${PROJECT_DIR}/workspace
runGodwoken

