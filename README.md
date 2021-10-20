# Godwoken-Kicker

one line command to start godwoken-polyjuice chain for devnet.

```md
- master branch: for production release, should support both two modes.
- develop branch: for newest development, might be broken. most of time, only support custom-mode.
```


----

## How to run

```md
## quick-mode

run all components from prebuild docker images, 
fast and simple

## custom-mode

run all components building from local packages,
more flexible, for more custom needs
```

command to start everything:

```sh
make init
make start
```

## Requirement

if you are using quick-mode:

- [curl](https://curl.se/) (this only [effects](https://github.com/RetricSu/godwoken-kicker/issues/115) showing progressbar correctly)
- [docker-compose](https://docs.docker.com/compose/)

if you are using custom-mode:

- [curl](https://curl.se/) (this only [effects](https://github.com/RetricSu/godwoken-kicker/issues/115) showing progressbar correctly)
- [docker-compose](https://docs.docker.com/compose/)
- [moleculec](https://github.com/nervosnetwork/molecule) 0.7.2 (cargo install moleculec)
- nodejs 14 && yarn ([how to install](https://yarnpkg.com/lang/en/docs/install/))
- [capsule](https://github.com/nervosnetwork/capsule) v0.7.0 (cargo install capsule)

## How Kicker Works

- `packages`: contains all components repo used in custom-mode.
- `workspace`: contains all scripts and bins used for godwoken deployment
- `cache`: contains all cache files produced by components activities or building

some useful commands:

```sh
make clean # remove all, requires make init next time.
make clean-data # remove cache activities data (eg: chain-data) and workspace, only keep packages untouched. requires make init next time.
make clean-cache # remove chain activity cache data, but keep workspace, packages  unchanged
make uninstall # remove all files in packages folder
make clean-build-cache # remove packages building cache like cargo crates cache
```

### 1. clean current chain data but keep everything else unchanged(best way to start a new chain) 

```sh
make clean-cache
make start
```

### 2. re-build scripts and bins used for chain deployment

```sh
make clean-data
make init
make start
```

### 3. brand-new restart

```sh
make clean
make init
make start
```

### 4. update component package

when you choose custom-build mode, you can update components version under [packages] section in `docker/.build.mode.env` file.

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

if you set `ALWAYS_FETCH_NEW_PACKAGE` to true (default is false) and set package's `CHECKOUT` to branch name like `master`, then the components will update to newest commit id in that branch every time you run `make init`.

```sh
####[system]
ALWAYS_FETCH_NEW_PACKAGE=true
```

## More

read [docs](docs/get-started.md) here
