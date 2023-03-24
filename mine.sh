#!/bin/bash
NBITS=${NBITS:-"1e0377ae"} #minimum difficulty in signet

while true; do
    ADDR=${MINETO:-$(bitcoin-cli getnewaddress)}
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
    echo "Mine To:" $ADDR
    miner --cli="bitcoin-cli" generate --grind-cmd="bitcoin-util grind" --address=$ADDR --nbits=$NBITS --set-block-time=$(date +%s)
done
