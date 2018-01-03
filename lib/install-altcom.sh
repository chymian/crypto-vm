#!/bin/bash

# installation of Altcommunity Coin
# wallet & daemon
DEBIAN_FRONTEND=noninteractiv
sudo \apt-get -y --force-yes install qt5-default qt5-qmake qtbase5-dev-tools qttools5-dev-tools \
	build-essential libboost-dev libboost-system-dev \
	libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev \
	libssl-dev libdb++-dev libminiupnpc-dev

GIT=https://github.com/altcommunitycoin/altcommunitycoin-skunk.git
BASE_NAME=`basename $GIT .git`
COIN_NAME=Altcommunity
COIN_SIGN=ALTCOM
EXEC=/opt/$BASE_NAME/bin/altcom-qt

ICON=
DESC_NAME="$COIN_NAME Wallet"
DESC_COMMENT="$COIN_NAME Desktop Wallet"
DESC_KEYWORDS="$COIN_NAME;$COIN_SIGN;Crypto-Currency"
DESC_CATEGORIES=Network

# Install from git
cd $HOME

if [ -d $BASE_NAME ]; then
    cd $BASE_NAME
    git pull
else
    git clone $GIT
fi

cd $BASE_NAME

qmake "USE_QRCODE=1"
make j8
sudo make install

# create desktop file
cat << EOF > $COIN_NAME.desktop

[Desktop Entry]
Comment=$DESC_COMMENT
Exec=$EXEC
GenericName[en_US]=$DESC_NAME
GenericName=$DESC_NAME
Icon=
Name[en_US]=$DESC_NAME
Name=$DESC_NAME
Categories=Network;
StartupNotify=false
Terminal=false
Type=Application
MimeType=x-scheme-handler/$COIN_NAME;
EOF

sudo cp $COIN_NAME.desktop /usr/share/applications

