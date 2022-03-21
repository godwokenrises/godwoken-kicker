# Deploy Local Network of Godwoken

## Requirement

- [docker](https://www.docker.com/)
- [docker-compose >= 1.29.0](https://docs.docker.com/compose/)
- [jq](https://stedolan.github.io/jq/)

---

## Deploy a local network of Godwoken using Godwoken-Kicker

```shell
git clone -b kicker-script https://github.com/RetricSu/godwoken-kicker
cd godwoken-kicker
./kicker start
```

This command deploys a local network of godwoken. Upon completion, the following docker containers should be running(see more [`docker-compose.yml`](../docker/docker-compose.yml)):
  - `docker_ckb_1`
  - `docker_ckb-miner_1`
  - `docker_ckb-indexer_1`
  - `docker_godwoken_1`
  - `docker_web3_1`
  - `docker_web3-indexer_1`
  - `docker_postgres_1`
  - `docker_redis_1`

Note that it might take several minutes on the first run. You can use `./kicker info` to get some useful info about the network and running services, such as Web3 RPC URL.

```shell
$ ./kicker info
Web3 RPC URL: http://127.0.0.1:8024
```

## Deposit some CKB to layer2 account

In this example, we use the private key *0x9d5bc55413c14cf4ce360a6051eacdc0e580100a0d3f7f2f48f63623f6b05361* and the ETH address is `0xCD1d13450cFA630728D0390C99957C6948BF7d19`.

```shell
$ ./kicker get-balance 0xCD1d13450cFA630728D0390C99957C6948BF7d19
Balance: 0

$ ./kicker deposit 0xCD1d13450cFA630728D0390C99957C6948BF7d19 999
eth address: 0xcd1d13450cfa630728d0390c99957c6948bf7d19
layer2 script hash: 0x75e830169e5a0ce461b05e7db195a7cec8b21a2783620d735a1e77c7937686b0
short script hash: 0x75e830169e5a0ce461b05e7db195a7cec8b21a27
tx_hash: 0x115b11dbeee6ccf1c0879ea7e5b554d1664ec0114be963dad0f4f2ed5d32bc42
...
current balance: 99900000000, waiting for 8 secs.
deposit success!
Your account id: 53

$ ./kicker get-balance 0xCD1d13450cFA630728D0390C99957C6948BF7d19
Balance: 99900000000
```

## What next

Try to deploy your contracts using [Hardhat](https://hardhat.org/): [Deploy a simple contract using Hardhat](./hardhat-simple-project.md)
