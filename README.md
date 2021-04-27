# Godwoken-Kicker

one line command to start a quick devnet godwoken-polyjuice chain for contract depolyment.

with web3 custom provider like [polyjuice-providers-http](https://github.com/RetricSu/polyjuice-providers-http), you can do simple debugging and testing for your dapp as well.

## How to run

make sure you have `docker` and `docker-compose` install on your machine.

```sh
    docker --version
    docker-compose --version
```

clone the code: 

```sh
git clone https://github.com/RetricSu/godwoken-kicker.git
cd godwoken-kicker 
```

when you run first time, do:

```sh
make init
```

then you can start godwoken-polyjuice chain by simply running:

```sh
make start
```

you can monitor godwoken and polyjuice backend real-time activities:

```sh
make sp # sp means show polyjuice activities
make sg # sg means show godwoken activities
```

after everything started, check `http://localhost:6100/` to deploy contract.

![panel](docs/panel.png)

## How to deploy contract

1. open `http://localhost:6100/`, connect with your metamask address
2. click `Deposit` button to fund some devnet ckb on your metamask address.
3. after deposit finished, 
    - click `Deploy Contract` button
    - select the contract compiled binary file from your computer
    - sign the message with metamask 
   
then the deployment will auto start.

after deployment successfully get done, you will find the contract address listing below.

with deployed contract address and the above web3.js-init-code sample, you are good to go.

## How to test dapp

read [doc here](docs/test-simple-dapp.md).

## Some useful command

```sh
make stop # stop the godwoken-polyjuice chain and everything related. (but not remove data) 
```

```sh
make start # start the godwoken-polyjuice chain service.
```

```sh
make start-f # force start. the default command `make start` will not deploy a new godwoken chain if it exits, use start-f if you want to deploy a new chain.
```

```sh
make clean # this will clean the ckb chain data and every other layer1-related cache data(eg: ckb-indexer data/ckb-cli data/lumos cache data) as well
```

```sh
make down # equals `docker-compose down`, down all the service 
```

so if you want to have a fresh start, you can run:

```sh
make down
make clean
make start-f
```

