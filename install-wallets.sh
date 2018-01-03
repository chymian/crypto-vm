#!/bin/bash

# Install wallets from git

DEBIAN_FRONTEND=noninteractive
PREPARED_MARKER=$HOME/.install_wallets_prepared

# blank separated list of supported Coins
ALL_WALLETS="ORE ALTCOM"

# prepare system
prepare_system() {
	sudo add-apt-repository -y ppa:bitcoin/bitcoin
	sudo \apt-get update
	sudo \apt-get install -y --force-yes build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils \
		libdb4.8-dev libdb4.8++-dev libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-program-options-dev \
		libboost-test-dev libboost-thread-dev libminiupnpc-dev libzmq3-dev libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev \
		qttools5-dev-tools libprotobuf-dev protobuf-compiler libqrencode-dev

	touch $PREPARED_MARKER
}

usage() {
echo
echo "$0 [options]…"
echo "Installes various Crypto-Wallets"
echo
echo "Supported wallets: $ALL_WALLETS"
echo "Options:"
echo "   -a|--all     Installes/updates all supported Wallets for CryptoCurrency"
echo "   <SIGN>      Installes/updates the Wallet for CryptoCurrency with the Sign <SIGN>"
echo
}

# if this file was updated since last run, go, get the system prepared again
if [ $PREPARED_MARKER -ot ./$0 ]; then
	prepare_system
fi

for i in $*; do
	case $i in
		ORE)
			lib/install-ore.sh
			shift
			;;
		XVG)
			lib/install-xvg.sh
			shift
			;;
		-a|--all)
			exec ./$0 $ALL_WALLETS
			exit 0
			;;
		-h|--help)
			usage
			exit 0
			;;
	esac
done

exit 0
