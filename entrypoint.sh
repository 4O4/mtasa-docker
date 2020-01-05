#!/usr/bin/env bash

set -e

readonly MTA_SERVER_ROOT_DIR="/mtasa"
readonly BASECONFIG_DIR="${MTA_SERVER_ROOT_DIR}/.default/baseconfig"
readonly DEFAULT_RESOURCES_DIR="${MTA_SERVER_ROOT_DIR}/.default/resources"

# readonly MTA_SERVER_WORK_DIR="/workdir"
readonly DATA_DIR="/data"
readonly RESOURCES_DIR="/resources"
readonly RESOURCE_CACHE_DIR="/resource-cache"

main() {
    if ! [[ -f ${DATA_DIR}/acl.xml ]]; then
        cp ${BASECONFIG_DIR}/acl.xml ${DATA_DIR}/acl.xml
    fi;

    if ! [[ -f ${DATA_DIR}/mtaserver.conf ]]; then
        cp ${BASECONFIG_DIR}/mtaserver.conf ${DATA_DIR}/mtaserver.conf
    fi;

    if ! [[ -f ${DATA_DIR}/vehiclecolors.conf ]]; then
        cp ${BASECONFIG_DIR}/vehiclecolors.conf ${DATA_DIR}/vehiclecolors.conf
    fi;

    if ! [ "$(ls -A ${RESOURCES_DIR})" ]; then
        cp -R ${DEFAULT_RESOURCES_DIR}/** ${RESOURCES_DIR}
    fi;

    ln -sf ${DATA_DIR} ${MTA_SERVER_ROOT_DIR}/mods/deathmatch
    ln -sf ${RESOURCES_DIR} ${DATA_DIR}/resources
    ln -sf ${RESOURCE_CACHE_DIR} ${DATA_DIR}/resource-cache

    ${MTA_SERVER_ROOT_DIR}/mta-server64 $@
}

main $@