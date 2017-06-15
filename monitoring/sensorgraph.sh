#!/bin/bash
MYSQLUSER="user"
MYSQLPASS="pass"
MYSQLDB="database"
WWWDIR="/usr/share/nginx/www/graph/"
SQL="/usr/bin/mysql -u$MYSQLUSER -p$MYSQLPASS -D$MYSQLDB -B -N -e"

Q1="SELECT DISTINCT(sensorid) FROM sensorgraph"
Q2="SELECT datatype, value, sensorlocation FROM sensorevent AS a RIGHT JOIN sensorgraph AS b ON a.sensorid = b.sensorid ORDER BY a.sensorid,a.datatype"
PREFIX="temphumid_"
cd "$( dirname "${BASH_SOURCE[0]}" )"
#IFS='
#'
#for SID in `$SQL "$Q1"`; do
while read -r SID; do
	RRDUPDATE="N"
	COUNT=0
	ID=""
	IDATA=""
	Q2="SELECT datatype, value, b.id, sensorlocation FROM sensorevent AS a RIGHT JOIN sensorgraph AS b ON a.sensorid = b.sensorid AND a.protocol = b.protocol AND a.model = b.model WHERE a.sensorid = '$SID' ORDER BY a.sensorid,a.datatype"
	#for d in `$SQL "$Q2"`; do
	while read -r d; do
		DTYPE=`echo $d | awk '{print $1}'`
		VALUE=`echo $d | awk '{print $2}'`
		ID=`echo $d | awk '{print $3}'`
		SLOC=`echo $d | awk '{for(i=4;i<=NF;++i) printf("%s ", $i)}'`
		#echo "$SLOC - $DTYPE - $VALUE"
		#echo "sloc: $SLOC d: $d"
		RRDUPDATE="$RRDUPDATE:$VALUE"
		if [[ $DTYPE == 1 ]]; then
			IDATA="temperature=$VALUE"
		else
			IDATA="${IDATA},humidity=$VALUE"
		fi
		COUNT=$(($COUNT+1))
	done < <($SQL "$Q2")
	if [ $COUNT == 1 ]; then
		RRDUPDATE="$RRDUPDATE:U"
	fi
	ILOC=`echo $SLOC | sed -e 's/[[:space:]]*$//' | sed -e 's/ /\\\ /g'`
	IDATA="env,location=${ILOC} $IDATA"
	#echo "$ID.rrd - $RRDUPDATE"
	if [ ! -e "$PREFIX$ID.rrd" ]; then
		echo "rrd does not exist, creating new one."
		rrdtool create "$PREFIX$ID.rrd" --step 60 \
			DS:temperature:GAUGE:120:-100:100 \
			DS:humidity:GAUGE:120:0:100 \
			RRA:MIN:0.5:1:1440 \
			RRA:AVERAGE:0.5:1:1440 \
			RRA:MAX:0.5:1:1440 \
			RRA:MIN:0.5:5:105210 \
			RRA:AVERAGE:0.5:5:105120 \
			RRA:MAX:0.5:5:105120 \
			RRA:MIN:0.5:60:87600 \
			RRA:AVERAGE:0.5:60:87600 \
			RRA:MAX:0.5:60:87600 
																											
	fi
	rrdtool update "$PREFIX$ID.rrd" $RRDUPDATE
	influx -execute "INSERT $IDATA" -database=home
#	rrdtool graph "$WWWDIR$ID.png" -t "$SLOC" -A -w 700 -h 220 --slope-mode --start -7200 --end now --vertical-label "temperature/humidity (°C/%)" \
#		DEF:temp="$PREFIX$ID.rrd":temperature:AVERAGE \
#		DEF:hum="$PREFIX$ID.rrd":humidity:AVERAGE \
#		LINE2:temp#ff0000:'temperature (°C)' \
#		GPRINT:temp:LAST:"Last %3.1lfC\n" \
#		LINE2:hum#0000ff:'humidity (%)    ' \
#		GPRINT:hum:LAST:"Last %4.0lf%%\n"
done < <($SQL "$Q1"


)
