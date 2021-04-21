echo '{
    "id": 2,
    "jsonrpc": "2.0",
    "method": "get_account_id_by_script_hash",
    "params":
        "0x5ea415fca8c85f716a18c68acdc491657c173fbb953db21aba7e00b953a1bce6"

}' \
| tr -d '\n' \
| curl -H 'content-type: application/json' -d @- \
http://localhost:8119

echo -e "\n"

echo '{
    "id": 2,
    "jsonrpc": "2.0",
    "method": "get_script_hash",
    "params":
        "0x1"

}' \
| tr -d '\n' \
| curl -H 'content-type: application/json' -d @- \
http://localhost:8119

echo -e "\n"

echo '{
    "id": 2,
    "jsonrpc": "2.0",
    "method": "get_tip_block_hash",
    "params":
        ""

}' \
| tr -d '\n' \
| curl -H 'content-type: application/json' -d @- \
http://localhost:8119