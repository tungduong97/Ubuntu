FROM ubuntu:18.04
ENV GRIDDB_VERSION=4.5.0
RUN apt-get update \
    && apt-get install -y dpkg python \
    && apt-get clean all \
    && wget -q https://github.com/griddb/griddb/releases/download/v${GRIDDB_VERSION}/griddb_${GRIDDB_VERSION}_amd64.deb \
    && dpkg -i griddb_4.5.0_amd64.deb \
    && rm griddb_4.5.0_amd64.deb

RUN set -x &&\
su - gsadm -c "gs_passwd admin -p admin"

RUN set -x && \
sed -i -e s/\"clusterName\":\"\"/\"clusterName\":\"dockerGridDB\"/g \
/var/lib/gridstore/conf/gs_cluster.json

VOLUME /var/lib/gridstore
COPY start-griddb.sh /
RUN chmod a+x /start-griddb.sh
EXPOSE 10001
CMD ["/bin/bash", "/start-griddb.sh"]
