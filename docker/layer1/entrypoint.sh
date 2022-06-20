#!/bin/bash

/bin/ckb list-hashes | tomljson > /var/lib/ckb/list-hashes.json
exec /bin/ckb "$@"
