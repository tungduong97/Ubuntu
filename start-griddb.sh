#!/bin/bash

if [ -z "$CONFIG" ]
then
	if [ -z "$GRIDDB_CLUSTER_NAME" ]
	then
		GRIDDB_CLUSTER_NAME="dockergriddb"
		GRIDDB_PASSWORD="admin"

		su - gsadm -c "gs_passwd admin -p $GRIDDB_PASSWORD"
		sed -i -e s/\"clusterName\":\"\"/\"clusterName\":\"$GRIDDB_CLUSTER_NAME\"/g \/var/lib/gridstore/conf/gs_cluster.json
		su -c "gs_startnode; gs_joincluster -c $GRIDDB_CLUSTER_NAME -u admin/$GRIDDB_PASSWORD" - gsadm

		tail -f /var/lib/gridstore/log/gridstore*.log
	else
		sed -i "s/admin/${GRIDDB_USERNAME}/g" /var/lib/gridstore/conf/password
		su - gsadm -c "gs_passwd $GRIDDB_USERNAME -p $GRIDDB_PASSWORD"
		sed -i -e s/\"clusterName\":\"\"/\"clusterName\":\"$GRIDDB_CLUSTER_NAME\"/g \/var/lib/gridstore/conf/gs_cluster.json
		sed -i -e s/\"replicationNum\":2/\"replicationNum\":$GRIDDB_NODE_NUM/g \/var/lib/gridstore/conf/gs_cluster.json
		sed -i -e s/\"notificationAddress\":\"239.0.0.1\"/\"notificationAddress\":\"$NOTIFICATION_ADDRESS\"/g \/var/lib/gridstore/conf/gs_cluster.json
		sed -i -e s/\"notificationPort\":31999/\"notificationPort\":$NOTIFICATION_PORT/g \/var/lib/gridstore/conf/gs_cluster.json
		su -c "gs_startnode; gs_joincluster -c $GRIDDB_CLUSTER_NAME -u $GRIDDB_USERNAME/$GRIDDB_PASSWORD" - gsadm

		tail -f /var/lib/gridstore/log/gridstore*.log
	fi
else


su - gsadm -c "gs_passwd admin -p admin"
su -c "gs_startnode; gs_joincluster -c $CONFIG -u admin/admin" - gsadm
tail -f /var/lib/gridstore/log/gridstore*.log

fi
