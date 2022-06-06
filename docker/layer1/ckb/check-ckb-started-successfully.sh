#!/bin/bash

while true; do
    sleep 1

    echo '{
        "id": 2,
        "jsonrpc": "2.0",
        "method": "get_tip_block_number",
        "params": []
    }' \
    | tr -d '\n' \
    | curl -H 'content-type: application/json' -d @- \
    http://ckb:8114

    if [ $? -eq 0 ]; then
        break
    fi
done

exit 0
