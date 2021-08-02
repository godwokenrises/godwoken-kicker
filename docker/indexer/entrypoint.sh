#!/bin/bash

set -o errexit

PROJECT_DIR="/code"
CKB_RPC=http://ckb:8114

RUST_LOG=info ckb-indexer -s /usr/local/ckb-indexer/data -c ${CKB_RPC} -l 0.0.0.0:8116
