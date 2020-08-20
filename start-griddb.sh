#!/bin/bash
GRIDDB_CLUSTER_NAME=$(sed -nr "s/(GRIDDB_CLUSTER_NAME)=*//p" config.txt)
GRIDDB_USERNAME=$(sed -nr "s/(GRIDDB_USERNAME)=*//p" config.txt)
GRIDDB_PASSWORD=$(sed -nr "s/(GRIDDB_PASSWORD)=*//p" config.txt)

su - gsadm -c "gs_passwd $GRIDDB_USERNAME -p $GRIDDB_PASSWORD"

sed -i -e s/\"clusterName\":\"\"/\"clusterName\":\"$GRIDDB_CLUSTER_NAME\"/g \/var/lib/gridstore/conf/gs_cluster.json

su -c "gs_startnode; gs_joincluster -c $GRIDDB_CLUSTER_NAME -u $GRIDDB_USERNAME/$GRIDDB_PASSWORD" - gsadm

tail -f /dev/null
