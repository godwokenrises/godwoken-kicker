# Accounts Used in Godwoken-Kicker

This document is not intended for general users, but rather Godwoken-Kicker developers. It describes the purposes and occurrences of these accounts used by Godwoken-Kicker. All of these accounts' private keys locate on [`./accounts/`](../accounts/) directory. And the CKB genesis block pre-issues amount of CKB for these accounts, see [the ckb chain spec](../docker/layer1/ckb/specs/dev.toml) for more detail.

Using the following command, you can find out more about each account.

```shell
$ ls -1 accounts
ckb-miner-and-faucet.key
godwoken-block-producer.key
rollup-scripts-deployer.key

$ ckb-cli util key-info --privkey-path accounts/godwoken-block-producer.key
Put this config in < ckb.toml >:

[block_assembler]
code_hash = "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8"
hash_type = "type"
args = "0x1d4b2a15f55ba1aa035f64ad6080e0943cc5ec0b"
message = "0x"

address:
  mainnet: ckb1qyqp6je2zh64hgd2qd0kfttqsrsfg0x9as9szl4xjv
  testnet: ckt1qyqp6je2zh64hgd2qd0kfttqsrsfg0x9as9sl6te7s
lock_arg: 0x1d4b2a15f55ba1aa035f64ad6080e0943cc5ec0b
lock_hash: 0x24842c3d28d9df39325ad05284efc3492972eec61606b51ded82369b3de72f04
old-testnet-address: ckt1q9gry5zgr49j5904tws65q6lvjkkpq8qjs7vtmqt3eg4j8
pubkey: 02261c3634191150993cb256adeb0ddf29a2b317b99885323564e28886933c9099

```

> It is possible to use only one key to do everything, but I think mixing keys will cause confusion and make debugging more difficult.

## [CKB Miner](../accounts/ckb-miner-and-faucet.key)

  This key identifies the CKB miner, which is used to unlock blocks cellbase. The corresponding public key is configured in [`ckb.toml` `[block_assembler]`](../docker/layer1/ckb/ckb.toml#L143-L147) under CKB's base directory.

## [CKB Faucet](../accounts/ckb-miner-and-faucet.key)

  The CKB faucet uses the same key as the [CKB miner](./accounts.md#ckb-miner).

  Upon executing `kicker deposit`, the CKB faucet transfers an amount of CKBs to the given address and then deposits into layer2(Godwoken).

## [Deployer of Rollup Genesis Cell](../accounts/godwoken-block-producer.key)

  The deployer of rollup genesis cell on layer1 uses this key to deploy Rollup genesis cell.

  When sets up Rollup genesis cell on layer1, `gw-tools deploy-genesis` [records the public key](https://github.com/nervosnetwork/godwoken/blob/c18807b5cfaa961c230e15e3a381570c324db6f8/crates/tools/src/deploy_genesis.rs#L428-L448) using [Omnilock](https://blog.cryptape.com/omnilock-a-universal-lock-that-powers-interoperability-1).

  The key must be the same as [Godwoken block producer](./accounts.md#godwoken-block-producer). I have no idea why.

## [Deployer of Rollup Scripts (will be removed soon)](../accounts/rollup-scripts-deployer.key)

  `gw-tools deploy-scripts` uses this account to deploy rollup related scripts onto layer1.

## [Godwoken Block Producer](../accounts/godwoken-block-producer.key)

  This key identifies the Godwoken block producer. 

  ```toml
  [block_producer.wallet_config]
  privkey_path = '/godwoken-block-producer.key'
  
  [block_producer.wallet_config.lock]
  code_hash = '0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8'
  hash_type = 'type'
  args = '0x952809177232d0dba355ba5b6f4eaca39cc57746'
  ```
