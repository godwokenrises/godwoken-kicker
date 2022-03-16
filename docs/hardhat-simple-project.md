# Deploy A Simple Contract Using Hardhat

### Before you start

**Please make sure you have [deployed the local network of Godwoken](./kicker-start.md) before trying this document.**

[`.github/workflows/hardhat-simple-project.yml`](../.github/workflows/hardhat-simple-project.yml) is a GitHub Actions workflow that completes all tasks associated with this document.

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
      url: `http://127.0.0.1:8024`,
      accounts: [`0x9d5bc55413c14cf4ce360a6051eacdc0e580100a0d3f7f2f48f63623f6b05361`],
    }
  },

  ...
}
```

* `http://127.0.0.1:8024` is the Godwoken Web3 URL, which should be deployed at [deploy-a-local-network-of-godwoken-using-godwoken-kicker](./kicker-start.md#deploy-a-local-network-of-godwoken-using-godwoken-kicker)
* `0x9d5bc55413c14cf4ce360a6051eacdc0e580100a0d3f7f2f48f63623f6b05361` is the private key of account we used at [deposit-some-ckb-to-layer2-account](./kicker-start.md#deposit-some-ckb-to-layer2-account). You can replace it with your testing keys.

### Run hardhat on our local network of Godwoken by `--network gw_devnet_v1`

```sh
$ npx hardhat accounts --network gw_devnet_v1
$ npx hardhat compile
$ npx hardhat test --network gw_devnet_v1
$ npx hardhat run --network gw_devnet_v1 scripts/sample-script.js
```
