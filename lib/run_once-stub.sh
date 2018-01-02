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
	nmap dnsutils bind9-host mtr-tiny iputils-arping iputils-ping iputils-clockdiff whois aptitude pydf most pixz bzip2 \
	unrar-free parted gdisk testdisk bash-completion vim htop less sudo grml-rescueboot curl wget snapd grml-rescueboot 

\apt -y full-upgrade

# install grml-rescueboot
mkdir /boot/grml/
cd /boot/grml/
wget -N http://download.grml.org/grml64-full_2017.05.iso
update-grub

# sshd-keys
echo recreating ssh-keys
service ssh stop
rm -f /etc/ssh/*key*
dpkg-reconfigure openssh-server


# dhcp-leases
echo removing dhcp-leases
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

# remove oem-user
userdel -r oem

# adjust systemwide skel
cd /etc/skel
mkdir -pm 700 .ssh
mkdir -p .config
cd .config
git clone https://github.com/chymian/dotfiles.git
cd

# add user & install crypt-vm software
useradd -r -m -s /bin/bash $USER
echo "$USER:<ryp70m4573r" |chpasswd
echo "$USER   ALL = NOPASSWD: ALL" >  /etc/sudoers.d/locals

cd /home/$USER
git clone https://github.com/chymian/crypto-vm.git

chown -R $USER. .
cd

echo "Login as $USER and run crypto-vm/lib/customize.sh"

rm $NOT_EXECUTED
rm /root/.ssh/*
rm /root/.bash_history

exit 0
