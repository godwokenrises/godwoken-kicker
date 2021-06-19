#!/bin/bash

echo -e "get_balance, id: 4 \n"

echo '{
    "id": 2,
    "jsonrpc": "2.0",
    "method": "get_balance",
    "params":
        ["0x4", "0x1"]

}' \
| tr -d '\n' \
| curl -H 'content-type: application/json' -d @- \
http://localhost:8119

echo -e "get_transaction_receipt \n"

echo '{
    "id": 2,
    "jsonrpc": "2.0",
    "method": "get_transaction_receipt",
    "params":
        ["0xe04ed3c8472191743290c52dec09ffb140a7f4b15861b41c944ef21a8ef46780"]

}' \
| tr -d '\n' \
| curl -H 'content-type: application/json' -d @- \
http://localhost:8119

echo -e "get_script_hash, id: 5 \n"

echo '{
    "id": 2,
    "jsonrpc": "2.0",
    "method": "get_script_hash",
    "params":
        ["0x5"]

}' \
| tr -d '\n' \
| curl -H 'content-type: application/json' -d @- \
http://localhost:8119

echo -e "get_account_id \n"

echo '{
    "id": 2,
    "jsonrpc": "2.0",
    "method": "get_account_id_by_script_hash",
    "params":
        ["0x683372fdc69ec9745102199529a39dc53d3e9f38fdd1665725d87e3743b01929"]

}' \
| tr -d '\n' \
| curl -H 'content-type: application/json' -d @- \
http://localhost:8119

