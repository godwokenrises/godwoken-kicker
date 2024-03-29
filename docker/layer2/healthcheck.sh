#!/usr/bin/env bash

# Make sure that polyjuice-root-account have been created
cat -n /var/lib/layer2/config/polyjuice-root-account-id | egrep 1 \
|| exit 2

# Query whether a Godwoken readonly node is ready to serve
# see: https://github.com/godwokenrises/godwoken/pull/644
echo '{
  "id": 42,
  "jsonrpc": "2.0",
  "method": "gw_get_mem_pool_state_ready",
  "params": []
}' \
| tr -d '\n' \
| curl --silent -H 'content-type: application/json' -d @- \
http://127.0.0.1:8119 \
| awk 'BEGIN { FS=":"; RS="," }; { if ($1 == "\"result\"") {print $2} }' \
| egrep true || exit 1
