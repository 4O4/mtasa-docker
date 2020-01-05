#!/usr/bin/env bash

set -e

if ! [ -z ${MTA_DOCKER_ENTRYPOINT_DEBUG} ]; then
    set -x
fi;

readonly BASECONFIG_DIR=${MTA_SERVER_ROOT_DIR}/.default/baseconfig
readonly DATA_DIR=${MTA_SERVER_ROOT_DIR}/mods/deathmatch

main() {
    if [ -L ${DATA_DIR}/resources ]; then
        unlink ${DATA_DIR}/resources
    fi;
    
    if [ -L ${DATA_DIR}/resource-cache ]; then
        unlink ${DATA_DIR}/resource-cache
    fi;
    
    if [ -f ${DATA_DIR}/resources ] || [ -d ${DATA_DIR}/resources ]; then
        echo "Forbidden file or directory name (resources) in /data volume. Remove or rename it in order to run this container."
        exit 1
    fi;
    
    if [ -f ${DATA_DIR}/resource-cache ] || [ -d ${DATA_DIR}/resource-cache ]; then
        echo "Forbidden file or directory name (resource-cache) in /data volume. Remove or rename it in order to run this container."
        exit 1
    fi;

    if ! [[ -f ${DATA_DIR}/acl.xml ]]; then
        cp ${BASECONFIG_DIR}/acl.xml ${DATA_DIR}/acl.xml
    fi;

    if ! [[ -f ${DATA_DIR}/mtaserver.conf ]]; then
        cp ${BASECONFIG_DIR}/mtaserver.conf ${DATA_DIR}/mtaserver.conf
    fi;

    if ! [[ -f ${DATA_DIR}/vehiclecolors.conf ]]; then
        cp ${BASECONFIG_DIR}/vehiclecolors.conf ${DATA_DIR}/vehiclecolors.conf
    fi;

    if ! [ "$(ls -A /resources)" ]; then
        echo "Downloading latest official resources package..."
        wget ${MTA_DEFAULT_RESOURCES_URL} -P /tmp
        unzip /tmp/mtasa-resources-latest.zip -d /resources
        rm /tmp/mtasa-resources-latest.zip
    fi;
    
    ln -sf /resources ${DATA_DIR}/resources
    ln -sf /resource-cache ${DATA_DIR}/resource-cache

    ${MTA_SERVER_ROOT_DIR}/mta-server64 $@
}

main $@