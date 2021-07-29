# Godwoken-Kicker

one line command to start godwoken-polyjuice chain for devnet.

```md
- master branch: for production releasement, should support both two modes.
- develop branch: for newest development. most of time, only support custom-mode.
```


----

## How to run

```md
## quick-mode

run all componets from prebuild docker images, 
fast and simple

## custom-mode

run all componets building from local packages,
more flexible, for more custom needs
```

command to start everything:

```sh
make init
make start
```

## How Kicker Works

- `packages`: contains all componets repo used in custom-mode.
- `workspace`: contains all scripts and bins used for godwoken deployment
- `cache`: contains all cache files produced by componets activities or building

some useful commands:

```sh
make clean # remove workspace, requires make init next time.
make clean-cache # remove chain activity cache data, but keep workspace, packages and building cache unchanged
make uninstall # remove all componets in packages folder
make clean-build-cache # remove packages building cache like cargo crates cache
```

### 1. clean current chain data but keep everything else unchanged(best way  to start a new chain) 

```sh
make clean-cache
make start
```

### 2. re-build scripts and bins used for chain deployment

```sh
make clean
make init
make start
```

### 3. update componet package

you can update componets version under [packages] section in `docker/.build.mode.env` file.

```sh
####[packages]
GODWOKEN_GIT_URL=https://github.com/nervosnetwork/godwoken.git
GODWOKEN_GIT_CHECKOUT=v0.6.0-rc1
POLYMAN_GIT_URL=https://github.com/RetricSu/godwoken-polyman.git
POLYMAN_GIT_CHECKOUT=master
WEB3_GIT_URL=https://github.com/nervosnetwork/godwoken-web3.git
WEB3_GIT_CHECKOUT=v0.5.0-rc2
SCRIPTS_GIT_URL=https://github.com/nervosnetwork/godwoken-scripts.git
SCRIPTS_GIT_CHECKOUT=v0.8.0-rc1
POLYJUICE_GIT_URL=https://github.com/nervosnetwork/godwoken-polyjuice.git
POLYJUICE_GIT_CHECKOUT=v0.8.2-rc
CLERKB_GIT_URL=https://github.com/nervosnetwork/clerkb.git
CLERKB_GIT_CHECKOUT=v0.4.0
```

if you set `ALWAYS_FETCH_NEW_PACKAGE` to true (default is false) and set package's `CHECKOUT` to branch name like `master`, then the componets will update to newest commit id in that branch everytime you run `make init`.

```sh
####[system]
ALWAYS_FETCH_NEW_PACKAGE=true
```

## More

read [docs](docs/get-started.md) here
