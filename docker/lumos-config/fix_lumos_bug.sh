#!/bin/bash

addr=$1
port=$2
user=$3

sed -i -e "s/\(address=\).*/\1$1/" \
-e "s/\(port=\).*/\1$2/" \
-e "s/\(username=\).*/\1$3/" lumos-config.json