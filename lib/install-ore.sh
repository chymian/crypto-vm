#!/bin/bash

# installation of Galactrum Coin 
# wallet & daemon

GIT=https://github.com/galactrum/galactrum.git
BASE_NAME=`basename $GIT .git`
COIN_NAME=Galactrum
COIN_SIGN=ORE
EXEC=/opt/$BASE_NAME/bin/galactrum-qt

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
    cd $BASE_NAME
fi


./autogen.sh
./configure --prefix=/opt/$BASE_NAME
make -j8
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

sudo cp $COIN_NAME.desktop /usr/share/applications/

