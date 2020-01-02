# MTA:SA Server Docker image

This image is in testing stage. It might or might not be good for you depending on your requirements. The goal is to freeze external dependencies as much as possible. Currently only the base image version is frozen by using the specific, date-based tag of current Debian Testing (Bullseye) slim image. MTA package urls are not versioned however, so it always downloads whatever is pushed to public on their side.

## Building

```
docker build -t mta-server:1.5.7.20359-20200101
```

## Running

```
docker run --name mta-server \ 
-t -d \ 
-p 22003:22003/udp \ 
-p 22005:22005 \
-v ${PWD}:/workdir \
--cap-add SYS_ADMIN \
notfound/mta-server:1.5.7.20359-20200101
```
