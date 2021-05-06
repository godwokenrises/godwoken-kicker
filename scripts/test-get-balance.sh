#!/bin/bash

MINER_BALANCE='total: 20000000000.0 (CKB)'
TOTAL="${MINER_BALANCE##immature*:}"
TOTAL="${TOTAL##total: }"
TOTAL=" ${TOTAL%%.*} "
echo $TOTAL
if [[ "$TOTAL" -gt 1000 ]]; then
  echo 'fund suffice, ready to deploy godwoken script.'
else
  echo 'fund unsuffice ${TOTAL}, keep waitting.'
fi