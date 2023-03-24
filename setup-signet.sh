PRIVKEY=${PRIVKEY:-$(cat ~/.bitcoin/PRIVKEY.txt)}
DATADIR=${DATADIR:-~/.bitcoin/}
bitcoind -datadir=$DATADIR --daemonwait -persistmempool
bitcoin-cli -datadir=$DATADIR -named createwallet wallet_name="custom_signet" load_on_startup=true descriptors=false

#only used in case of mining node
if [[ "$MINERENABLED" == "1" ]]; then
    bitcoin-cli -datadir=$DATADIR importprivkey $PRIVKEY
    ## for future with descriptor wallets, cannot seem to get it working yet
    # descinfo=$(bitcoin-cli getdescriptorinfo "wpkh(${PRIVKEY})")
    # checksum=$(echo "$descinfo" | jq .checksum | tr -d '"' | tr -d "\n")
    # desc='[{"desc":"wpkh('$PRIVKEY')#'$checksum'","timestamp":0,"internal":false}]'
    # bitcoin-cli -datadir=$DATADIR importdescriptors $desc
fi