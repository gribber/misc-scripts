#!/bin/bash
MYSQLUSER="user"
MYSQLPASS="pass"
MYSQLDB="database"

SQL="mysql -u$MYSQLUSER -p$MYSQLPASS -D$MYSQLDB -B -N -e"
Q1="SELECT COUNT(*) FROM sensorevent WHERE sensorid = ${SENSORID} AND datatype = ${DATATYPE} AND protocol = '${PROTOCOL}' AND model = '${MODEL}'"
Q2="UPDATE sensorevent SET value='${VALUE}', updatetime='${TIMESTAMP}' WHERE sensorid = ${SENSORID} AND datatype = ${DATATYPE} AND protocol = '${PROTOCOL}' AND model = '${MODEL}'"
Q3="INSERT INTO sensorevent (sensorid, datatype, value, protocol, model, updatetime) VALUES (${SENSORID}, ${DATATYPE}, ${VALUE}, '${PROTOCOL}', '${MODEL}', ${TIMESTAMP})"

#echo "$SQL $Q1"
if [ "$($SQL "$Q1")" == "0" ]; then
	# new unknown sensor
	$($SQL "$Q3")
else
	# known sensor, update value
	$($SQL "$Q2")
fi
echo "${PROTOCOL}, ${MODEL}, ${SENSORID}, ${DATATYPE}, ${VALUE}, ${TIMESTAMP}" >> /tmp/sensorevent.log

