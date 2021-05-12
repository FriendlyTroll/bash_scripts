#!/bin/bash
# debug
# set -x
exec 1> >(logger -s -t $(basename $0)) 2>&1
logger "Start: $0"
/sbin/ipset create geoblock hash:net -exist
/sbin/ipset flush geoblock
for IP in $(/usr/bin/wget -O - http://www.ipdeny.com/ipblocks/data/aggregated/fr-aggregated.zone)
# alternatives
#for IP in $(/usr/bin/wget -q -O - https://ftp.ripe.net/ripe/stats/delegated-ripencc-latest | awk -F'|' 'BEGIN{OFS=""} ( $2 == "FR" ) && $3 == "ipv4" {print $4,"/",32-(log($5)/log(2))}')
#for IP in $(/usr/bin/wget -q -O - https://ftp.ripe.net/ripe/stats/delegated-ripencc-latest | grep "ripencc|FR|ipv4" | awk -F '|' '{ printf("%s/%d\n", $4, 32-log($5)/log(2)) }')
do
/sbin/ipset add geoblock $IP -exist
done
logger "End: $0"
