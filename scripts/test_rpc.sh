#!/bin/bash

echo -e "get_script_hash, id: 2 \n"

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

echo -e "get_script_hash, id: 7 \n"

echo '{
    "id": 2,
    "jsonrpc": "2.0",
    "method": "get_script_hash",
    "params":
        ["0x7"]

}' \
| tr -d '\n' \
| curl -H 'content-type: application/json' -d @- \
http://localhost:8119

echo -e "get_account_id, id: 4 \n"

echo '{
    "id": 2,
    "jsonrpc": "2.0",
    "method": "get_account_id_by_script_hash",
    "params":
        ["0x162805086915a6d2fb5dd1f45c018a7d403a059073abc3f411dd861c8239ed67"]

}' \
| tr -d '\n' \
| curl -H 'content-type: application/json' -d @- \
http://localhost:8119

