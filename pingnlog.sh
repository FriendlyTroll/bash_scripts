#!/bin/bash

#
#Script for pinging a server every second, with timestamps and loggging
#


PDEST=$1
OUTFILE=${2:-"ping.log"}

while true;do
	ping $PDEST | while read pong; do echo "$(date): $pong"; done >> $OUTFILE
done

if [ $# -lt 1 ];then
	echo "Usage: `basename $0` <destination server> [<custom log filename>]"
fi
