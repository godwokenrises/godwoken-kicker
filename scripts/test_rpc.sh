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
        ["0x9e39821b6774239ebc4578af7a0b299145236878c99c9433663e17d6c94d3ed3"]

}' \
| tr -d '\n' \
| curl -H 'content-type: application/json' -d @- \
http://localhost:8119

