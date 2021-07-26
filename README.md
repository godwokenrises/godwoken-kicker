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

if you set `CHECKOUT` to branch name like `master`, the componets will update to newest commit id in that branch everytime you run `make init`.

## More

read [docs](docs/get-started.md) here
