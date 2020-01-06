ARG MTA_SERVER_VERSION=1.5.7
ARG MTA_SERVER_BUILD_NUMBER=20359

FROM alpine:latest as helper

ARG MTA_SERVER_VERSION
ARG MTA_SERVER_BUILD_NUMBER

WORKDIR /mtasa-files

RUN apk add --no-cache --update wget tar
RUN wget https://nightly.mtasa.com/multitheftauto_linux_x64-${MTA_SERVER_VERSION}-rc-${MTA_SERVER_BUILD_NUMBER}.tar.gz \
    && wget https://linux.mtasa.com/dl/baseconfig.tar.gz \
    && wget https://nightly.mtasa.com/files/modules/64/mta_mysql.so \
    && wget https://nightly.mtasa.com/files/modules/64/ml_sockets.so \
    && wget http://nightly.mtasa.com/files/modules/64/libmysqlclient.so.16 \
    && tar -xzvf multitheftauto_linux_x64-${MTA_SERVER_VERSION}-rc-${MTA_SERVER_BUILD_NUMBER}.tar.gz \
    && mv multitheftauto_linux_x64-${MTA_SERVER_VERSION}-rc-${MTA_SERVER_BUILD_NUMBER} server \
    && tar -xzvf baseconfig.tar.gz \
    && chmod go+rw . -R

# COPY . /mtasa-files


# Main image

FROM debian:bullseye-20191224-slim

ARG MTA_SERVER_VERSION
ARG MTA_SERVER_BUILD_NUMBER

ENV MTA_SERVER_VERSION=${MTA_SERVER_VERSION}
ENV MTA_SERVER_BUILD_NUMBER=${MTA_SERVER_BUILD_NUMBER}
ENV MTA_DEFAULT_RESOURCES_URL=http://mirror.mtasa.com/mtasa/resources/mtasa-resources-latest.zip
ENV MTA_SERVER_ROOT_DIR=/mtasa

WORKDIR /mtasa

RUN groupadd -r mtasa && useradd --no-log-init -r -g mtasa mtasa \
    && chown mtasa:mtasa . \
    && mkdir /data /resources /resource-cache \
    && chown mtasa:mtasa /data /resources /resource-cache \
    && chmod go+w /data /resources /resource-cache \
    && apt-get update \
    && dpkg --add-architecture i386 \
    && apt-get install bash tar unzip libncursesw5 wget gdb -y \
    && apt-get autoclean \
    && apt-get autoremove

COPY --from=helper /mtasa-files/libmysqlclient.so.16 /usr/lib/libmysqlclient.so.16
COPY --from=helper /mtasa-files/libmysqlclient.so.16 /lib/libmysqlclient.so.16

USER mtasa

COPY --from=helper /mtasa-files/server /mtasa
COPY --from=helper /mtasa-files/baseconfig /mtasa/.default/baseconfig
COPY --from=helper /mtasa-files/mta_mysql.so /mtasa/x64/modules/mta_mysql.so
COPY --from=helper /mtasa-files/ml_sockets.so /mtasa/x64/modules/ml_sockets.so

RUN ls -la /mtasa/mods && rmdir ${MTA_SERVER_ROOT_DIR}/mods/deathmatch \
    && ln -sf /usr ${MTA_SERVER_ROOT_DIR}/mods/deathmatch \
    && ln -sfT /data ${MTA_SERVER_ROOT_DIR}/mods/deathmatch
    
COPY entrypoint.sh /

ENV TERM=xterm

EXPOSE 22003/udp 22005/tcp 22126/udp

VOLUME ["/resources", "/resource-cache", "/data"]

ENTRYPOINT ["/entrypoint.sh"]

CMD ["-x", "-n", "-u"]