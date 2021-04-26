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

echo -e "get_script_hash, id: 4 \n"

echo '{
    "id": 2,
    "jsonrpc": "2.0",
    "method": "get_script_hash",
    "params":
        ["0x3"]

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

