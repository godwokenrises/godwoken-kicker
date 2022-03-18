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
  start                   Start services and deploy local network
  stop                    Stop services
  info                    Print some useful info about the network and running services, such as Web3 RPC URL
  clean                   Clean containers volumed data
  ps [service]            List services
  logs [service]          Tail target service's logs
  enter <service>         Enter target service's container
  manual-build            Manually build services artifacts
  deposit <eth-address> <amount>  Deposit CKB to layer2
  get-balance <eth-address>       Get layer2 balance

EXAMPLES:
  * Deploy the local network and print service info

    $ ./kicker start
    $ ./kicker info

  * Deposit 1000CKB from layer1 to layer2

    $ ./kicker deposit 0x618cc3C660cEBFDbA8570CA739b1744AE3E2553a 1000
    $ ./kicker get-balance 0x618cc3C660cEBFDbA8570CA739b1744AE3E2553a

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
