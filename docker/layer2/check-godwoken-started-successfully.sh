#!/bin/bash

while true; do
    sleep 1
    result=$(curl http://godwoken:8119 &> /dev/null || echo "not started")
    if [ "$result" != "not started" ]; then
        break
    fi
done

exit 0
