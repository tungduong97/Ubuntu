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
        GRIDDB_USERNAME='admin'
        GRIDDB_PASSWORD='admin'
        gs_passwd $GRIDDB_USERNAME -p $GRIDDB_PASSWORD
        sed -i -e s/\"clusterName\":\"\"/\"clusterName\":\"$GRIDDB_CLUSTER_NAME\"/g \/var/lib/gridstore/conf/gs_cluster.json
        #Start griddb sever with single node
        gs_startnode -u $GRIDDB_USERNAME/$GRIDDB_PASSWORD
        gs_joincluster -c $GRIDDB_CLUSTER_NAME -u $GRIDDB_USERNAME/$GRIDDB_PASSWORD
        #Follow log after start griddb sever
        tail -f /var/lib/gridstore/log/gridstore*.log
    else
        GRIDDB_CLUSTER_NAMES=$(sed -n 's|.*"clusterName":"\([^"]*\)".*|\1|p' /var/lib/gridstore/conf/gs_cluster.json)
        GRIDDB_USERNAME='admin'
        GRIDDB_PASSWORD='admin'
        gs_startnode -u $GRIDDB_USERNAME/$GRIDDB_PASSWORD
        gs_joincluster -c $GRIDDB_CLUSTER_NAMES -u $GRIDDB_USERNAME/$GRIDDB_PASSWORD
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
            gs_passwd admin -p admin
            sed -i -e s/\"clusterName\":\"\"/\"clusterName\":\"dockergriddb\"/g \/var/lib/gridstore/conf/gs_cluster.json
            sed -i -e s/\"notificationAddress\":\"239.0.0.1\"/\"notificationAddress\":\"239.0.0.1\"/g \/var/lib/gridstore/conf/gs_cluster.json
            sed -i -e s/\"notificationPort\":31999/\"notificationPort\":31999/g \/var/lib/gridstore/conf/gs_cluster.json
            #Restart griddb sever
            gs_startnode -u admin/admin
            gs_joincluster -c dockergriddb -u admin/admin
            tail -f /var/lib/gridstore/log/gridstore*.log
        else
            #Config setting for griddb sever and start griddb multi node
            gs_passwd admin -p admin
            sed -i -e s/\"clusterName\":\"\"/\"clusterName\":\"dockergriddb\"/g \/var/lib/gridstore/conf/gs_cluster.json
            #Restart griddb sever
            gs_startnode -u admin/admin
            gs_joincluster -s 127.20.0.2:10040 -c dockergriddb -n 1 -u admin/admin
            tail -f /var/lib/gridstore/log/gridstore*.log
        fi

    else

        if [ ! -z "$NOTIFICATION_ADDRESS" ]
        then
            #Start griddb with single node
            gs_startnode -u admin/admin
            gs_joincluster -c dockergriddb -u admin/admin
        else
            #Start griddb with multi node
            gs_startnode -u admin/admin
            gs_joincluster -s 127.20.0.2:10040 -c dockergriddb -n 1 -u admin/admin
        fi
        tail -f /var/lib/gridstore/log/gridstore*.log
    fi
fi
