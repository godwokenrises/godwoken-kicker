#!/bin/bash

CONF=config.toml

set_key_value() {
    local key=${1}
    local value=${2}
    if [ -n $value ]; then
        #echo $value
        local current=$(sed -n -e "s/^\($key = '\)\([^ ']*\)\(.*\)$/\2/p" $CONF) # value带单引号
        if [ -n $current ];then
            echo "setting $CONF : $key = $value"
            value="$(echo "${value}" | sed 's|[&]|\\&|g')"
            sed -i "s|^[#]*[ ]*${key}\([ ]*\)=.*|${key} = '${value}'|" ${CONF}
        fi
    fi
}


set_key_value "privkey_path" "deploy/private_key"

# delete the default lock
sed -i '/\[block_producer.wallet_config.lock\]/{n;d}' $CONF 
sed -i '/\[block_producer.wallet_config.lock\]/{n;d}' $CONF 
sed -i '/\[block_producer.wallet_config.lock\]/{n;d}' $CONF 

# add new lock
sed -i "/\[block_producer.wallet_config.lock\]/a\code_hash = '0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8'" $CONF 
sed -i "/\[block_producer.wallet_config.lock\]/a\hash_type = 'type'" $CONF 
sed -i "/\[block_producer.wallet_config.lock\]/a\args = '0x43d509d97f26007a285f39241cffcd411157196c'" $CONF 