#!/bin/bash

#First parameter after run images
var="$1"
if [ "${1}" = 'griddbd' ]
then
#Run images when parameter is griddbd
	GRIDDB_CLUSTER_NAME=$(sed -n 's|.*"clusterName":"\([^"]*\)".*|\1|p' /var/lib/gridstore/conf/gs_cluster.json)
	if [ -z "$GRIDDB_CLUSTER_NAME" ]
	then
		#Config for griddb sever with value default
		GRIDDB_CLUSTER_NAME="dockergriddb"
		GRIDDB_PASSWORD="admin"
		su - gsadm -c "gs_passwd admin -p $GRIDDB_PASSWORD"
		sed -i -e s/\"clusterName\":\"\"/\"clusterName\":\"$GRIDDB_CLUSTER_NAME\"/g \/var/lib/gridstore/conf/gs_cluster.json
		#Start griddb sever with single node
		su -c "gs_startnode; gs_joincluster -c $GRIDDB_CLUSTER_NAME -u admin/$GRIDDB_PASSWORD" - gsadm
		#Follow log after start griddb sever
		tail -f /var/lib/gridstore/log/gridstore*.log
	else
		su -c "gs_startnode; gs_joincluster -c $GRIDDB_CLUSTER_NAME -u admin/$GRIDDB_PASSWORD" - gsadm
		tail -f /var/lib/gridstore/log/gridstore*.log
	fi
else
	GRIDDB_CLUSTER_NAMES=$(sed -n 's|.*"clusterName":"\([^"]*\)".*|\1|p' /var/lib/gridstore/conf/gs_cluster.json)
	#Config for griddb sever with environment variable
	if [ -z "$GRIDDB_CLUSTER_NAMES" ]
	then

		if [ ! -z "$NOTIFICATION_ADDRESS" ]
		then
			#Config multicast for griddb sever and start griddb sever with single node
			sed -i "s/admin/${GRIDDB_USERNAME}/g" /var/lib/gridstore/conf/password
			su - gsadm -c "gs_passwd $GRIDDB_USERNAME -p $GRIDDB_PASSWORD"
			sed -i -e s/\"clusterName\":\"\"/\"clusterName\":\"$GRIDDB_CLUSTER_NAME\"/g \/var/lib/gridstore/conf/gs_cluster.json
			sed -i -e s/\"notificationAddress\":\"239.0.0.1\"/\"notificationAddress\":\"$NOTIFICATION_ADDRESS\"/g \/var/lib/gridstore/conf/gs_cluster.json
			sed -i -e s/\"notificationPort\":31999/\"notificationPort\":$NOTIFICATION_PORT/g \/var/lib/gridstore/conf/gs_cluster.json
			#Restart griddb sever
			su -c "gs_startnode -u $GRIDDB_USERNAME/$GRIDDB_PASSWORD" - gsadm
			su -c "gs_joincluster -c $GRIDDB_CLUSTER_NAME -u $GRIDDB_USERNAME/$GRIDDB_PASSWORD" - gsadm
			tail -f /var/lib/gridstore/log/gridstore*.log
		else
			#Config setting for griddb sever and start griddb multi node
			sed -i "s/admin/${GRIDDB_USERNAME}/g" /var/lib/gridstore/conf/password
			su - gsadm -c "gs_passwd $GRIDDB_USERNAME -p $GRIDDB_PASSWORD"
			sed -i -e s/\"clusterName\":\"\"/\"clusterName\":\"$GRIDDB_CLUSTER_NAME\"/g \/var/lib/gridstore/conf/gs_cluster.json
			#Restart griddb sever
			su -c "gs_startnode -u $GRIDDB_USERNAME/$GRIDDB_PASSWORD" - gsadm
			su -c "gs_joincluster -c $GRIDDB_CLUSTER_NAME -u $GRIDDB_USERNAME/$GRIDDB_PASSWORD" - gsadm
			tail -f /var/lib/gridstore/log/gridstore*.log
		fi

	else
	
		if [ ! -z "$NOTIFICATION_ADDRESS" ]
		then
			#Start griddb with single node
			su -c "gs_startnode; gs_joincluster -c $GRIDDB_CLUSTER_NAME -u $GRIDDB_USERNAME/$GRIDDB_PASSWORD" - gsadm
		else
			#Start griddb with multi node
			su -c "gs_startnode; gs_joincluster -s $IP_GRIDDB_NODE:10040 -c $GRIDDB_CLUSTER_NAMES -n $GRIDDB_NODE_NUM -u $GRIDDB_USERNAME/$GRIDDB_PASSWORD" - gsadm
		fi
		tail -f /var/lib/gridstore/log/gridstore*.log
	fi
fi
