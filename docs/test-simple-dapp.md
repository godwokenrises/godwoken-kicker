# How to test Dapp on Godwoken-Polyjuice

the quickest way to get familar with and testing out this process is to use the [simple-storage-contract](https://github.com/RetricSu/godwoken-polyman/tree/bbb824f8945ac55e48a6482b419ab41a8333e62e/packages/runner/src/sample-contracts) alongside with our PolyjuiceHttpPorviders [example](https://github.com/RetricSu/polyjuice-providers-http/tree/master/example/web).

if you want to testing with your own dapp, just jump to second parts.

## Test simple-storage-contract dapp

### 1. Deploy with the contract binary file under `godwoken-polyman` submodule folder

```sh
godwoken-kicker/godwoken-polyman/packages/runner/src/sample-contracts/SimpleStorage.bin
```
after deployment, copy web3.js-init-code sample and the contract address.

### 2. Download polyjuice-providers-http project.

```sh
git clone https://github.com/RetricSu/polyjuice-providers-http
cd polyjuice-providers-http
yarn install
yarn build
```

### 3. Edit index.html in polyjuice-providers-http/example/web

just paste the copied web3.js-init-code sample in [this position](https://github.com/RetricSu/polyjuice-providers-http/blob/master/example/web/index.html#L17-L28).

```html
<body>
...
<script>
            // init provider and web3
            const godwoken_rpc_url = 'http://localhost:8024';
            const provider_config =  {
                godwoken: {
                    rollup_type_hash: "...",
                    eth_account_lock: {
                        code_hash: "..",
                        hash_type: "type"
                    }
                }
            }
            const p = new PolyjuiceHttpProvider(godwoken_rpc_url, provider_config);
            const web3 = new Web3(p);
...
```

### 4. Edit contract address in polyjuice-providers-http/example

change [this line](https://github.com/RetricSu/polyjuice-providers-http/blob/master/example/web/static/contracts/simplestorage.js#L3) in `example/web/static/contracts/simplestorage.js` with your deployed contract address.

```javascript
const SimpleContract = {
    "address": "<replace with your deployed contract address>",
    "contract_name": "SimpleStorage",
    "abi": [..],
}
```

### 5. Run dapp

```sh
yarn example
```

## Test with your own dapp

so we assume you already ran a godwoken-polyjuice chain by starting [godwoken-kicker](https://github.com/retricsu/godwoken-kicker) and deployed a smart-contract on it.

in your own dapp, you need to change two place:

1. your contract address (because you have re-deployed it on godwoken-polyjuice chain!)
2. replace your web3.js http-provider with `PolyjuiceHttpProvider`

### How to replace http-provider

first, build the PolyjuiceHttpProvider:

```sh
git clone https://github.com/RetricSu/polyjuice-providers-http.git
cd polyjuice-providers-http
yarn
yarn build
```
then  the file is located in `polyjuice-providers-http/lib/polyjuice_provider.min.js`.

init the polyjuice provider:

```sh
import PolyjuiceHttpProvider from './polyjuice_provider.min.js';

const godwoken_rpc_url = 'http://127.0.0.1:8024';
const provider_config =  {
  godwoken: {
      rollup_type_hash: "0xf70aa98a96fba847185be1b58c1d1e3cae7ad91f971eecc5749799d5e72939f0",
      eth_account_lock: {
          code_hash: "0xeeb39042bd7a1907e35823438db35f0a67fd495464abd0d183220e1ee8dda009",
          hash_type: "type"
      }
  }
}
const provider = new PolyjuiceHttpProvider(godwoken_rpc_url, provider_config);
const web3 = new Web3(provider);
```

you should be able to copy the specific init code when you deploy contract via Godwoken-Kicker.


