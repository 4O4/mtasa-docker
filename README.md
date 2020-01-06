# MTA:SA Server Docker image

The goal of this image is to freeze external dependencies as much as possible. Currently everything is frozen except the baseconfig (which is unversioned according to MTA staff). This includes:

- the base image, which is the official Debian Testing Bullseye (slim) locked on specific date-tagged version, as-is (no apt upgrade) - base image version will always be updated manually
- MTA linux server package for specific build number (according to tag number)

## Running

Just run one of the commands below depending on your environment. If you don't have any resources in `mta-resources` dir, the official default resources will be automatically downloaded and unpacked there when the container is started.

Server config, acl config, banlist and so on are in the `/data` dir, which will be mounted as `data/` in your current directory if you use the example below.

Note: This image is prepared for running as non-root user. Use Docker's `--user` option (or equivalent) to pass the uid / gid (of the non-root user on your host-machine) to the container.

From bash:

```
docker run --name mta-server \ 
-t \                                        # allocate tty
-p 22003:22003/udp \                        # map ports to host machine
-p 22126:22126/udp \
-p 22005:22005 \
-v $(pwd)/mta-resources:/resources \        # mount mta resources dir
-v $(pwd)/resource-cache:/resource-cache \  # mount cache dir, you only need it if you have fastdl server setup
-v $(pwd)/data:/data \                      # mount mta data dir (config, acl, banlist, internal DBs etc.)
notfound/mtasa-server:1.5.7-20359-v15       # remember to adjust the tag name
```

From powershell (basically the only difference is `pwd` syntax):

```
docker run --name mta-server \ 
-t \                                        # allocate tty
-p 22003:22003/udp \                        # map ports to host machine
-p 22126:22126/udp \
-p 22005:22005 \
-v ${PWD}/mta-resources:/resources \        # mount mta resources dir
-v ${PWD}/resource-cache:/resource-cache \  # mount cache dir, you only need it if you have fastdl server setup
-v ${PWD}/data:/data \                      # mount mta data dir (config, acl, banlist, internal DBs etc.)
notfound/mtasa-server:1.5.7-20359-v15       # remember to adjust the tag name
```

## More examples

### Local development

#### Minimal setup

```
docker run --name mta-server \
-t \
-p 22003:22003/udp \
-p 22005:22005 \
-v $(pwd)/mta-resources:/resources \
notfound/mtasa-server:1.5.7-20359-v15 
```

#### Or with access to /data (mtaserver.conf, acl.xml etc.)

```
docker run --name mta-server \
-t \
-p 22003:22003/udp \
-p 22005:22005 \
-v $(pwd)/mta-resources:/resources \
-v $(pwd)/data:/data \
notfound/mtasa-server:1.5.7-20359-v15 
```

### Running as non-root user:

```
docker run --name mta-server \ 
-u $(id -u):$(id -g)                        # set uid and gid of current user
-t \                                        # allocate tty
-p 22003:22003/udp \                        # map ports to host machine
-p 22126:22126/udp \
-p 22005:22005 \
-v $(pwd)/mta-resources:/resources \        # mount mta resources dir
-v $(pwd)/resource-cache:/resource-cache \  # mount cache dir, you only need it if you have fastdl server setup
-v $(pwd)/data:/data \                      # mount mta data dir (config, acl, banlist, internal DBs etc.)
notfound/mtasa-server:1.5.7-20359-v15       # remember to adjust the tag name
```

### Running in the background (daemonized):

```
docker run --name mta-server \ 
-d                                          # detach
-t \                                        # allocate tty
-p 22003:22003/udp \                        # map ports to host machine
-p 22126:22126/udp \
-p 22005:22005 \
-v $(pwd)/mta-resources:/resources \        # mount mta resources dir
-v $(pwd)/resource-cache:/resource-cache \  # mount cache dir, you only need it if you have fastdl server setup
-v $(pwd)/data:/data \                      # mount mta data dir (config, acl, banlist, internal DBs etc.)
notfound/mtasa-server:1.5.7-20359-v15       # remember to adjust the tag name
```

## Building

This image is built automatically and published on Docker Hub when I push tag to this repo.

To build the image manually I use this exact command:

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

