# Accounts Used in Godwoken-Kicker

This document is not intended for general users, but rather Godwoken-Kicker developers. It describes the purposes and occurrences of these accounts used by Godwoken-Kicker. All of these accounts' private keys locate on [`./accounts/`](../accounts/) directory. And the CKB genesis block pre-issues amount of CKB for these accounts, see [the ckb chain spec](../docker/layer1/ckb/specs/dev.toml) for more detail.

Using the following command, you can find out more about each account.

```shell
$ ls -1 accounts
ckb-miner-and-faucet.key
godwoken-block-producer.key
godwoken-eoa-register-and-polyjuice-root-account.key
rollup-scripts-deployer.key

$ ckb-cli util key-info --privkey-path accounts/godwoken-eoa-register-and-polyjuice-root-account.key
Put this config in < ckb.toml >:

[block_assembler]
code_hash = "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8"
hash_type = "type"
args = "0x2fb2d69092a6c9206c7f5c2348ebf0a84438bcf2"
message = "0x"

address:
  mainnet: ckb1qyqzlvkkjzf2djfqd3l4cg6ga0c2s3pchneq02k5an
  testnet: ckt1qyqzlvkkjzf2djfqd3l4cg6ga0c2s3pchneqj0gt30
lock_arg: 0x2fb2d69092a6c9206c7f5c2348ebf0a84438bcf2
lock_hash: 0xdef995f28d313531a8b2bfb2c38b933f91803cee857df6741982a4293a49f007
old-testnet-address: ckt1q9gry5zg97eddyyj5myjqmrlts3536ls4pzr308j2mc4qc
pubkey: 03b87ab0edfbc154c6cc6437a773f343ba1120825be5f2664f41ce3e4180b05aa7

$ ethereum_private_key_to_address $(cat accounts/godwoken-eoa-register-and-polyjuice-root-account.key)
0x5Afa08022F00A540FBB0F743c63d835c08056E89

$ grep $(cat accounts/godwoken-eoa-register-and-polyjuice-root-account.key) docker/layer1/ckb/specs/dev.toml
# private key: 0x751bce00b384d4a6f65034346761c66aa958072163eb5bd1f6f8bd300dc11b9f
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

## [Polyjuice Root Account](../accounts/godwoken-eoa-register-and-polyjuice-root-account.key)

  [godwoken/life_of_a_polyjuice_transaction.md](https://github.com/nervosnetwork/godwoken/blob/master/docs/life_of_a_polyjuice_transaction.md#root-account--deployment)

  After polyjuice root account was created by `gw-tools create-creator-account`, the resulting account id will be configured as `CREATOR_ACCOUNT_ID` in Godwoken-Web3 configuration file.


## [Godwoken EOA Register (will be deprecated at Godwoken v1)](../accounts/godwoken-eoa-register-and-polyjuice-root-account.key)

  This key belongs to [EthEoaMappingRegister.wallet](https://github.com/nervosnetwork/godwoken/blob/3605c70/crates/eoa-mapping/src/eth_register.rs#L22). It must be related to a created Godwoken Account. It will be used to [sign](https://github.com/nervosnetwork/godwoken/blob/3605c70/crates/eoa-mapping/src/eth_register.rs#L147) EthEoaMappingRegister transaction which is a layer2 transaction.
