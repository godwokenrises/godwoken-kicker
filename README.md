# Godwoken-Kicker

One line command to start a local network of [Godwoken](https://github.com/nervosnetwork/godwoken).

---

Godwoken v0: the latest stable version of Godwoken v0 is ["rc-0.10.0"](https://github.com/RetricSu/godwoken-kicker/tree/rc-0.10.0)

Godwoken v1: Godwoken v1 is tracked by "main" and "rc-1.\*" branches

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

## Bug Report

Whenever you encounter a problem with Kicker, please let us know by providing the following information. This will help us dig into the problem:

- Version: `git log --format="%H" -n 1`
- Service running status: `./kicker ps`
- Service logs: `./kicker logs`

## More

* [Manual build mode](docs/manual-build.md)
* [Chaos testing](docs/chaos-test.md)
