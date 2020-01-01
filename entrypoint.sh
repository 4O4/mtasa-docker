#!/usr/bin/env bash

# set -

readonly SERVER_DIR="/mtasa"
readonly BASECONFIG_DIR="${SERVER_DIR}/.default/baseconfig"
readonly DEFAULT_RESOURCES_DIR="${SERVER_DIR}/.default/resources"

readonly WORK_DIR="/workdir"
readonly DATA_DIR="${WORK_DIR}/data"
readonly RESOURCES_DIR="${WORK_DIR}/resources"

main() {
    mkdir -p ${DATA_DIR}
    mkdir -p ${RESOURCES_DIR}

    if ! [[ -f ${DATA_DIR}/acl.xml ]]; then
        cp ${BASECONFIG_DIR}/acl.xml ${DATA_DIR}/acl.xml
    fi;

    if ! [[ -f ${DATA_DIR}/mtaserver.conf ]]; then
        cp ${BASECONFIG_DIR}/mtaserver.conf ${DATA_DIR}/mtaserver.conf
    fi;

    if ! [[ -f ${DATA_DIR}/vehiclecolors.conf ]]; then
        cp ${BASECONFIG_DIR}/vehiclecolors.conf ${DATA_DIR}/vehiclecolors.conf
    fi;

    ln -s ${RESOURCES_DIR} ${DATA_DIR}

    if ! [ "$(ls -A ${RESOURCES_DIR})" ]; then
        cp -R ${DEFAULT_RESOURCES_DIR}/** ${RESOURCES_DIR}
    fi;

    mount --bind ${DATA_DIR} ${SERVER_DIR}/mods/deathmatch

    # screen -dmSU mta-server ${SERVER_DIR}/mta-server64 $@
    
    # while true; do
    #     sleep 1
    # done

    ${SERVER_DIR}/mta-server64 $@
}

main $@