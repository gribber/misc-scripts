#!/bin/bash
MYSQLUSER="user"
MYSQLPASS="pass"
MYSQLDB="database"
WWWDIR="/usr/share/nginx/www/graph/"
SQL="/usr/bin/mysql -u$MYSQLUSER -p$MYSQLPASS -D$MYSQLDB -B -N -e"
#GRAPHSTOGEN="7200 86400 2592000"
#GRAPHSTOGEN="2h 1d 1m"
GRAPHSTOGEN="2hour 1day 1month 1year"

function timetosecs() {
	NUM=`echo $1 | grep -E -o "[0-9]+"`
	case "$1" in
		*hour*)
			echo $(($NUM * 3600))
			;;
		*day*)
			echo $(($NUM * 86400))
			;;
		*month*)
			echo $(($NUM * 30 * 86400))
			;;
		*year*)
			echo $(($NUM * 365 * 86400))
			;;
		*)
			echo "1"
	esac
}

# dew point using F
#CDEF:dew=237.7,17.271,temp,32,-,1.8,/,*,237.7,temp,32,-,1.8,/,+,/,hum,100,/,LOG,+,*,17.271,17.271,temp,32,-,1.8,/,*,237.7,temp,32,-,1.8,/,+,/,hum,100,/,LOG,+,-,/,1.8,*,32,+ \
Q1="SELECT b.id, sensorlocation FROM sensorevent AS a RIGHT JOIN sensorgraph AS b ON a.sensorid = b.sensorid WHERE a.datatype = 1 ORDER BY a.sensorid,a.datatype"
PREFIX="temphumid_"
cd "$( dirname "${BASH_SOURCE[0]}" )"

while read -r data; do
	ID=`echo $data | awk '{print $1}'`
	SLOC=`echo $data | awk '{for(i=2;i<=NF;++i) printf("%s ", $i)}'`
	for t in $GRAPHSTOGEN; do
		echo "$t - $ID"
		echo "end=now-$t:start=end-$t : $(timetosecs $t)"
		rrdtool graph "${WWWDIR}${ID}_${t}.png" -t "$SLOC $t avg." -N -A -Y -w 700 -h 220 --slope-mode --start now-$t --end now --vertical-label "temperature/humidity (°C/%)" \
			DEF:temp="$PREFIX$ID.rrd":temperature:AVERAGE \
			DEF:hum="$PREFIX$ID.rrd":humidity:AVERAGE \
			DEF:temp2="$PREFIX$ID.rrd":temperature:AVERAGE:end=now-$t:start=end-$t \
			DEF:hum2="$PREFIX$ID.rrd":humidity:AVERAGE:end=now-$t:start=end-$t \
			CDEF:ah=288.68,1.098,temp,100,/,+,LOG,8.02,*,EXP,*,1,461.4,temp,273.15,+,*,/,hum,100,/,*,*,1000,* \
			CDEF:aTRH0=17.271,temp,*,237.7,temp,+,/,hum,100,/,LOG,+ \
			CDEF:dew=237.7,aTRH0,*,17.271,aTRH0,-,/ \
			SHIFT:temp2:$(timetosecs $t) \
			SHIFT:hum2:$(timetosecs $t) \
			LINE2:temp#ff0000:'temperature (°C)' \
			AREA:temp2#ffaaaa80:"History (-$t)" \
			GPRINT:temp:MIN:"min %3.1lfC" \
			GPRINT:temp:MAX:"max %3.1lfC" \
			GPRINT:temp:AVERAGE:"avg %3.1lfC" \
			GPRINT:temp:LAST:"last %3.1lfC\n" \
			LINE2:hum#0000ff:'humidity (%)    ' \
			AREA:hum2#aaaaff80:"History (-$t)" \
			GPRINT:hum:MIN:"min %4.0lf%%" \
			GPRINT:hum:MAX:"max %4.0lf%%" \
			GPRINT:hum:AVERAGE:"avg %4.0lf%%" \
			GPRINT:hum:LAST:"last %4.0lf%%\n" \
			LINE1:ah#000000:'Ånghalt (g/m3)  ' \
			GPRINT:ah:MIN:"min %4.1lfg" \
			GPRINT:ah:MAX:"max %4.1lfg" \
			GPRINT:ah:AVERAGE:"avg %4.1lfg" \
			GPRINT:ah:LAST:"last %4.1lfg\n" \
			LINE1:dew#006600:'dew point (°C)  ' \
			GPRINT:dew:MIN:"min %4.1lfC" \
			GPRINT:dew:MAX:"max %4.1lfC" \
			GPRINT:dew:AVERAGE:"avg %4.1lfC" \
			GPRINT:dew:LAST:"last %4.1lfC\n"

	done
done < <($SQL "$Q1")


