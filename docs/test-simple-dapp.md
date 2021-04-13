## Test simple dapp

the quickest way to get familar with and testing out this process is to use the [simple-storage-contract](https://github.com/RetricSu/godwoken-examples/tree/bbb824f8945ac55e48a6482b419ab41a8333e62e/packages/runner/src/sample-contracts) alongside with our PolyjuiceHttpPorviders [example](https://github.com/RetricSu/polyjuice-providers-http/tree/master/example/web).

### 1. Deploy with the contract binary file under `godwoken-examples` submodule folder

```sh
godwoken-examples/packages/runner/src/sample-contracts/SimpleStorage.bin
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
<script>
            // init provider and web3
            const godwoken_rpc_url = 'http://127.0.0.1:8119';
            const provider_config =  {
                godwoken: {
                    rollup_type_hash: "...",
                    layer2_lock: {
                        code_hash: "..",
                        hash_type: "data"
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
    "account_id": "...",
    "address": "<replace with your deployed contract address>",
    "contract_name": "SimpleStorage",
    "abi": [..],
}
```

### 5. Run dapp

```sh
yarn example
```