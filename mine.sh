#!/bin/bash
NBITS=${NBITS:-"1e0377ae"} #minimum difficulty in signet
ADDR=$(get_next_address)    # It will get the first address from the wallet ie. cusomt_signet

# Initial mining of 100 blocks if blocks count is less than 100
BLOCKS_COUNT=$(bitcoin-cli -rpcwallet=custom_signet getblockcount)
if [[ $BLOCKS_COUNT -lt 100 ]]; then
    echo "Mining initial 100 blocks"
    for ((i = BLOCKS_COUNT; i <= 100; i++)); do
        echo "Minining initial block $i"
        miner --cli="bitcoin-cli -rpcwallet=custom_signet" generate --grind-cmd="bitcoin-util grind" --address=$ADDR --nbits=$NBITS --set-block-time=$(date +%s)
    done
else
    echo "Starting bitcoind mining from block $BLOCKS_COUNT"
fi


while true; do
    if [[ -f "${BITCOIN_DIR}/MINE_ADDRESS.txt" ]]; then
        ADDR=$(cat ~/.bitcoin/MINE_ADDRESS.txt)
    else
        ADDR=${MINETO:-$(bitcoin-cli getnewaddress)}
    fi
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