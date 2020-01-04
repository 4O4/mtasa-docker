FROM debian:bullseye-20191224-slim

WORKDIR /mtasa

RUN apt-get update \
    && dpkg --add-architecture i386 \
    && apt-get install zip bash tar unzip lib32z1 libncursesw5 wget gdb -y \
    && wget http://nightly.mtasa.com/files/modules/64/libmysqlclient.so.16 -P /usr/lib \
    && cp /usr/lib/libmysqlclient.so.16 /lib \
    && apt-get autoclean && apt-get autoremove

RUN wget http://linux.mtasa.com/dl/multitheftauto_linux_x64.tar.gz -P /tmp \
    && wget https://nightly.mtasa.com/files/modules/64/mta_mysql.so -P /tmp \
    && wget https://nightly.mtasa.com/files/modules/64/ml_sockets.so -P /tmp \
    && wget http://linux.mtasa.com/dl/baseconfig.tar.gz -P /tmp \
    && wget http://mirror.mtasa.com/mtasa/resources/mtasa-resources-latest.zip -P /tmp

RUN tar -xzvf /tmp/multitheftauto_linux_x64.tar.gz \
    && mv multitheftauto_linux_x64/** . \
    && rm -rfv multitheftauto_linux_x64 \
    && mkdir x64/modules && mkdir -p .default/resources \
    && mv /tmp/mta_mysql.so x64/modules \
    && mv /tmp/ml_sockets.so x64/modules \
    && tar -xzvf /tmp/baseconfig.tar.gz -C .default \
    && unzip /tmp/mtasa-resources-latest.zip -d .default/resources \
    && rm -rfv /tmp/*

COPY entrypoint.sh /

ENV TERM=xterm

EXPOSE 22003/udp 22005/tcp 22126/udp

VOLUME ["/resources", "/resource-cache" "/data"]

ENTRYPOINT ["/entrypoint.sh"]

CMD ["-x", "-n", "-u"]