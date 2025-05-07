#!/bin/bash
set -Eeuo pipefail
# Define mining constants
CLI="bitcoin-cli -datadir=${BITCOIN_DIR}" 
GRIND="bitcoin-util grind"
MINING_DESC=$($CLI listdescriptors | jq -r ".descriptors | .[4].desc")

NBITS=${NBITS:-"1e0377ae"} #minimum difficulty in signet

while true; do
    ##ADDR=${MINETO:-$(bitcoin-cli getnewaddress)}
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
    miner --cli="bitcoin-cli" generate --grind-cmd="bitcoin-util grind" --nbits=$NBITS --descriptor=$MINING_DESC --set-block-time=$(date +%s) 
done


# #!/bin/bash



# while echo "Start mining... ";
# do
#     CURRBLOCK=$(bitcoin-cli -datadir=/bitcoind getblockcount)
#     echo "Current blockcount: ${CURRBLOCK}"
#     if [ $CURRBLOCK -le 100 ]; then
#         $MINER --cli="$CLI" generate --grind-cmd="$GRIND" --min-nbits --descriptor=$MINING_DESC --max-blocks=101
#     fi
    
#     # BITS calibration after 100 blocks
#     if [ -f "/bitcoind/nbits_calibration.txt" ]; then
#         NBITS=`cat /bitcoind/nbits_calibration.txt`
#     else
#         echo "Waiting for difficulty calibration..."
#         NBITS=`$MINER calibrate --grind-cmd="$GRIND" --seconds=600 | grep -oP 'nbits=\K[a-f0-9]+'`
#         echo "The number of bits is: $NBITS"
#         echo $NBITS > /bitcoind/nbits_calibration.txt
#     fi
    
#     $MINER --cli="$CLI" generate --grind-cmd="$GRIND" --nbits=$NBITS --descriptor=$MINING_DESC --poisson --ongoing
# done

# # If loop is interrupted, stop bitcoind
# bitcoin-cli -datadir=/bitcoind stop