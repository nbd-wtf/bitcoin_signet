echo "Generate or import keyset"
gen-signet-keys.sh
echo "Generate bitcoind configuration"
gen-bitcoind-conf.sh >~/.bitcoin/bitcoin.conf
echo "Setup Signet"
setup-signet.sh

if [[ "$MINE_GENESIS" == "1" ]]; then
    echo "Mine Genesis Block"
    mine-genesis.sh
fi

touch ~/.bitcoin/install_done
