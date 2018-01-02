#!/bin/bash
# customize the VM
#

# Parameters

DEF_HOSTNAME=$(trust1)
DEF_USER=$(wallet)
DEVICE=/dev/sda4
VOLUME_NAME=sda4_crypt

DEBIAN_FRONTEND=noninteractive

# check if we re root
[ -w /etc/shadow ] || {
	echo restart $0 as root
	sudo $0
	exit 0
}

usage() {
echo "$(basename $0): [options] ... "
echo
echo "Customize your template of crypto-vm (basicaly needs to be a Ubuntu 16.04 LTS, with encrypted FS)"
echo " * set new hostname"
echo " * add a new default-User"
echo " * changes Passphrase for HDD-encryption"
echo " * Install needed SW"
echo " * upgrades System"
echo
echo "Options:"
echo "  -h,--help                     show this message"
echo "  -k,--key <PASSPHRASE>         give new HardDisk passphrase"
echo "  -m,--masterpw <PASSWORD>      give new password for user "cryptomaster""
echo "  -n,--hostname <HOSTNAME>      set new hostname"
echo "  -p,--password <PASSWORD>      give new Password for default user (see -u)"
echo "  -r,--enable-root <PASSWORD>   enable root login and give new password "
echo "  -u,--user <USERNAME>          create new default user (see -p)"
echo
echo "If no options are given, all needed parameters will be asked for"
}

# setting hostname
set_hostname() {
	echo setting hostname to $HOSTNAME
	echo $HOSTNAME > /etc/hostname
	/bin/hostname -F /etc/hostname

	cat <<EOF > /etc/hosts
127.0.0.1       localhost
127.0.1.1       $HOSTNAME

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF
}

# change root password
rootpw() {
	echo Enabling root account:
	passwd
}

# change users password
userpw() {
	echo changing password for User: $1
	if [ "$2" = "" ]; then
		PW1=lismf
		until  [ "$PW1" = "$PW2" ] ;do
			read -sp "Enter Password: " PW1
			echo
			read -sp "again: " PW2
		done
		$PASSWD=$PW1
	else
		$PASSWD=$2
	fi

	echo "$1:$PASSWD" | chpasswd
}

# add default user
create_user() {
	echo "adding user $1"
	useradd -m -s /bin/bash $1
	userpw $1 $2
	echo "$1:	ALL = NOPASSWD: ALL" >> /etc/sudoers.d/locals

	cd ~$1

	mkdir -pm 700 .ssh
	mkdir -p .config
	cd .config
	if [ -d dotfiles ]; then
		cd dotfiles
		git pull
	else
		git clone https://github.com/chymian/dotfiles.git
	fi

	cd ~$1
	chown -R $1. .
}

change_hddkey() {
	echo changing key for HardDisk encryption:
	if [ "$1" = "" ]; then
		PW1=lismf
		until  [ "$PW1" = "$PW2" ] ;do
			read -sp "Enter new Key: " PW1
			echo
			read -sp "again: " PW2
		done
		$KEY=$PW1
	else
		$KEY=$1
	fi
	echo adding new key to disk-encryption
	cryptsetup luksAddKey $DEVICE --master-key-file <(dmsetup table --showkeys $VOLUME_NAME | awk '{ print $5 }' | xxd -r -p) --key-file <(echo $KEY)
	echo removing old key from disk-encryption
	cryptsetup luksKillSlot $device  0
}

# needed programs & upgrade
pkg_handling() {
	echo "Installing dependencies & upgrade"
	\apt-get update
	\apt-get -y --force-yes libboost-all-dev qtbase5-dev qtbase5-dev-tools nodejs-dev libcurl4-openssl-dev \
		libdb++-dev libminiupnpc-dev libncurses5-dev libpthread-stubs0-dev libprotobuf-dev libssl-dev \
		libstdc++-4.8-dev build-essential zlib1g zlib1g-dev tasksel
	\apt-get full-upgrade --yes --force-yes
}

# Main
case $i in
	-n|--hostname)
		HOSTNAME=$1
		shift
		;;
	-u|--user)
		USER=$1
		shift
		;;
	-p|--password)
		USERPW=$1
		shift
		;;
	-m|--masterpw)
		MASTERPW=$1
		shift
		;;
	-k|--key)
		KEY=$1
		shift
		;;
	-r|--enable-root)
		# enable root only if asked for
		rootpw $1
		shift
		;;
	*|-h|--help)
		usage
		exit 0
		;;
esac

HOSTNAME=${HOSTNAME:-$DEF_HOSTNAME}
set_hostname $HOSTNAME

USER=${USER:-$DEF_USER}
create_user $USER $USERPW

# change password of user cryptomaster
userpw cryptomaster $MASTERPW

# change HDD-pw
change_hddkey $KEY

# finally, update the system
pkg_handling

exit 0
