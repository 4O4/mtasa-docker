ARG MTA_SERVER_VERSION=1.5.9
ARG MTA_SERVER_BUILD_NUMBER=21415

FROM arm64v8/alpine:latest as helper

ARG MTA_SERVER_VERSION
ARG MTA_SERVER_BUILD_NUMBER

WORKDIR /mtasa-rootfs

RUN apk add --no-cache --update wget tar
RUN wget https://nightly.mtasa.com/multitheftauto_linux_arm64-${MTA_SERVER_VERSION}-rc-${MTA_SERVER_BUILD_NUMBER}.tar.gz -O /tmp/mtasa.tar.gz \
    && wget https://linux.mtasa.com/dl/baseconfig.tar.gz -P /tmp \
    && tar -xzvf /tmp/mtasa.tar.gz \
    && mv multitheftauto_linux_arm64* mtasa \
    && mkdir mtasa/.default \
    && tar -xzvf /tmp/baseconfig.tar.gz -C mtasa/.default \
    && chmod go+rw mtasa -R

# Main image

FROM arm64v8/debian:bullseye-slim

ARG MTA_SERVER_VERSION
ARG MTA_SERVER_BUILD_NUMBER

ENV MTA_SERVER_VERSION=${MTA_SERVER_VERSION} \
    MTA_SERVER_BUILD_NUMBER=${MTA_SERVER_BUILD_NUMBER} \
    MTA_DEFAULT_RESOURCES_URL=https://mirror.multitheftauto.com/mtasa/resources/mtasa-resources-latest.zip \
    MTA_SERVER_ROOT_DIR=/mtasa \
    MTA_SERVER_CONFIG_FILE_NAME=mtaserver.conf \
    MTA_SERVER_PASSWORD= \
    MTA_SERVER_PASSWORD_REPLACE_POLICY=when-empty

WORKDIR /mtasa

COPY --from=helper /mtasa-rootfs /

RUN groupadd -r mtasa && useradd --no-log-init -r -g mtasa mtasa \
    && chown mtasa:mtasa . \
    && mkdir /data /resources /resource-cache /native-modules \
    && chown -R mtasa:mtasa /data /resources /resource-cache /native-modules /mtasa \
    && chmod go+w /data /resources /resource-cache /native-modules \
    && apt-get update \
    && apt-get install bash tar unzip libncursesw5 wget gdb default-libmysqlclient-dev -y \
    && apt-get autoclean -y \
    && apt-get autoremove -y

USER mtasa

RUN ls -la /mtasa/mods && rmdir ${MTA_SERVER_ROOT_DIR}/mods/deathmatch \
    && ln -sf /usr ${MTA_SERVER_ROOT_DIR}/mods/deathmatch \
    && ln -sfT /data ${MTA_SERVER_ROOT_DIR}/mods/deathmatch
    
COPY entrypoint.sh /

ENV TERM=xterm

EXPOSE 22003/udp 22005/tcp 22126/udp

VOLUME ["/resources", "/resource-cache", "/native-modules", "/data"]

ENTRYPOINT ["/entrypoint.sh"]

CMD ["-x", "-n", "-u"]
