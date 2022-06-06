#!/usr/bin/env bash

# Check configuration files have created
if [ ! -f "/var/lib/layer2/config/scripts-deployment.json" ]; then
    exit 3
fi
if [ ! -f "/var/lib/layer2/config/godwoken-config.toml" ]; then
    exit 2
fi

echo '{
  "id": 42,
  "jsonrpc": "2.0",
  "method": "gw_get_mem_pool_state_root",
  "params": []
}' \
| tr -d '\n' \
| curl --silent -H 'content-type: application/json' -d @- \
http://127.0.0.1:8119 \
| awk 'BEGIN { FS=":"; RS="," }; { if ($1 == "\"result\"") {print $2} }' \
| egrep "0x.*" || exit 1
