configfile=./godwoken/deploy/scripts-deploy-result.json
eth_account_lock_code_hash=$(jq -r '.eth_account_lock.script_type_hash' $configfile)
echo $eth_account_lock_code_hash


tomlconfigfile=./godwoken/config.toml
RollupTypeHash=$(awk -F'[ ="]+' '$1 == "rollup_type_hash" { print $2 }' $tomlconfigfile | sed 's/\x27//g') 
echo "$RollupTypeHash"
