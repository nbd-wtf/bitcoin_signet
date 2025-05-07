DATADIR=${DATADIR:-~/.bitcoin/}
bitcoind -datadir=$DATADIR --daemonwait -persistmempool #-deprecatedrpc=create_bdb
bitcoin-cli -datadir=$DATADIR -named createwallet wallet_name="custom_signet" load_on_startup=true descriptors=true
#only used in case of mining node
if [[ "$MINERENABLED" == "1" ]]; then

line_count=0
    while read line; do
        # Increment the line counter
        line_count=$((line_count+1))
        
        # Check if the line count is even or odd
        if [ $((line_count % 2)) -eq 0 ]; then
            is_even="true"
        else
            is_even="false"
        fi
        
        
        DESCRIPTORS="
        {
            \"desc\": \"${line}\",
            \"timestamp\": 0,
            \"active\": true,
            \"internal\": ${is_even},
            \"range\": [
                0,
                999
            ]
        }"
        
        DESCRIPTORS="[${DESCRIPTORS//[$'\t\r\n ']}]"
        
        bitcoin-cli -datadir=$DATADIR importdescriptors "$DESCRIPTORS" 2>&1 > /dev/null
        
    done < ~/.bitcoin/PRIVKEY.txt
fi