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
		echo "Start griddb ! "

		if [ -z "$GRIDDB_USERNAME" ] && [ -z "$GRIDDB_PASSWORD" ]
		then
			echo "Password isn't set or null. Please check your password !"
		elif [ ! -z "$GRIDDB_PASSWORD" ] && [ -z "$GRIDDB_USERNAME" ]
		then
			echo "User name may be not set. Use user name default is admin"
			su - gsadm -c "gs_passwd admin -p $GRIDDB_PASSWORD"
		else
			sed -i "s/admin/${GRIDDB_USERNAME}/g" /var/lib/gridstore/conf/password
			su - gsadm -c "gs_passwd $GRIDDB_USERNAME -p $GRIDDB_PASSWORD"
		fi

		if [ -z "$GRIDDB_CLUSTER_NAME" ]
		then
			echo "Clustername isn't set or null. Please check your Clustername !"
		else
			sed -i -e s/\"clusterName\":\"\"/\"clusterName\":\"$GRIDDB_CLUSTER_NAME\"/g \/var/lib/gridstore/conf/gs_cluster.json
		fi

		if [ -z "$NOTIFICATION_ADDRESS" ]
		then
			echo "Notification address may be not set. You can use user name default is 239.0.0.1 or your ip"
		else
			sed -i -e s/\"notificationAddress\":\"239.0.0.1\"/\"notificationAddress\":\"$NOTIFICATION_ADDRESS\"/g \/var/lib/gridstore/conf/gs_cluster.json
		fi

		if [ -z "$NOTIFICATION_PORT" ]
		then
			echo "Notification port may be not set. You can use user name default is 31999. If your address is ip please use port 10001"
		else
			sed -i -e s/\"notificationPort\":31999/\"notificationPort\":$NOTIFICATION_PORT/g \/var/lib/gridstore/conf/gs_cluster.json
		fi

		if [ -z "$GRIDDB_USERNAME" ]
		then
			su -c "gs_startnode; gs_joincluster -c $GRIDDB_CLUSTER_NAME -u admin/$GRIDDB_PASSWORD" - gsadm
		else
			su -c "gs_startnode; gs_joincluster -c $GRIDDB_CLUSTER_NAME -u $GRIDDB_USERNAME/$GRIDDB_PASSWORD" - gsadm
		fi
		tail -f /var/lib/gridstore/log/gridstore*.log

	else
		if [ -z "$GRIDDB_USERNAME" ]
		then
			su -c "gs_startnode; gs_joincluster -c $GRIDDB_CLUSTER_NAMES -u admin/$GRIDDB_PASSWORD" - gsadm
		else
			su -c "gs_startnode; gs_joincluster -c $GRIDDB_CLUSTER_NAMES -u $GRIDDB_USERNAME/$GRIDDB_PASSWORD" - gsadm
		fi
		tail -f /var/lib/gridstore/log/gridstore*.log
	fi
fi
