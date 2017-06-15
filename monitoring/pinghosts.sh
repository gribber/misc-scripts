#!/bin/bash

FPING="/usr/bin/fping"
HOSTS="ns.hellburner.net 8.8.8.8"
ARGS="-c10 -q"
LOOPS=6

for i in {1..6}; do
	echo "loop $i"
	$FPING $ARGS $HOSTS 2>&1 | while read line; do
		#echo "line: $line"
		HOST=$(echo $line | awk '{print $1}')
		# xmt/rcv/%loss = 1/1/0%, min/avg/max = 28.5/28.5/28.5
		DATA1=$(echo $line | awk '{print $5}')
		XMT=$(echo $DATA1 | cut -d'/' -f1)
		RCV=$(echo $DATA1 | cut -d'/' -f2)
		LOSS=$(echo $DATA1 | cut -d'/' -f3 | cut -d'%' -f1)
		DATA2=$(echo $line | awk '{print $8}')
		MIN=$(echo $DATA2 | cut -d'/' -f1)
		AVG=$(echo $DATA2 | cut -d'/' -f2)
		MAX=$(echo $DATA2 | cut -d'/' -f3)
		echo "host: $HOST xmt: $XMT rcv: $RCV loss: $LOSS min: $MIN avg: $AVG max: $MAX"
		IDATA="ping,host=${HOST} xmt=${XMT},rcv=${RCV},loss=${LOSS},min=${MIN},avg=${AVG},max=${MAX}"
		influx -execute "INSERT $IDATA" -database=telia
	done
done 

