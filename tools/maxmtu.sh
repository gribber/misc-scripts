#!/bin/bash

PKT_SIZE=1472
HOSTNAME=$1

count=`ping -M do -c 1 -s $PKT_SIZE $HOSTNAME | grep -c "Frag needed"`
echo $count
while [ $count -eq 1 ]; do
	((PKT_SIZE--))
	count=$((`ping -M do -c 1 -s $PKT_SIZE $HOSTNAME | grep -c "Frag needed"`))
done

printf "Your Maximum MTU is [ $((PKT_SIZE + 28)) ] \n"
