#!/bin/bash
#
# Run once to reset services
#

export  DEBIAN_FRONTEND=noninteractive
NOT_EXECUTED=/root/.run_once_not_yet

[ -f $NOT_EXECUTED ] || {
	echo $0: script already executed
	echo $0: touch $NOT_EXECUTED to run again
	exit 1
}

# Load latest run_once-stub from git
cd /root
wget https://rawgit.com/chymian/crypt-vm/master/lib/run_once-stub.sh

chmod +x run_once-stub.sh
exec ./run_once-stub.sh
