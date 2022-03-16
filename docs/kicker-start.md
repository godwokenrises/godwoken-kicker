# Deploy Local Network of Godwoken

## Requirement

- [docker](https://www.docker.com/)
- [docker-compose >= 1.28.0](https://docs.docker.com/compose/)

---

## Deploy a local network of Godwoken using Godwoken-Kicker

```shell
git clone -b kicker-script https://github.com/RetricSu/godwoken-kicker
cd godwoken-kicker
./kicker start
```

This command deploys a local network of godwoken. Upon completion, the following docker containers should be running(see more [`docker-compose.yml`](./docker/docker-compose.yml)):
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
Accounts:
  - Private Key: 0xdd50cac37ec6dd12539a968c1a2cbedda75bd8724f7bcad486548eaabb87fc8b
    ETH Address: 0x0C1EfCCa2Bcb65A532274f3eF24c044EF4ab6D73
  - Private Key: 0x6cd5e7be2f6504aa5ae7c0c04178d8f47b7cfc63b71d95d9e6282f5b090431bf
    ETH Address: 0x6DaF63D8411D6E23552658E3cFb48416A6A2CA78
```

## What next

Try to deploy your contracts using [Hardhat](https://hardhat.org/): [Deploy a simple contract using Hardhat](./hardhat-simple-project.md)
