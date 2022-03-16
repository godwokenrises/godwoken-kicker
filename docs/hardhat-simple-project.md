# Deploy A Simple Contract Using Hardhat

### Before you start

**Please make sure you have [deployed the local network of Godwoken](./kicker-start.md) before trying this document.**

### Prepare a simple hardhat project

```sh
$ git clone --depth=1 ssh://git@github.com/NomicFoundation/hardhat
$ cd hardhat/packages/hardhat-core/sample-projects/basic/
$ ls
LICENSE.md  README.md  cache  contracts  hardhat.config.js  scripts  test
```

### Install requirements

```sh
$ npm install --save-dev hardhat @nomiclabs/hardhat-waffle
```

### Adapt `hardhat.config.js` to our local network of Godwoken

Add the below `network` configuration into `hardhat.config.js`:

```js
module.exports = {

  networks: {
    gw_devnet_v1: {
      url: `http://localhost:8024`,
      accounts: [`0x6cd5e7be2f6504aa5ae7c0c04178d8f47b7cfc63b71d95d9e6282f5b090431bf`, `0xdd50cac37ec6dd12539a968c1a2cbedda75bd8724f7bcad486548eaabb87fc8b`],
    }
  },

  ...
}
```

### Run hardhat on our local network of Godwoken by `--network gw_devnet_v1`

```sh
$ npx hardhat accounts --network gw_devnet_v1
$ npx hardhat compile
$ npx hardhat test --network gw_devnet_v1
$ npx hardhat run --network gw_devnet_v1 scripts/sample-script.js
```
