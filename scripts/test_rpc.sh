#!/bin/bash

echo -e "get_balance, type: contract address \n"

echo '{
    "id": 2,
    "jsonrpc": "2.0",
    "method": "eth_getBalance",
    "params":
        ["0x900c05b5d9cf8a9480810c2bd0f899f03020fd33"]

}' \
| tr -d '\n' \
| curl -H 'content-type: application/json' -d @- \
http://localhost:8024

echo -e "get_balance, type: eoa address \n"

echo '{
    "id": 2,
    "jsonrpc": "2.0",
    "method": "eth_getBalance",
    "params":
        ["0x768249aC5ED64517C96c16e26B7A5Aa3E9334217"]

}' \
| tr -d '\n' \
| curl -H 'content-type: application/json' -d @- \
http://localhost:8024

echo -e "get_transaction_receipt \n"

echo '{
    "id": 2,
    "jsonrpc": "2.0",
    "method": "eth_getTransactionReceipt",
    "params":
        ["0x955c04c857fa9d3c1d66ef155a496c2aac564381deba12b76a4fef01f5182d7c"]

}' \
| tr -d '\n' \
| curl -H 'content-type: application/json' -d @- \
http://localhost:8024

echo -e "get_script_hash, id: 5 \n"

echo '{
    "id": 2,
    "jsonrpc": "2.0",
    "method": "gw_get_script_hash",
    "params":
        ["0x5"]

}' \
| tr -d '\n' \
| curl -H 'content-type: application/json' -d @- \
http://localhost:8119

