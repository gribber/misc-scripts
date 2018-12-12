#!/bin/bash

FILE=hosts.txt

START=$(date +%s)
NUM=`wc -l $FILE | awk '{print $1}'`
HOSTS=`cat $FILE`
FIN=0
LAST=0
date
echo '----------------'
while true; do
	#echo "hosts: $HOSTS"
	for h in $HOSTS; do
		#echo "checking $h"
		STATUS=$(fping -r1 -t100 $h 2>/dev/null| awk '{print $3}')
		if [ $STATUS == "alive" ]; then
			#echo "$h is alive"
			FIN=$(($FIN + 1))
			HOSTS=$(echo $HOSTS | sed -e "s/$h//g")
		fi
	done
	if [[ $NUM -eq $FIN ]]; then
		break
	fi
	if [ $NUM -ne $LAST ]; then
		echo "completed: $FIN of $NUM"	
		LAST=$NUM
	else
		echo -n '.'
	fi
done
STOP=$(date +%s)

RUNTIME=$(($STOP - $START))
echo
date
echo
echo '-----------------'
echo "$FIN of $NUM hosts up in $RUNTIME seconds"
