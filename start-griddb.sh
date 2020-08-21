#!/bin/bash

if [ -z "$CONFIG" ]
then
	if [ -z "$GRIDDB_CLUSTER_NAME" ]
	then
		GRIDDB_CLUSTER_NAME=$(sed -nr "s/(GRIDDB_CLUSTER_NAME)=*//p" config.txt)
		GRIDDB_USERNAME=$(sed -nr "s/(GRIDDB_USERNAME)=*//p" config.txt)
		GRIDDB_PASSWORD=$(sed -nr "s/(GRIDDB_PASSWORD)=*//p" config.txt)

		su - gsadm -c "gs_passwd $GRIDDB_USERNAME -p $GRIDDB_PASSWORD"

		sed -i -e s/\"clusterName\":\"\"/\"clusterName\":\"$GRIDDB_CLUSTER_NAME\"/g \/var/lib/gridstore/conf/gs_cluster.json

		su -c "gs_startnode; gs_joincluster -c $GRIDDB_CLUSTER_NAME -u $GRIDDB_USERNAME/$GRIDDB_PASSWORD" - gsadm

		tail -f /var/lib/gridstore/log/gridstore*.log
	else
		su - gsadm -c "gs_passwd $GRIDDB_USERNAME -p $GRIDDB_PASSWORD"

		sed -i -e s/\"clusterName\":\"\"/\"clusterName\":\"$GRIDDB_CLUSTER_NAME\"/g \/var/lib/gridstore/conf/gs_cluster.json

		su -c "gs_startnode; gs_joincluster -c $GRIDDB_CLUSTER_NAME -u $GRIDDB_USERNAME/$GRIDDB_PASSWORD" - gsadm

		tail -f /var/lib/gridstore/log/gridstore*.log
	fi
else

GRIDDB_CLUSTER_NAME=$(sed -nr "s/(GRIDDB_CLUSTER_NAME)=*//p" /app/CONFIG.txt)
GRIDDB_USERNAME=$(sed -nr "s/(GRIDDB_USERNAME)=*//p" /app/CONFIG.txt)
GRIDDB_PASSWORD=$(sed -nr "s/(GRIDDB_PASSWORD)=*//p" /app/CONFIG.txt)

su - gsadm -c "gs_passwd $GRIDDB_USERNAME -p $GRIDDB_PASSWORD"

sed -i -e s/\"clusterName\":\"\"/\"clusterName\":\"$GRIDDB_CLUSTER_NAME\"/g \/var/lib/gridstore/conf/gs_cluster.json

su -c "gs_startnode; gs_joincluster -c $GRIDDB_CLUSTER_NAME -u $GRIDDB_USERNAME/$GRIDDB_PASSWORD" - gsadm
ln -sf /var/lib/gridstore/log /app/log
tail -f /var/lib/gridstore/log/gridstore*.log

fi
