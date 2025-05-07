#!/bin/bash
set -Eeuo pipefail
# Define mining constants
CLI="bitcoin-cli -datadir=${BITCOIN_DIR}" 
GRIND="bitcoin-util grind"
MINING_DESC=$($CLI listdescriptors | jq -r ".descriptors | .[4].desc")

NBITS=${NBITS:-"1e0377ae"} #minimum difficulty in signet

while true; do
    ADDR=${MINETO:-$(bitcoin-cli getnewaddress)}
    echo "Mining to address:" $ADDR
    if [[ -f "${BITCOIN_DIR}/BLOCKPRODUCTIONDELAY.txt" ]]; then
        BLOCKPRODUCTIONDELAY_OVERRIDE=$(cat ~/.bitcoin/BLOCKPRODUCTIONDELAY.txt)
        echo "Delay OVERRIDE before next block" $BLOCKPRODUCTIONDELAY_OVERRIDE "seconds."
        sleep $BLOCKPRODUCTIONDELAY_OVERRIDE
    else
        BLOCKPRODUCTIONDELAY=${BLOCKPRODUCTIONDELAY:="0"}
        if [[ BLOCKPRODUCTIONDELAY -gt 0 ]]; then
            echo "Delay before next block" $BLOCKPRODUCTIONDELAY "seconds."
            sleep $BLOCKPRODUCTIONDELAY
        fi
    fi
    #echo "Mine To:" $ADDR
    miner --cli="bitcoin-cli" generate --grind-cmd="bitcoin-util grind" --addr=$ADDR --nbits=$NBITS  --set-block-time=$(date +%s) 
done

 