#!/bin/bash

CALL_POLYMAN_URL=http://localhost:6102
POLYMAN_UI_URL=http://localhost:6100
GODWOKEN_RPC=http://localhost:8119

# 1. Create ProgressBar function
# 1.1 Input is currentState($1) and totalState($2)
function ProgressBar {
    # some naive color const
    RED=`tput setaf 1`
    GREEN=`tput setaf 2`
    NO_COLOR=`tput sgr0`
# Process data
    if [ ${#3} -gt 20 ]; then
        STR12="${3:0:20}.."
    else
        STR12="$3                    "         # 20 spaces here    
        STR12="${STR12:0:20}"
    fi

    let _progress=(${1}*100/${2}*100)/100
    let _done=(${_progress}*4)/10
    let _left=40-$_done
# Build progressbar string lengths
    _fill=$(printf "%${_done}s")
    _empty=$(printf "%${_left}s")

# 1.2 Build progressbar strings and print the ProgressBar line
# 1.2.1 Output example:                           
# 1.2.1.1 Progress : [########################################] 100%
    printf "\r${STR12}: ${GREEN}[${_fill// /#}${_empty// /-}] ${_progress}%%${NO_COLOR}"
}

# read_docker_logs docker-compose-path service-name how-many-last-logs-to-show
read_docker_logs(){
    _log=$(cd $1 && docker-compose logs --tail $3 $2 && cd ..)
    echo $_log
}

# usage:
#   checkLogsToSetProgress
checkLogsToSetProgress() {
    # some naive color const
    RED=`tput setaf 1`
    GREEN=`tput setaf 2`
    NO_COLOR=`tput sgr0`

    # This accounts as the "totalState" variable for the ProgressBar function
    _end=100

    # godwoken activity
    stage1_name="deploy sudt   " # should be 6 word length
    stage1_info="ready to call prepare_sudt_scripts with polyman.."
    stage1_number=5

    stage2_info="start deploying godwoken scripts, this might takes a little bit of time"
    stage2_name="deploy scripts"
    start_deploying_scripts="start deploying godwoken scripts now."
    stage2_number=10

    finishe_deploy_scripts="finish deploying godwoken scripts now."
 
    stage3_name="deploy_genesis"
    stage3_info="gw_tools::deploy_genesis] tx_hash"
    stage3_number=70

    stage4_name="produce block"
    stage4_info="gw_block_producer::runner"
    stage4_number=75
    # polyjuice activity
    stage5_name="create account"
    stage5_info="create deposit account.2"
    stage5_number=85

    stage6_name="create creator"
    stage6_info="create creator account => 0x3"
    stage6_number=95

    polyjuice_wait_to_start_info="godwoken rpc server is down."

    while true
    do
        # if two rpc is up and all set.
        if isPolymanUIRunning "${POLYMAN_UI_URL}" &> /dev/null && isGodwokenRpcRunning "${GODWOKEN_RPC}" &> /dev/null; then
          ProgressBar ${_end} ${_end} "All Jobs Done"
          show_success_finish_info 
          break;
        fi

        # if one of service from docker-compose is not Up, then throw error.
        if !(check_service_status "godwoken" &> /dev/null); then
            echo "${RED}Godwoken service is not running. please run 'make sg' to check what happend.${NO_COLOR}"
            break;
        fi

        if !(check_service_status "polyjuice" &> /dev/null); then
            echo "${RED}polyjuice service is not running. please run 'make sp' to check what happend.${NO_COLOR}"
            break;
        fi

        if !(check_service_status "call-polyman" &> /dev/null); then
            echo "${RED}call-polyman(a setup-service) is not running. please run 'make call-polyman' to check what happend.${NO_COLOR}"
            break;
        fi

        # monitor Godwoekn service logs to display progress info.
        if isGodwokenRpcRunning "${GODWOKEN_RPC}" &> /dev/null; then
            :
        else
            _log=$(read_docker_logs ./docker godwoken 20)

            if [[  $_log =~ "$stage1_info" ]] && [[  $_log != *"$stage2_info"* ]]; then
                ProgressBar "$stage1_number" ${_end} "$stage1_name"
            fi

            # monitor call-polyman service logs to diplay scripts deployment progress info
            _c_poly_log=$(read_docker_logs ./docker call-polyman 5)
            total_progress_regex='(total_progress: )([^,]*)';
            percentage_progress_regex='(percentage: )([^,]*)';

            if [[ $_log =~ $stage2_info ]] && [[ $_c_poly_log != *"successful deployed script: "* ]]; then
                ProgressBar "$stage2_number" ${_end} "$stage2_name"
            fi

            if [[ $_c_poly_log =~ $total_progress_regex ]] && [[ $_log != *"$stage3_info"* ]] && [[ $_log != *"$stage4_info"* ]]; then
                p_number="scripts(${BASH_REMATCH[2]})"
                if [[ $_c_poly_log =~ $percentage_progress_regex ]]; then
                    p_percentage=${BASH_REMATCH[2]}
                    ProgressBar $p_percentage ${_end} $p_number
                fi
            fi

            if [[  $_log =~ "$stage3_info" ]]; then
                ProgressBar "$stage3_number" ${_end} "$stage3_name"
            fi

            if [[  $_log =~ "$stage4_info" ]]; then
                ProgressBar "$stage4_number" ${_end} "$stage4_name"
            fi
        fi

        # monitor Polyjuice service logs to display progress info.
        if isPolymanUIRunning "${POLYMAN_UI_URL}" &> /dev/null; then
            :
        else
            _poly_log=$(read_docker_logs ./docker polyjuice 50)
            if [[  $_poly_log =~ "$stage5_info" ]] && [[ $_poly_log != *"$polyjuice_wait_to_start_info"* ]]; then
                ProgressBar "$stage5_number" ${_end} "$stage5_name"
            fi

            if [[  $_poly_log =~ "$stage6_info" ]] && [[ $_poly_log != *"$polyjuice_wait_to_start_info"* ]]; then
                ProgressBar "$stage6_number" ${_end} "$stage6_name"
            fi
        fi

        sleep 2
    done
}

show_wait_tips(){
    # some naive color const
    RED=`tput setaf 1`
    GREEN=`tput setaf 2`
    NO_COLOR=`tput sgr0`

    content="
Run commands to monitor background activities: ${GREEN}

    make sg (Godwoken)
    make sp (Polyjuice)
    make web3 (web3)
    make call-polyman (setup service)
${NO_COLOR}
"
    printf "$content"

    printf "Note: this might takes couple minutes to finish.."
    checkLogsToSetProgress
}

show_success_finish_info(){
    # some naive color const
    RED=`tput setaf 1`
    GREEN=`tput setaf 2`
    NO_COLOR=`tput sgr0`

    echo ""
    echo ""
    printf "Great! Checkout${GREEN} ${POLYMAN_UI_URL} ${NO_COLOR}to deploy contract!"
    echo ""
    echo ""
}

check_service_status(){
    if [[ -n $1 ]]; 
    then
        local service="$1"
    else
        local service="godwoken"
    fi
    result=$(cd docker && docker-compose ps "$service")
    if [[ $result =~ "   Up   " ]]; then
        echo "$service Service is up and running!"
        # 0 equals true
        return 0
    else
        echo "$service rpc server is down/paused/exits."
        # 1 equals false
        return 1
    fi
}

# how to use: 
#    parese_toml_with_section file_path section_name key_name
parse_toml_with_section(){
    [[ -f $1 ]] || { echo "$1 is not a file." >&2;return 1;}
    local -n config_array=config
    [[ -n $2 ]] || { echo "pleas pass your interested section name as second variable!";}
    if [[ -n $3 ]]; then 
        key_name="$3"
    else
        echo "pleas pass your interested key name as third variable!";
    fi
    declare -Ag ${!config_array} || return 1
    local line key value section_regex entry_regex interested_section_array
    section_regex="^[[:blank:]]*\[([[:alpha:]_][[:alnum:]/._-]*)\][[:blank:]]*(#.*)?$"
    entry_regex="^[[:blank:]]*([[:alpha:]_][[:alnum:]_]*)[[:blank:]]*=[[:blank:]]*('[^']+'|\"[^\"]+\"|[^#[:blank:]]+)[[:blank:]]*(#.*)*$"
    while read -r line
    do
        [[ -n $line ]] || continue
        [[ $line =~ $section_regex ]] && {
            local -n config_array=${BASH_REMATCH[1]//\./\_} # if section name contains ".", replace it with "_" for naming.
            if [[ ${BASH_REMATCH[1]} =~ $2 ]]; then 
               interested_section_array="$BASH_REMATCH"
            else
               continue 
            fi
            declare -Ag ${!config_array} || return 1
            continue
        }
        [[ $line =~ $entry_regex ]] || continue
        key=${BASH_REMATCH[1]}
        value=${BASH_REMATCH[2]#[\'\"]} # strip quotes
        value=${value%[\'\"]}
        config_array["${key}"]="${value}"
    done < "$1"
    declare -n array="${interested_section_array//\./\_}"
    echo ${array[$key_name]}
}

isRollupCellExits(){
    if [[ -n $1 ]]; 
    then
        local tomlconfigfile="$1"
    else
        local tomlconfigfile="/code/workspace/config.toml"
    fi

    if [[ -n $2 ]];
    then
        local indexer_rpc="$2"
    else
        local indexer_rpc="http://localhost:8116"
    fi

    rollup_code_hash=$( parse_toml_with_section "$tomlconfigfile" "chain.rollup_type_script" "code_hash" )
    rollup_hash_type=$( parse_toml_with_section "$tomlconfigfile" "chain.rollup_type_script" "hash_type" )
    rollup_args=$( parse_toml_with_section "$tomlconfigfile" "chain.rollup_type_script" "args" )

    # curl retry on connrefused, considering ECONNREFUSED as a transient error(network issues)
    # connections with ipv6 are not retried because it returns EADDRNOTAVAIL instead of ECONNREFUSED,
    # hence we should use --ipv4
    result=$( echo '{
    "id": 2,
    "jsonrpc": "2.0",
    "method": "get_cells",
    "params": [
        {
            "script": {
                "code_hash": "'${rollup_code_hash}'",
                "hash_type": "'${rollup_hash_type}'",
                "args": "'${rollup_args}'"
            },
            "script_type": "type"
        },
        "asc",
        "0x64"
    ]
    }' \
    | tr -d '\n' \
    | curl -s --ipv4 --retry 3 --retry-connrefused \
    -H 'content-type: application/json' -d @- \
    $indexer_rpc)

    if [[ $result =~ "block_number" ]]; then
        echo "Rollup cell exits!"
        # 0 equals true
        return 0
    else
        echo "can not found Rollup cell!"
        # 1 equals false
        return 1
    fi
}

isCkbRpcRunning(){
    if [[ -n $1 ]]; 
    then
        local rpc_url="$1"
    else
        local rpc_url="http://localhost:8114"
    fi

    result=$( echo '{
    "id": 2,
    "jsonrpc": "2.0",
    "method": "ping",
    "params": []
    }' \
    | tr -d '\n' \
    | curl -s --ipv4 \
    -H 'content-type: application/json' -d @- \
    $rpc_url)

    if [[ $result =~ "pong" ]]; then
        echo "ckb rpc server is up and running!"
        # 0 equals true
        return 0
    else
        echo "ckb rpc server is down."
        # 1 equals false
        return 1
    fi
}

isGodwokenRpcRunning(){
    if [[ -n $1 ]]; 
    then
        local rpc_url="$1"
    else
        local rpc_url="http://localhost:8119"
    fi

    # curl retry on connrefused, considering ECONNREFUSED as a transient error(network issues)
    # connections with ipv6 are not retried because it returns EADDRNOTAVAIL instead of ECONNREFUSED,
    # hence we should use --ipv4
    result=$( echo '{
    "id": 2,
    "jsonrpc": "2.0",
    "method": "gw_ping",
    "params": []
    }' \
    | tr -d '\n' \
    | curl -s --ipv4 --retry 3 --retry-connrefused \
    -H 'content-type: application/json' -d @- \
    $rpc_url)

    if [[ $result =~ "pong" ]]; then
        echo "godwoken rpc server is up and running!"
        # 0 equals true
        return 0
    else
        echo "godwoken rpc server is down."
        # 1 equals false
        return 1
    fi
}

isPolymanPrepareRpcRunning(){
    if [[ -n $1 ]]; 
    then
        local rpc_url="$1"
    else
        local rpc_url="http://localhost:6102"
    fi

    # curl retry on connrefused, considering ECONNREFUSED as a transient error(network issues)
    # connections with ipv6 are not retried because it returns EADDRNOTAVAIL instead of ECONNREFUSED,
    # hence we should use --ipv4
    result=$(curl -s --ipv4 $rpc_url/ping)

    if [[ $result =~ "pong" ]]; then
        echo "polyman prepare rpc server is up and running!"
        # 0 equals true
        return 0
    else
        echo "polyman prepare rpc server is down."
        # 1 equals false
        return 1
    fi
}

isPolymanUIRunning(){
    if [[ -n $1 ]]; 
    then
        local rpc_url="$1"
    else
        local rpc_url="http://localhost:6100"
    fi

    # curl retry on connrefused, considering ECONNREFUSED as a transient error(network issues)
    # connections with ipv6 are not retried because it returns EADDRNOTAVAIL instead of ECONNREFUSED,
    # hence we should use --ipv4
    result=$(curl -s --ipv4 $rpc_url)

    if [[ $result =~ "<!doctype html>" ]]; then
        echo "polyman UI is up and running!"
        # 0 equals true
        return 0
    else
        echo "polyman UI is down."
        # 1 equals false
        return 1
    fi
}

isWeb3RpcRunning(){
    if [[ -n $1 ]]; 
    then
        local rpc_url="$1"
    else
        local rpc_url="http://localhost:8024"
    fi

    # curl retry on connrefused, considering ECONNREFUSED as a transient error(network issues)
    # connections with ipv6 are not retried because it returns EADDRNOTAVAIL instead of ECONNREFUSED,
    # hence we should use --ipv4
    result=$( echo '{
    "id": 2,
    "jsonrpc": "2.0",
    "method": "net_listening",
    "params": []
    }' \
    | tr -d '\n' \
    | curl -s --ipv4 --retry 3 --retry-connrefused \
    -H 'content-type: application/json' -d @- \
    $rpc_url)

    if [[ $result =~ "true" ]]; then
        echo "web3 rpc server is up and running!"
        # 0 equals true
        return 0
    else
        echo "web3 rpc server is down."
        # 1 equals false
        return 1
    fi
}

# set key value in toml config file
# how to use: set_key_value_in_toml key value your_toml_config_file
set_key_value_in_toml() {
    if [[ -f $3 ]];
    then echo 'found toml file.'
    else
        echo "${3} file not exits, skip this steps."
        return 0
    fi


    local key=${1}
    local value=${2}
    if [ -n $value ]; then
        #echo $value
        local current=$(sed -n -e "s/^\($key = '\)\([^ ']*\)\(.*\)$/\2/p" $3) # value带单引号
        if [ -n $current ];then
            echo "setting $3 : $key = $value"
            value="$(echo "${value}" | sed 's|[&]|\\&|g')"
            sed -i "s|^[#]*[ ]*${key}\([ ]*\)=.*|${key} = '${value}'|" ${3}
        fi
    fi
}

# set key value in json config file
# how to use: set_key_value_in_json key value your_json_config_file
set_key_value_in_json() {
    if [[ -f $3 ]];
    then echo 'found json file.'
    else
        echo "${3} file not exits, skip this steps."
        return 0
    fi


    local key=${1}
    local value=${2}
    if [ -n $value ]; then
        # echo $value
        local current=$(sed -n -e "s/^\s*\(\"$key\": \"\)\([^ \"]*\)\(.*\)$/\2/p" $3) # value带双引号
        if [ -n $current ];then
            echo "setting $3 : $key: $value"
            value="$(echo "${value}" | sed 's|[&]|\\&|g')"
            sed -i "s|^[#]*[ ]*\"${key}\"\([ ]*\):.*|  \"${key}\": \"${value}\",|" ${3}
        fi
    fi
}

# usage:
#  get_lumos_config_script_key_value <scripts_name> <key_name> <lumos-config.json file path>
get_lumos_config_script_key_value(){
    if [[ ! -n $1 ]]; 
    then
        echo 'provide your interested scripts(like SUDT/SECP256K1_BLAKE160)! abort.'
        return 1
    fi

    if [[ ! -n $2 ]]; 
    then
        echo 'provide your interested key name(like CODE_HASH/TX_HASH)! abort.'
        return 2
    fi

    if [[ -n $3 ]]; 
    then
        local lumosconfigfile="$3"
    else
        local lumosconfigfile="/code/godwoken-polyman/packages/runner/configs/lumos-config.json"
    fi
    
    echo "$(cat $lumosconfigfile)" | grep -Pzo ''$1'[^}]*'$2'":[\s]*"\K[^"]*'
}
 
# usage: prepare_package name url checkout
# if package folder exits and the git remote url is the same, will not remove and re-clone
prepare_package(){
    # if subpackage folder is empty
    if [[ -d "packages/$1" ]]; then
       cd packages/$1 
       url=$(git remote get-url origin)
       cd ../..
       if [[ $url == $2 ]]; then
          if [[ "$ALWAYS_FETCH_NEW_PACKAGE" = true ]]; then
            cd packages/$1 && git fetch --all && git pull origin $(git rev-parse --abbrev-ref HEAD) && git checkout $3 && cd ../.. || reclone_repo_if_checkout_failed $1 $2 $3 ;
          else
            cd packages/$1 && git checkout $3 && cd ../.. || reclone_repo_if_checkout_failed $1 $2 $3 ;
          fi  
       else rm -rf packages/$1 && pull_code_from_url $1 $2 $3
       fi
    else pull_code_from_url $1 $2 $3
    fi
}

# usage: pull_code_from_url name url checkout 
pull_code_from_url(){
    cd packages && git clone --recursive $2 && cd $1 && git checkout $3 && cd ../../
}

get_git_remote_url(){
    url=$(git remote get-url origin)
}

reclone_repo_if_checkout_failed(){
    cd ../.. && rm -rf packages/$1 && pull_code_from_url $1 $2 $3
}

remove_dummy_docker_if_exits(){
    [ "$(docker ps -a | grep dummy)" ] && docker rm -f dummy || :
}

edit_godwoken_config_toml(){
    if [[ -f $1 ]];
    then echo 'found config.toml file.'
    else
        echo "${1} file not exits, skip this steps."
        return 0
    fi
    
    set_key_value_in_toml "node_mode" "fullnode" $1

    set_key_value_in_toml "privkey_path" "deploy/private_key" $1
    set_key_value_in_toml "listen" "0.0.0.0:8119" $1

    ## set store path
    # delete the default path
    sed -i '/\[store\]/{n;d}' $1
    # add an new path
    sed -i "/\[store\]/a\path = '../cache/activity/godwoken-chain-data'" $1

    ## 1. reward lock update
    # delete the default reward lock
    sed -i '/\[block_producer.challenger_config.rewards_receiver_lock\]/{n;d}' $1 
    sed -i '/\[block_producer.challenger_config.rewards_receiver_lock\]/{n;d}' $1 
    sed -i '/\[block_producer.challenger_config.rewards_receiver_lock\]/{n;d}' $1 
    # add an new one with your own lock
    sed -i "/\[block_producer.challenger_config.rewards_receiver_lock\]/a\code_hash = '0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8'" $1 
    sed -i "/\[block_producer.challenger_config.rewards_receiver_lock\]/a\hash_type = 'type'" $1
    sed -i "/\[block_producer.challenger_config.rewards_receiver_lock\]/a\args = '0x74e5c89172c5d447819f1629743ef2221df083be'" $1

    ## 2. miner wallet lock
    # delete the default wallet lock
    sed -i '/\[block_producer.wallet_config.lock\]/{n;d}' $1 
    sed -i '/\[block_producer.wallet_config.lock\]/{n;d}' $1 
    sed -i '/\[block_producer.wallet_config.lock\]/{n;d}' $1 
    # add an new one with your own lock
    sed -i "/\[block_producer.wallet_config.lock\]/a\code_hash = '0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8'" $1 
    sed -i "/\[block_producer.wallet_config.lock\]/a\hash_type = 'type'" $1
    sed -i "/\[block_producer.wallet_config.lock\]/a\args = '0x43d509d97f26007a285f39241cffcd411157196c'" $1
}

# check if polyman prepare rpc is running
# usage:
#   wait_for_polyman_prepare_rpc <rpc url> 
wait_for_polyman_prepare_rpc(){
    while true; do
        sleep 3;
        if isPolymanPrepareRpcRunning $1;
        then
          break;
        else echo "keep waitting..."
        fi
    done
}

# call polyman via prepare-rpc server
#   do things like:
#       * prepare sudt scriptws
#       * prepare money
# usage:
#   callPolyman <command_router> <rpc_url>
callPolyman(){
    if [[ -n $1 ]]; 
    then
        echo "ready to call $1 with polyman.."
    else 
        echo 'please pass command_router args to call polyman. abort.'
        return 2;
    fi
    
    if [[ -n $2 ]]; 
    then
        local rpc_url="$2"
    else
        local rpc_url="http://localhost:6102"
    fi

    # curl retry on connrefused, considering ECONNREFUSED as a transient error(network issues)
    # connections with ipv6 are not retried because it returns EADDRNOTAVAIL instead of ECONNREFUSED,
    # hence we should use --ipv4
    result=$(curl -s --ipv4 --retry 3 --retry-connrefused \
                    $rpc_url/$1)
    if [[ $result =~ '"status":"ok"' ]]; then
        echo "$1 finished"
        call_result=$result
    else
        echo "failed to call polyman $1."
        # 1 equals false
        return 1
    fi
}

# usage:
#   deployGodwokenScripts retry_limit rpc_url scripts_file_path deploy_result_file_path 
deployGodwokenScripts(){
    if [[ -n $1 ]]; 
    then
        local retryLimit=$1;
    else 
        local retryLimit=5; # default retry 5 times max
    fi
    local count=0;
    while [ $retryLimit -gt $count ]; do
        sleep 3;
        ((count=count+1))
        result=$(curl -s --ipv4 --retry 3 --retry-connrefused --max-time 300 "$2/deploy_godwoken_scripts?scripts_file_path=$3&deploy_result_file_path=$4")
        if [[ $result =~ '"status":"ok"' ]];
        then
          echo $result && break;
        else echo "deploy failed, retry {$count}th time.."
        fi
    done
}

# usage:
#   update_godwoken_config_toml_with_l1_sudt_dep <config.toml file> <dep_type> <tx_hash> <index>
update_godwoken_config_toml_with_l1_sudt_dep(){
    if [[ -f $1 ]];
    then echo 'found config.toml file.'
    else
        echo "${1} file not exits, skip this steps."
        return 0
    fi

    if [[ -n $2 ]];
    then echo "dep_type: $2"
    else
        echo "dep_tpe not supported. abort."
        return 1
    fi

    if [[ -n $3 ]];
    then echo "tx_hash: $3"
    else
        echo "tx_hash not supported. abort."
        return 2
    fi

    if [[ -n $4 ]];
    then echo "tx_hash index: $4"
    else
        echo "tx_hash index not supported. abort."
        return 3
    fi

    # delete the default l1_sudt_type_dep
    sed -i '/\[block_producer.l1_sudt_type_dep\]/{n;d}' $1 
    # add an new one
    sed -i "/\[block_producer.l1_sudt_type_dep\]/a\dep_type = '$2'" $1

    # delete the default l1_sudt_type_dep.out_point
    sed -i '/\[block_producer.l1_sudt_type_dep.out_point\]/{n;d}' $1 
    sed -i '/\[block_producer.l1_sudt_type_dep.out_point\]/{n;d}' $1 
    # add an new one
    sed -i "/\[block_producer.l1_sudt_type_dep.out_point\]/a\index = '$4'" $1
    sed -i "/\[block_producer.l1_sudt_type_dep.out_point\]/a\tx_hash = '$3'" $1
}

# usage:
#   wait_for_address_got_suffice_money <ckb_rpc> <address> <minimal money threshold, unit: kb>
wait_for_address_got_suffice_money(){

    if [[ -n $1 ]];
    then echo "use ckb_rpc: $1"
    else
        echo "ckb_rpc not provided. abort."
        return 1
    fi

    if [[ -n $2 ]];
    then echo "use address: $2"
    else
        echo "address not provided. abort."
        return 2
    fi

    if [[ -n $3 ]];
    then echo "use threshold: $3"
    else
        echo "minimal money threshold not provided. abort."
        return 3
    fi

    while true; do
        sleep 3;
        MINER_BALANCE=$(ckb-cli --url $1 wallet get-capacity --wait-for-sync --address $2)
        TOTAL="${MINER_BALANCE##immature*:}"
        TOTAL="${TOTAL##total: }"
        TOTAL=" ${TOTAL%%.*} "
        if [[ "$TOTAL" -gt $3 ]]; then
          echo 'fund suffice, ready to deploy godwoken script.'
          break
        else
          echo 'fund unsuffice ${TOTAL}, keep waitting.'
        fi
    done
}

cargo_build_local_or_docker(){
    if [[ "$BUILD_GODWOKEN_ON_LOCAL_OVER_DOCKER" = true ]]; then
        echo "build Godwoken on local"
        cd packages/godwoken && cargo build --release && cd ../..
    else
        echo "build Godwoken via Docker"
        ## decide how to pass proxy host to docker 
        ## according to differen docker version
        ## see: https://stackoverflow.com/questions/24319662/from-inside-of-a-docker-container-how-do-i-connect-to-the-localhost-of-the-mach
        if [[ $(docker -v) != *20.10.* ]] && [[ "$OSTYPE" == "linux-gnu"* ]]; then
            echo 'Docker version not 20.10.0+!'
            docker run --rm -i --network="host" -v `pwd`/packages/godwoken:/app -v `pwd`/docker/layer2/cargo:/.cargo/ -v `pwd`/cache/build/cargo-registry:/root/.cargo/registry -w=/app "$DOCKER_MANUAL_BUILD_IMAGE_NAME":"$DOCKER_MANUAL_BUILD_IMAGE_TAG" cargo build --release ;
            return 0;
        fi

        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            echo "linux-gnu"
            docker run --rm -i --add-host host.docker.internal:host-gateway -v `pwd`/packages/godwoken:/app -v `pwd`/docker/layer2/cargo:/.cargo/ -v `pwd`/cache/build/cargo-registry:/root/.cargo/registry -w=/app "$DOCKER_MANUAL_BUILD_IMAGE_NAME":"$DOCKER_MANUAL_BUILD_IMAGE_TAG" cargo build --release;
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            # Mac OSX
            echo "mac osx"
            docker run --rm -i -v `pwd`/packages/godwoken:/app -v `pwd`/docker/layer2/cargo:/.cargo/ -v `pwd`/cache/build/cargo-registry:/root/.cargo/registry -w=/app "$DOCKER_MANUAL_BUILD_IMAGE_NAME":"$DOCKER_MANUAL_BUILD_IMAGE_TAG" cargo build --release;
        elif [[ "$OSTYPE" == "cygwin" ]]; then
            echo "windows"
            # POSIX compatibility layer and Linux environment emulation for Windows
            docker run --rm -i -v `pwd`/packages/godwoken:/app -v `pwd`/docker/layer2/cargo:/.cargo/ -v `pwd`/cache/build/cargo-registry:/root/.cargo/registry -w=/app "$DOCKER_MANUAL_BUILD_IMAGE_NAME":"$DOCKER_MANUAL_BUILD_IMAGE_TAG" cargo build --release;
        elif [[ "$OSTYPE" == "msys" ]]; then
            # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
            echo "windows"
            docker run --rm -i -v `pwd`/packages/godwoken:/app -v `pwd`/docker/layer2/cargo:/.cargo/ -v `pwd`/cache/build/cargo-registry:/root/.cargo/registry -w=/app "$DOCKER_MANUAL_BUILD_IMAGE_NAME":"$DOCKER_MANUAL_BUILD_IMAGE_TAG" cargo build --release;
        fi
    fi
}
