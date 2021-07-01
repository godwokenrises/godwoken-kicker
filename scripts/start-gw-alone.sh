# todo: should remove to another service. but the port mapping some how not working.
./indexer-data/ckb-indexer -s indexer-data/ckb-indexer-data & 

# start godwoken
RUST_LOG=debug ./target/debug/godwoken
