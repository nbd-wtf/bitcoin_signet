#!/bin/bash
NBITS=${NBITS:-"1e0377ae"} #minimum difficulty in signet
if [[ -f "${BITCOIN_DIR}/MINE_ADDRESS.txt" ]]; then
    ADDR=$(cat ~/.bitcoin/MINE_ADDRESS.txt)
else
    ADDR=${MINETO:-$(bitcoin-cli -rpcwallet=custom_signet getnewaddress)}
fi
echo "Mineto: $MINETO"
echo "Initial mining address: $ADDR"

# Initial mining of 101 blocks if blocks count is less than 101
BLOCKS_COUNT=$(bitcoin-cli -rpcwallet=custom_signet getblockcount)
if [[ $BLOCKS_COUNT -lt 101 ]]; then
    echo "Mining initial blocks until 101"
    while [[ $BLOCKS_COUNT -lt 101 ]]; do
        echo "Mining initial block $BLOCKS_COUNT"
        miner --cli="bitcoin-cli" generate --grind-cmd="bitcoin-util grind" --address=$ADDR --nbits=$NBITS --set-block-time=$(date +%s)
        BLOCKS_COUNT=$(bitcoin-cli -rpcwallet=custom_signet getblockcount)
    done
else
    echo "Starting bitcoind mining from block $BLOCKS_COUNT"
fi


while true; do
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