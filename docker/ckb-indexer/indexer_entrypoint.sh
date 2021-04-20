#!/bin/sh

#wget -c https://github.com/nervosnetwork/ckb-indexer/releases/download/v0.2.0/ckb-indexer-0.2.0-linux.zip -O - | unzip 
#apt update && apt upgrade && apt install unzip
#wget https://github.com/nervosnetwork/ckb-indexer/releases/download/v0.2.0/ckb-indexer-0.2.0-linux.zip -O temp.zip
#unzip temp.zip
#rm temp.zip
#ls
#cp /ckb-indexer /usr/bin/ckb-indexer
#export PATH="/usr/bin/ckb-indexer:${PATH}"
RUST_LOG=info ./ckb-indexer -s ckb-indexer-data -c http://ckb:8114
