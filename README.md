# MTA:SA Server Docker image

This image is in testing stage. It might or might not be good for you depending on your requirements. The goal is to freeze external dependencies as much as possible. Currently only the base image version is frozen by using the specific, date-based tag of current Debian Testing (Bullseye) slim image. MTA package urls are not versioned however, so it always downloads whatever is pushed to public on their side.

## Building

From bash:

```
env MTA_SERVER_VERSION=1.5.7 MTA_SERVER_BUILD_NUMBER=20359 IMAGE_VERSION=7 \
docker build --build-arg MTA_SERVER_VERSION=${MTA_SERVER_VERSION} -t mtasa-server:${MTA_SERVER_VERSION}-v${IMAGE_VERSION} .
```

From powershell:

```
$env:MTA_SERVER_VERSION="1.5.7"; $env:MTA_SERVER_BUILD_NUMBER="20359"; $env:IMAGE_VERSION="7";
docker build --build-arg MTA_SERVER_VERSION=$env:MTA_SERVER_VERSION -t mtasa-server:$env:MTA_SERVER_VERSION-v$env:IMAGE_VERSION .
```

## Running

```
docker run --name mta-server \ 
-t -d \ 
-p 22003:22003/udp \ 
-p 22126:22126/udp \
-p 22005:22005 \
-v ${PWD}:/workdir \
notfound/mta-server:1.5.7.20359-20200101
```
