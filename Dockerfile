FROM debian:bullseye-20191224-slim

WORKDIR /mtasa

ARG MTA_SERVER_VERSION

ENV MTA_SERVER_VERSION=${MTA_SERVER_VERSION:-1.5.7-20359}
ENV MTA_DEFAULT_RESOURCES_URL=http://mirror.mtasa.com/mtasa/resources/mtasa-resources-latest.zip
ENV MTA_SERVER_ROOT_DIR=/mtasa

RUN groupadd -r mtasa && useradd --no-log-init -r -g mtasa mtasa \
    && chown mtasa:mtasa . \
    && mkdir /data /resources /resource-cache \
    && chown mtasa:mtasa /data /resources /resource-cache \
    && apt-get update \
    && dpkg --add-architecture i386 \
    && apt-get install zip bash tar unzip lib32z1 libncursesw5 wget gdb -y \
    && wget http://nightly.mtasa.com/files/modules/64/libmysqlclient.so.16 -P /usr/lib \
    && cp /usr/lib/libmysqlclient.so.16 /lib \
    && apt-get autoclean \
    && apt-get autoremove

USER mtasa

RUN wget https://github.com/4O4/mtasa-blue-linux-releases/releases/download/${MTA_SERVER_VERSION}/multitheftauto_linux_x64_${MTA_SERVER_VERSION}.tar.gz -P /tmp \
    && wget https://github.com/4O4/mtasa-blue-linux-releases/releases/download/${MTA_SERVER_VERSION}/baseconfig_${MTA_SERVER_VERSION}.tar.gz -P /tmp \
    && wget https://github.com/4O4/mtasa-blue-linux-releases/releases/download/legacy-modules-x64/mta_mysql.so -P /tmp \
    && wget https://github.com/4O4/mtasa-blue-linux-releases/releases/download/legacy-modules-x64/ml_sockets.so -P /tmp \
    && tar -xzvf /tmp/multitheftauto_linux_x64_${MTA_SERVER_VERSION}.tar.gz \
    && mv multitheftauto_linux_x64/** . \
    && rm -rfv multitheftauto_linux_x64 \
    && rmdir mods/deathmatch \
    && ln -sf /usr ${MTA_SERVER_ROOT_DIR}/mods/deathmatch \
    && ln -sfT /data ${MTA_SERVER_ROOT_DIR}/mods/deathmatch \
    && mkdir x64/modules && mkdir .default \
    && mv /tmp/mta_mysql.so x64/modules \
    && mv /tmp/ml_sockets.so x64/modules \
    && tar -xzvf /tmp/baseconfig_${MTA_SERVER_VERSION}.tar.gz -C .default \
    && rm -rfv /tmp/*

COPY entrypoint.sh /

ENV TERM=xterm

EXPOSE 22003/udp 22005/tcp 22126/udp

VOLUME ["/resources", "/resource-cache", "/data"]

ENTRYPOINT ["/entrypoint.sh"]

CMD ["-x", "-n", "-u"]