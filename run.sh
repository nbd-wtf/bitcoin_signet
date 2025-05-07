#!/bin/bash

# run bitcoind
bitcoind --daemonwait -deprecatedrpc=create_bdb
sleep 5
echo "get magic"
magic=$(cat /root/.bitcoin/signet/debug.log | grep -m1 magic)  
magic=${magic:(-8)}
echo $magic > /root/.bitcoin/MAGIC.txt

# if in mining mode
if [[ "$MINERENABLED" == "1" ]]; then
    mine.sh
fi