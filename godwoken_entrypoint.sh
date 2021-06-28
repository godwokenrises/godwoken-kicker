#!/bin/bash

set -o errexit
set -o xtrace
PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
LUMOS_CONFIG_FILE=${PROJECT_DIR}/godwoken/deploy/lumos-config.json
GODWOKEN_CONFIG_TOML_FILE=${PROJECT_DIR}/godwoken/config.toml

export PRIVKEY=deploy/private_key
export CKB_RPC=http://ckb:8114
export POLYMAN_RPC=http://polyjuice:6102
export DATABASE_URL=postgres://user:password@postgres:5432/lumos

# detect which godwoken to start (prebuild version or local manual-build version)
if [ "$MANUAL_BUILD_GODWOKEN" = true ] ; then
  export GODWOKEN_BIN=${PROJECT_DIR}/godwoken/target/debug/godwoken
  export GW_TOOLS_BIN=${PROJECT_DIR}/godwoken/target/debug/gw-tools
else
  export GODWOKEN_BIN=godwoken
  export GW_TOOLS_BIN=gw-tools
fi

# import some helper function
source ${PROJECT_DIR}/gw_util.sh

# ready to start godwoken
cd ${PROJECT_DIR}/godwoken

# first, start ckb-indexer 
# todo: should remove to another service. but the port mapping some how not working.
RUST_LOG=error ckb-indexer -s ${PROJECT_DIR}/indexer-data/ckb-indexer-data -c ${CKB_RPC} -l 0.0.0.0:8116 > ${PROJECT_DIR}/indexer-data/indexer-log & 
 
# detect which mode to start godwoken
if test -f "$GODWOKEN_CONFIG_TOML_FILE"; then
  if [ "$FORCE_GODWOKEN_REDEPLOY" = true ]; then
    echo "godwoken config.toml exists, but force_godwoken_redeploy is enabled, so use fat mode."
    # fat start, re-deploy godwoken chain 
    export START_MODE="fat_start" 
  else
    echo "godwoken config.toml exists. try search rollup cell.."
    if isRollupCellExits "${GODWOKEN_CONFIG_TOML_FILE}";
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
  RUST_LOG=gw_block_producer=info,gw_generator=debug,info,gw_web3_indexer=debug,info $GODWOKEN_BIN
else
  echo 'run deploy mode'
fi

# ========= below: run godwoken in deploy mode ============

# === check and prepare for l1-sudt-script
wait_for_polyman_prepare_rpc "$POLYMAN_RPC"
callPolyman prepare_sudt_scripts "$POLYMAN_RPC"
# save lumos-config file with new l1-sudt-script config in godwoken folder
callPolyman get_lumos_config "$POLYMAN_RPC"
echo $call_result > $LUMOS_CONFIG_FILE
sed -i -e 's/{"status":"ok","data"://g' $LUMOS_CONFIG_FILE
sed -i -e 's/}}}}/}}}/g' $LUMOS_CONFIG_FILE
# update l1_sudt_script_hash in rollup-config.json file(if it exits) with lumos script.sudt.code_hash
codeHash=$(get_lumos_config_script_key_value SUDT CODE_HASH "$LUMOS_CONFIG_FILE")
set_key_value_in_json "l1_sudt_script_type_hash" $codeHash "deploy/rollup-config.json"

# deploy scripts
echo 'this may takes a little bit of time, please wait...'
$GW_TOOLS_BIN deploy-scripts -r ${CKB_RPC} -i deploy/scripts-deploy.json -o deploy/scripts-deploy-result.json -k ${PRIVKEY}

# deploy genesis block
$GW_TOOLS_BIN deploy-genesis -r ${CKB_RPC} -d deploy/scripts-deploy-result.json -p deploy/poa-config.json -u deploy/rollup-config.json -o deploy/genesis-deploy-result.json -k ${PRIVKEY}

# generate config file
$GW_TOOLS_BIN generate-config -d ${DATABASE_URL} -r ${CKB_RPC} -g deploy/genesis-deploy-result.json -s deploy/scripts-deploy-result.json -p deploy/polyjuice-backend -o config.toml

# Update block_producer.wallet_config section to your own lock.
edit_godwoken_config_toml $GODWOKEN_CONFIG_TOML_FILE

# update l1_sudt_script_hash in config.toml file(if it exits) with lumos script.sudt.code_hash
codeHash=$(get_lumos_config_script_key_value SUDT CODE_HASH "$LUMOS_CONFIG_FILE")
set_key_value_in_toml "l1_sudt_script_type_hash" $codeHash "$GODWOKEN_CONFIG_TOML_FILE"
# update l1_sudt_dep info in config.toml file(if it exits) with lumos script.sudt.dep
depType=$(get_lumos_config_script_key_value SUDT DEP_TYPE "$LUMOS_CONFIG_FILE")
txHash=$(get_lumos_config_script_key_value SUDT TX_HASH "$LUMOS_CONFIG_FILE")
outpointIndex=$(get_lumos_config_script_key_value SUDT INDEX "$LUMOS_CONFIG_FILE")
update_godwoken_config_toml_with_l1_sudt_dep "$GODWOKEN_CONFIG_TOML_FILE" $depType $txHash $outpointIndex

# generate godwoken config file for polyjuice
callPolyman gen_config "$POLYMAN_RPC" 

cd ${PROJECT_DIR}/godwoken 

# start godwoken
RUST_LOG=gw_block_producer=info,gw_generator=debug,info,gw_web3_indexer=debug,info $GODWOKEN_BIN
