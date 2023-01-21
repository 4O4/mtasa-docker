# MTA:SA Server Docker image

Unofficial Docker image for Multi Theft Auto: San Andreas game server. Maintained mostly for myself, but also for anyone from the MTA community who find it useful.

![image](https://user-images.githubusercontent.com/4274691/95139095-fd730200-076b-11eb-8310-e2e009856fd4.png)

## Details

- This image is automatically built and published on Dockerhub as [`notfound/mtasa-server`](https://hub.docker.com/r/notfound/mtasa-server)
- The base image is Debian Testing (slim) which ensures maximum compatibility and official support 
- Total image size is oscillating around 100MiB
- **arm64 server only**
- The tags always reflect the specific version and build number of the MTA server which they contain, i.e. `1.5.7-20595-v4`


> **Note:** the `v4` in this example is the version number of the tag itself because sometimes something might go wrong and an updated release of the same version and build number is needed)

## Features

- Optimized to be easy to use by anyone
- Comes with a simple scripts which automate boring stuff:
  
  - Automatic resources downloader: If you don't have any resources yet, the official MTA resources package is automatically downloaded and extracted for you before the server is started

  - Automatic baseconfig provider: If you don't have your own configuration files, all essential ones are automatically brought to you from the official `baseconfig` archive
 
- Also covers more advanced scenarios that experienced developers and server owners might find handy:
  
  - Automatic creation of admin / developer account in the built-in accounts system - TODO, soon
  - Automatic management of server password, with three strategies (policies) available to be used depending on the use case
  - Effortless switching between different server configs, i.e. `mtaserver.dev.conf` file for development and `mtaserver.prod.conf` for the live server
  - All of that is configurable via [environment variables](#environment-variables)
  - Custom native modules can still be installed easily if needed (native modules will be deprecated in MTA 1.6, so they will be around for a while)
  - Full access to the server console input and output, even if the server was started in the background (re-attaching to the console works fine, no `screen` or anything like that is involved - it's all docker)
  - Simple directory structure on the root level (`/`) inside the image which makes them easier to find and mount
  - Ready for fastdl setups (hosting client files over external HTTP servers)
  - Fully prepared for running as a non-root user


- It's battle-tested: I'm using this image by myself in 4 different environments and I consider it production-ready :)

> **Note:** The automatic resources downloader and baseconfig provider mentioned above don't interfere with your existing files. If some essential config files are totally missing, then they will be added for you from the `baseconfig` package, But if you already have your own resources and configs then don't worry - **they will NOT be overwritten**.

## More screenshots

Because everyone likes screenshots

- Resources autodownloader in action:
  
  ![image](https://user-images.githubusercontent.com/4274691/95139177-285d5600-076c-11eb-9c9c-c34fd3fed2ef.png)

- Directory structure after running the command visible in the screenshot above (before running it, it was three empty folders)
  
  ![image](https://user-images.githubusercontent.com/4274691/95139692-5db67380-076d-11eb-90de-e61f675e8e93.png)

## Environment variables

- `MTA_SERVER_CONFIG_FILE_NAME` - custom name of the config file, useful for switching between configs for different environments i.e. `mtaserver.dev.conf` for development, `mtaserver.prod.conf` for the live server

## Usage

It's recommended to use this image in a Docker Compose setup, because it's much easier to maintain and configure everything with a YAML file instead of passing all of the options via command line.

TODO: More on that will be here soon

## Usage via command line

This is just for reference and basic testing. You should really consider [using a Docker Compose setup as described in this section](#usage).

### Required manual setup

Create an empty directory somewhere on your disk, then navigate to it and create directories named:
- `mta-resources/`
- `data/` 
- `resource-cache/` 

The commands in the examples below are [bind-mounting](https://docs.docker.com/storage/bind-mounts/) these directories to the container and they must exist or you will get a nasty error.

### See it in action

Run one of [the example commands](#the-commands) in Powershell on Windows, or in bash on Linux.

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
victoroy/mtasa-server-arm64:1.5.9-21415       # remember to adjust the tag name
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
victoroy/mtasa-server-arm64:1.5.9-21415       # remember to adjust the tag name
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
victoroy/mtasa-server-arm64:1.5.9-21415 
```

#### Or with access to /data (mtaserver.conf, acl.xml etc.)

```
docker run --name mta-server \
-t \
-p 22003:22003/udp \
-p 22005:22005 \
-v $(pwd)/mta-resources:/resources \
-v $(pwd)/data:/data \
victoroy/mtasa-server-arm64:1.5.9-21415 
```

### Running as non-root user:

```
docker run --name mta-server \ 
-u $(id -u):$(id -g)                        # set uid and gid of current user
-t \                                        # allocate tty (always required)
victoroy/mtasa-server-arm64:1.5.9-21415       # remember to adjust the tag name
```

### Running in the background (daemonized):

```
docker run --name mta-server \ 
-d                                          # detach
-t \                                        # allocate tty (always required)
victoroy/mtasa-server-arm64:1.5.9-21415       # remember to adjust the tag name
```

### Expose resource-cache to setup external fastdl server

```
docker run --name mta-server \ 
-t \                                        # allocate tty (always required)
-v $(pwd)/resource-cache:/resource-cache \  # mount cache dir, you only need it if you have fastdl server setup
victoroy/mtasa-server-arm64:1.5.9-21415       # remember to adjust the tag name
```

### Enforce server password on startup

```
docker run --name mta-server \ 
-e MTA_SERVER_PASSWORD=mypassword
-e MTA_SERVER_PASSWORD_REPLACE_POLICY=always  # always update the <password> entry in the active server config with the value of MTA_SERVER_PASSWORD
-t \                                          # allocate tty (always required)
victoroy/mtasa-server-arm64:1.5.9-21415         # remember to adjust the tag name
```

### Set server password on startup, but only if it's not already set in the config

```
docker run --name mta-server \ 
-e MTA_SERVER_PASSWORD=mypassword
-e MTA_SERVER_PASSWORD_REPLACE_POLICY=when-empty  # only update the <password> entry in the active server config if it's not already set
-t \                                              # allocate tty (always required)
victoroy/mtasa-server-arm64:1.5.9-21415             # remember to adjust the tag name
```

`when-empty` is the default policy, so this can be simplified to just:

```
docker run --name mta-server \ 
-e MTA_SERVER_PASSWORD=mypassword
-t \                                              # allocate tty (always required)
victoroy/mtasa-server-arm64:1.5.9-21415             # remember to adjust the tag name
```

### Automatically clear server password on startup if it's set in the config

```
docker run --name mta-server \ 
-e MTA_SERVER_PASSWORD_REPLACE_POLICY=unless-empty  # only update the <password> entry in the active server config if it has some value
-t \                                              # allocate tty (always required)
victoroy/mtasa-server-arm64:1.5.9-21415             # remember to adjust the tag name
```

### Use custom config file

The config file (in this example it is `mtaserver.mycustom.conf`) must be available in container's data directory, so remember to create a local directory on your host machine, put your config in there and mount this directory as `/data` in the container.

If your custom config file is not present in the data directory, it will be automatically created on container startup and populated with the default configuration from baseconfig.

```
docker run --name mta-server \ 
-e MTA_SERVER_CONFIG_FILE_NAME=mtaserver.mycustom.conf
-t \                                              # allocate tty (always required)
-v ${PWD}/data:/data \                            # mount mta data dir (config, acl, banlist, internal DBs etc.)
victoroy/mtasa-server-arm64:1.5.9-21415             # remember to adjust the tag name
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

