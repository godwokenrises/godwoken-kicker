# How to enable ckb reorgs for chaos test

## require

- yarn && nodejs
- [pumba](https://github.com/alexei-led/pumba)

## run

1. set env in `.build.mode.env` to true

```s
ENABLE_MULTI_CKB_NODES=true
WATCH_CKB_REORG=true
```

2. `make init && make start`

3. after kicker is up, run `make chaos`

4. check `chain-reorg.log` file to see how many times reorg has happend. 
