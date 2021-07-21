# Godwoken-Kicker

one line command to start godwoken-polyjuice chain for devnet.

`develop branch for kicker. most of time, only support manual-build mode(custom-mode).`

----

## How to run

```md
## quick-mode

use prebuild scripts and binary from docker images, 
fast and simple

## custom-mode

use manual-build scripts and binary via local submodules,
more flexible, for more custom needs

eg: you can use manual mode to debug with
- godwoken
- godwoken-web3
- godwoken-scripts
- godwoken-polyjuice
```

by default, we ship the components with the ***same version*** in both quick-mode(under prebuild-docker-image) and custom-mode(under local packages folder). you can checkout the specific version information for all components in the release tags descriptions.

## 1. Quick mode

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

when you run first time, or everytime after you change mode / clean data, please do:

```sh
make init
```

then you can start godwoken-polyjuice chain by simply running:

```sh
make start
```

you can monitor godwoken and polyjuice backend real-time activities:

```sh
make sp # sp means show polyjuice chain manage-server logs
make sg # sg means show godwoken logs
```

after everything started, check `http://localhost:6100/` to deploy contract.

![panel](docs/main.png)

### How to deploy contract

1. open `http://localhost:6100/`, connect with your metamask address
2. click `Deposit` button to fund 400 devnet ckb on your metamask address each time.
3. after deposit finished,
    - click `Deploy Contract` button
    - select the contract compile artifact json file or binary file from your computer
    - sign the message with metamask

then the deployment will auto start.

after deployment successfully get done, you will find the contract address listing below.

### How to test dapp

you can use the kicker's built-in `Contract Debugger` right on the page to give your dapp a first simple manual test.

![panel](docs/contract-debugger.png)

## 2. Custom mode

### ***- build custom components on local***

open `/docker/.build.mode.env` file, under the [mode] section,
set the component you want to `true`, 
and set the github repo url and checkout for componets

```sh
####[mode]
MANUAL_BUILD_GODWOKEN=false
MANUAL_BUILD_WEB3=false
MANUAL_BUILD_SCRIPTS=false
MANUAL_BUILD_POLYJUICE=false
...

####[packages]
GODWOKEN_GIT_URL=https://github.com/nervosnetwork/godwoken.git
GODWOKEN_GIT_CHECKOUT=master
POLYMAN_GIT_URL=https://github.com/RetricSu/godwoken-polyman.git
POLYMAN_GIT_CHECKOUT=master
WEB3_GIT_URL=https://github.com/nervosnetwork/godwoken-web3.git
WEB3_GIT_CHECKOUT=main
...
```

then run

```sh
make init
make start
```

and the component will be build and run through submodule on local.

### ***- skip building Godwoken by providing binary***

sometimes you don't want to building Godwoken in Kicker beacuse the network inside docker container can be unreliable slow. 

you can set `/docker/.build.mode.env` to "skip" option:

```sh
####[mode]
MANUAL_BUILD_GODWOKEN=skip
MANUAL_BUILD_WEB3=false
MANUAL_BUILD_SCRIPTS=false
MANUAL_BUILD_POLYJUICE=false
...
```

provide your own godwoken binary:

```s
make pass-godwoken-binary
```

or simply copy the binaries of godwoken and gw-tools into this path `/workspace/bin/` by yourself.

finally, run:

```sh
make init
make start
```

everything is good!

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
