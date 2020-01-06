# MTA:SA Server Docker image

The goal of this image is to freeze external dependencies as much as possible. Currently everything is frozen except the baseconfig (which is unversioned according to MTA staff). This includes:

- the base image, which is the official Debian Testing Bullseye (slim) locked on specific date-tagged version, as-is (no apt upgrade) - base image version will always be updated manually
- MTA linux server package for specific build number (according to tag number)

Please note that two of the legacy MTA modules (`ml_sockets.so` and `mta_mysql.so`) are included in this image for maximum compatibility with older scripts. If you want to use them, just remember to add proper entries to your server config.

## Running

1. Create directories named `mta-resources/`, `data/` and `resource-cache/` in your current working directory. The command below is bind-mounting these directories to the container and they must exist or you will get an error.
2. Run one of the commands below depending on your environment. 

### What's going to happen?

If you don't have any resources in `mta-resources/` dir, the official default resources will be automatically downloaded and unpacked there when the container is started.

Server config, acl config, banlist and so on will be available in `data/` in your current directory.

### Important notes

This image is prepared for running as non-root user. Use Docker's `--user` option (or equivalent) to pass the uid / gid (of the non-root user on your host-machine) to the container. Look at examples in the next section.


### The commands

From bash:

```
docker run --name mta-server \ 
-t \                                        # allocate tty (always required)
-p 22003:22003/udp \                        # map ports to host machine
-p 22126:22126/udp \
-p 22005:22005 \
-v $(pwd)/mta-resources:/resources \        # mount mta resources dir
-v $(pwd)/data:/data \                      # mount mta data dir (config, acl, banlist, internal DBs etc.)
notfound/mtasa-server:1.5.7-20359-v17       # remember to adjust the tag name
```

From powershell (basically the only difference is `pwd` syntax):

```
docker run --name mta-server \ 
-t \                                        # allocate tty (always required)
-p 22003:22003/udp \                        # map ports to host machine
-p 22126:22126/udp \
-p 22005:22005 \
-v ${PWD}/mta-resources:/resources \        # mount mta resources dir
-v ${PWD}/data:/data \                      # mount mta data dir (config, acl, banlist, internal DBs etc.)
notfound/mtasa-server:1.5.7-20359-v17       # remember to adjust the tag name
```

## More examples

Only relevant `docker run` options are being shown in each example to avoid redundancy. You can combine options from multiple examples to create the setup that suits your needs.

### Local development

#### Minimal setup

```
docker run --name mta-server \
-t \
-p 22003:22003/udp \
-p 22005:22005 \
-v $(pwd)/mta-resources:/resources \
notfound/mtasa-server:1.5.7-20359-v17 
```

#### Or with access to /data (mtaserver.conf, acl.xml etc.)

```
docker run --name mta-server \
-t \
-p 22003:22003/udp \
-p 22005:22005 \
-v $(pwd)/mta-resources:/resources \
-v $(pwd)/data:/data \
notfound/mtasa-server:1.5.7-20359-v17 
```

### Running as non-root user:

```
docker run --name mta-server \ 
-u $(id -u):$(id -g)                        # set uid and gid of current user
-t \                                        # allocate tty (always required)
notfound/mtasa-server:1.5.7-20359-v17       # remember to adjust the tag name
```

### Running in the background (daemonized):

```
docker run --name mta-server \ 
-d                                          # detach
-t \                                        # allocate tty (always required)
notfound/mtasa-server:1.5.7-20359-v17       # remember to adjust the tag name
```

### Expose resource-cache to setup external fastdl server

```
docker run --name mta-server \ 
-t \                                        # allocate tty (always required)
-v $(pwd)/resource-cache:/resource-cache \  # mount cache dir, you only need it if you have fastdl server setup
notfound/mtasa-server:1.5.7-20359-v17       # remember to adjust the tag name
```

### Enforce server password on startup

```
docker run --name mta-server \ 
-e MTA_SERVER_PASSWORD=mypassword
-e MTA_SERVER_PASSWORD_REPLACE_POLICY=always  # always update the <password> entry in the active server config with the value of MTA_SERVER_PASSWORD
-t \                                          # allocate tty (always required)
notfound/mtasa-server:1.5.7-20359-v17         # remember to adjust the tag name
```

### Set server password on startup, but only if it's not already set in the config

```
docker run --name mta-server \ 
-e MTA_SERVER_PASSWORD=mypassword
-e MTA_SERVER_PASSWORD_REPLACE_POLICY=when-empty  # only update the <password> entry in the active server config if it's not already set
-t \                                              # allocate tty (always required)
notfound/mtasa-server:1.5.7-20359-v17             # remember to adjust the tag name
```

`when-empty` is the default policy, so this can be simplified to just:

```
docker run --name mta-server \ 
-e MTA_SERVER_PASSWORD=mypassword
-t \                                              # allocate tty (always required)
notfound/mtasa-server:1.5.7-20359-v17             # remember to adjust the tag name
```

### Automatically clear server password on startup if it's set in the config

```
docker run --name mta-server \ 
-e MTA_SERVER_PASSWORD_REPLACE_POLICY=unless-empty  # only update the <password> entry in the active server config if it has some value
-t \                                              # allocate tty (always required)
notfound/mtasa-server:1.5.7-20359-v17             # remember to adjust the tag name
```

### Use custom config file

The config file (in this example it is `mtaserver.mycustom.conf`) must be available in container's data directory, so remember to create a local directory on your host machine, put your config in there and mount this directory as `/data` in the container.

If your custom config file is not present in the data directory, it will be automatically created on container startup and populated with the default configuration from baseconfig.

```
docker run --name mta-server \ 
-e MTA_SERVER_CONFIG_FILE_NAME=mtaserver.mycustom.conf
-t \                                              # allocate tty (always required)
-v ${PWD}/data:/data \                            # mount mta data dir (config, acl, banlist, internal DBs etc.)
notfound/mtasa-server:1.5.7-20359-v17             # remember to adjust the tag name
```


## Building

This image is built automatically and published on Docker Hub when I push tag to this repo.

To build the image manually I use this exact command:

From bash:

```
env MTA_SERVER_VERSION=1.5.7 MTA_SERVER_BUILD_NUMBER=20359 IMAGE_VERSION=7 \
docker build --build-arg MTA_SERVER_VERSION=${MTA_SERVER_VERSION} -t mtasa-server:${MTA_SERVER_VERSION}-${MTA_SERVER_BUILD_NUMBER}-v${IMAGE_VERSION} .
```

From powershell:

```
$env:MTA_SERVER_VERSION="1.5.7"; $env:MTA_SERVER_BUILD_NUMBER="20359"; $env:IMAGE_VERSION="7";
docker build --build-arg MTA_SERVER_VERSION=$env:MTA_SERVER_VERSION -t mtasa-server:$env:MTA_SERVER_VERSION-$env:MTA_SERVER_BUILD_NUMBER-v$env:IMAGE_VERSION .
```

