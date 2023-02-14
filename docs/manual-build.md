# Manual-Build Mode

This document is not intended for general users, but for advanced users who want to customize Docker Compose services, e.g. replace the prebuilt artifacts with customized ones.

## How Godwoken-Kicker Supports Manual-Build mode

Let's start with an example to demonstrate how Godwoken-Kicker supports manual-build mode [using multiple Docker Compose files](https://runnable.com/docker/advanced-docker-compose-configuration).

1. In [`docker/docker-compose.yml`](../docker/docker-compose.yml), we define a base "godwoken" service that runs on a prebuilt image. By the way, godwoken's binary is located in /usr/bin/godwoken.

  ```yaml
  godwoken:
    image: ghcr.io/flouse/godwoken-prebuilds:v1.0.x-202203160423
    environment:
      RUST_LOG: info,gw_generator=debug
      GODWOKEN_MODE: fullnode
      RUST_BACKTRACE: full
    volumes:
      - ./layer2:/var/lib/layer2
    ports:
      - 8119:8119
      - 8120:8120
    command: [ "godwoken", "run", "-c", "/var/lib/layer2/config/godwoken-config.toml" ]
  ```

2. Manually build your godwoken binary and place it in `docker/manual-artifacts/godwoken`.

  You can build by yourself or use [`kicker manual-build`](./manual-build.md#kicker-manual-build-usage), just make sure your built binary is placed in [`docker/manual-artifacts/`](../docker/manual-artifacts/).

  ```shell
  MANUAL_BUILD_GODWOKEN=true \
  GODWOKEN_GIT_URL=ssh://git@github.com/godwokenrises/godwoken \
  GODWOKEN_GIT_CHECKOUT=develop \
  ./kicker manual-build
  ```

  Just take a look:

  ```shell
  $ ls -l docker/manual-artifacts/godwoken
  -rwxr-xr-x 1 staff staff 58719848 Mar 18 17:49 docker/manual-artifacts/godwoken

  $ file docker/manual-artifacts/godwoken
  docker/manual-artifacts/godwoken: ELF 64-bit LSB pie executable, x86-64, version 1 (GNU/Linux), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, BuildID[sha1]=e37924aba5413cd7c105eba1d6e65ad15fd675c6, for GNU/Linux 3.2.0, with debug_info, not stripped
  ```

3. Create a new Docker Compose file [`docker/manual-godwoken.compose.yml`](../docker/manual-godwoken.compose.yml)

  ```yaml
  services:
    godwoken:
      volumes:
        # Volume our manual-build godwoken to
        # `/usr/bin/godwoken` inside container
        - ./manual-artifacts/godwoken:/usr/bin/godwoken
  ```

4. Start "godwoken" service with our manual-build artifacts

  ```shell
  # Starts all services
  # Equal to `docker-compose -f docker/docker-compose.yml -f docker/manual-godwoken.compose.yml up`
  MANUAL_BUILD_GODWOKEN=true ./kicker start 

  # Or only starts a single godwoken service
  # Equal to `docker-compose -f docker/docker-compose.yml -f docker/manual-godwoken.compose.yml up -d godwoken`
  MANUAL_BUILD_GODWOKEN=true ./kicker start godwoken
  ```

## `kicker manual-build` Usage

> Personally, I don't recommend using Kicker manual build if you are unfamiliar with it. Before you use the *kicker manual-build* mode, you should know how Godwoken-Kicker runs in the manual-build mode. A good way to do this is to read the [`kicker`](../kicker) script.

Pulls godwoken repository into `packages/godwoken/`, builds, and then moves the finalized artifacts to `docker/manual-build/`:

```shell
MANUAL_BUILD_GODWOKEN=true \
GODWOKEN_GIT_URL=ssh://git@github.com/godwokenrises/godwoken \
GODWOKEN_GIT_CHECKOUT=compatibility-breaking-changes \
./kicker manual-build
```

Start services that uses manual-build artifacts:

```shell
MANUAL_BUILD_GODWOKEN=true ./kicker start
```
