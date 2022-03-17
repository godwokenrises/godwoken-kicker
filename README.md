# Godwoken-Kicker

One line command to start a local network of [Godwoken](https://github.com/nervosnetwork/godwoken).

```md
- master branch: for production release, should support both two modes.
- develop branch: for newest development, might be broken. most of time, only support custom-mode.
```

----

## Getting Started

1. [Deploy local network of Godwoken](./docs/kicker-start.md)

2. [Deploy a simple contract using Hardhat](./docs/hardhat-simple-project.md)


## Usage

```
./kicker --help
Usage: ./kicker [OPTIONS] <SUBCOMMAND>

OPTIONS:
  --help          Print usage information
  -- <args>...    Execute docker-compose command

SUBCOMMANDS:
  init                    Init running environment
  start                   Start services
  stop                    Stop services
  info                    Print information about the network and services
  clean                   Clean containers volumed data
  ps [service]            List services
  logs [service]          Tail target service's logs
  enter <service>         Enter target service's container
  manual-build            Manually build services artifacts
  deposit <privkey-path> <capacity>   Deposit from layer1(CKB network) to layer2 Godwoken network

EXAMPLES:
  * Deploy the local network and print service info

    $ ./kicker start
    $ ./kicker info

  * Deposit 1000CKB from layer1 to layer2

    $ ./kicker deposit config/private_key 1000

  * Redeploy the local network

    $ ./kicker stop
    $ sudo ./kicker clean
    $ ./kicker start

  * Execute docker-compose commands

    $ ./kicker -- exec ckb ls -l
    $ ./kicker -- top godwoken
    $ ./kicker -- kill godwoken
    $ ./kicker -- --help
```

## More

* [Manual build mode](docs/manual-build.md)
* [Chaos testing](docs/chaos-test.md)
