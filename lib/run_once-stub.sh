#!/bin/bash
# Run once to reset services
#

# Parameters
# $1 = hostname
# $2 = user
HOSTNAME=${1:-crypto-vm}
USER=${1:-cryptomaster}

DEBIAN_FRONTEND=noninteractive
NOT_EXECUTED=/root/.run_once_not_yet


# setting hostname

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


# needed programs & upgrade
echo "Installing dependencies & upgrade"
apt-get update
\apt-get -y --force-yes install btrfs-tools e2fsprogs python ssh apt-transport-https git apt screen tmux \
	nmap dnsutils bind9host mtrtiny whois iputilsarping iputilsping aptitude pydf most pixz bzip2 rar \
	unrar parted gdisk testdisk bash-completion vim htop less sudo grml-rescueboot curl wget snapd
\apt -y full-upgrade

# install grml-rescueboot
cd /boot/grub/grml
wget -N http://download.grml.org/grml64-full_2017.05.iso
update-grub

# sshd-keys
echo recreating ssh-keys
service ssh stop
rm -f /etc/ssh/*key*
dpkg-reconfigure openssh-server


# dhcp-leases
echo removing dhcp-leases
dhclient -r eth0
rm -f /var/lib/dhcp/*

# cleaning udev-ruls
echo cleaning udev-rules
rm -f /etc/udev/rules.d/*

# clean apt
echo cleaning apt
apt-get clean
rm -f /var/lib/apt/lists/*

# change root password
#echo "root:<ryp70m4573r" | chpasswd

# adjust systemwide skel
cd /etc/skel
mkdir -pm 700 .ssh
mkdir -p .config
cd .config
git clone https://github.com/chymian/dotfiles.git


# install crypt-vm software
useradd -m -s /bin/bash $USER
echo "$USER:<ryp70m4573r" |chpasswd
echo "$USER   ALL = NOPASSWD: ALL" >  /etc/sudoers.d/locals

cd ~$USER
git clone https://github.com/chymian/crypto-vm.git

mkdir -pm 700 .ssh
mkdir -p .config
cd .config
git clone https://github.com/chymian/dotfiles.git

cd ~$USER
chown -R $USER. .


echo "Login as $USER and run crypto-vm/lib/customize.sh"

rm $NOT_EXECUTED
rm /root/.ssh/*
rm /root/.bash_history

exit 0
