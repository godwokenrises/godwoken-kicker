#!/bin/bash

echo -e "get_script_hash, id: 3 \n"

echo '{
    "id": 2,
    "jsonrpc": "2.0",
    "method": "get_script_hash",
    "params":
        ["0x2"]

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

echo -e "get_script_hash, id: 8 \n"

echo '{
    "id": 2,
    "jsonrpc": "2.0",
    "method": "get_script_hash",
    "params":
        ["0x8"]

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
        ["0x572ea72cc258439d6e5d1691d92fd4cffe3ece856b85f72f6ae5dc8498d7814f"]

}' \
| tr -d '\n' \
| curl -H 'content-type: application/json' -d @- \
http://localhost:8119

