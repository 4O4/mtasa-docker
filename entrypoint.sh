#!/usr/bin/env bash

set -e

if ! [ -z "${MTA_DOCKER_ENTRYPOINT_DEBUG}" ]; then
    set -x
fi;

readonly BASECONFIG_DIR="${MTA_SERVER_ROOT_DIR}/.default/baseconfig"
readonly DATA_DIR="${MTA_SERVER_ROOT_DIR}/mods/deathmatch"
readonly MTA_SERVER_CONFIG_FILE_PATH="${DATA_DIR}/${MTA_SERVER_CONFIG_FILE_NAME}"
DEFAULT_RESOURCES_ROOT_DIR="/resources"

if ! [ -z "${MTA_DEFAULT_RESOURCES_SUBDIRECTORY_NAME}" ]; then
    DEFAULT_RESOURCES_ROOT_DIR="${DEFAULT_RESOURCES_ROOT_DIR}/${MTA_DEFAULT_RESOURCES_SUBDIRECTORY_NAME}"
fi;

main() {
    if [ -L "${DATA_DIR}/resources" ]; then
        unlink "${DATA_DIR}/resources"
    fi;
    
    if [ -L "${DATA_DIR}/resource-cache" ]; then
        unlink "${DATA_DIR}/resource-cache"
    fi;
    
    if [ -f "${DATA_DIR}/resources" ] || [ -d "${DATA_DIR}/resources" ]; then
        echo "Forbidden file or directory name (resources) in /data volume. Remove or rename it in order to run this container."
        exit 1
    fi;
    
    if [ -f ${DATA_DIR}/resource-cache ] || [ -d ${DATA_DIR}/resource-cache ]; then
        echo "Forbidden file or directory name (resource-cache) in /data volume. Remove or rename it in order to run this container."
        exit 1
    fi;

    if ! [[ -f "${DATA_DIR}/acl.xml" ]]; then
        cp "${BASECONFIG_DIR}/acl.xml" "${DATA_DIR}/acl.xml"
    fi;

    if ! [[ -f "${MTA_SERVER_CONFIG_FILE_PATH}" ]]; then
        cp "${BASECONFIG_DIR}/mtaserver.conf" "${MTA_SERVER_CONFIG_FILE_PATH}"
    fi;

    if ! [[ -f "${DATA_DIR}/vehiclecolors.conf" ]]; then
        cp "${BASECONFIG_DIR}/vehiclecolors.conf" "${DATA_DIR}/vehiclecolors.conf"
    fi;

    if ! [ "$(ls -A ${DEFAULT_RESOURCES_ROOT_DIR})" ]; then
        echo "Downloading latest official resources package..."
        wget "${MTA_DEFAULT_RESOURCES_URL}" -O /tmp/mtasa-resources-latest.zip
        unzip /tmp/mtasa-resources-latest.zip -d "${DEFAULT_RESOURCES_ROOT_DIR}"
        rm /tmp/mtasa-resources-latest.zip
    fi;

    if [ "$(ls -A /native-modules/*.so)" ]; then
        echo "Copying native modules..."
        cp -vf /native-modules/*.so "${MTA_SERVER_ROOT_DIR}/arm64/modules"
    fi;

    if [ -z "${MTA_SERVER_PASSWORD_REPLACE_POLICY}" ]; then
        MTA_SERVER_PASSWORD_REPLACE_POLICY="when-empty"
    fi;

    escaped_password="$(echo "${MTA_SERVER_PASSWORD}" | sed 's~#~\\#~g; s#&#\\\&amp\\;#g; s#<#\\\&lt\\;#g; s#>#\\\&gt\\;#g; s#"#\\\&quot\\;#g; s#'"'"'#\\\&apos\\;#g')"
    checksum_before="$(md5sum "${MTA_SERVER_CONFIG_FILE_PATH}")"

    echo "Password replace policy is: ${MTA_SERVER_PASSWORD_REPLACE_POLICY}"
    
    case "${MTA_SERVER_PASSWORD_REPLACE_POLICY}" in
        when-empty)
            if ! [ -z "${MTA_SERVER_PASSWORD}" ]; then
                sed -i 's#\(<password>\)[ ]*\(</password>\)#\1'"${escaped_password}"'\2#g' "${MTA_SERVER_CONFIG_FILE_PATH}"
            else
                echo "MTA_SERVER_PASSWORD is not set, skipping"
            fi;
            ;;
        unless-empty)
            sed -i 's#\(<password>\)[^<]\{1,\}\(</password>\)#\1'"${escaped_password}"'\2#g' "${MTA_SERVER_CONFIG_FILE_PATH}"
            ;;
        always)
            sed -i 's#\(<password>\)[^<]*\(</password>\)#\1'"${escaped_password}"'\2#g' "${MTA_SERVER_CONFIG_FILE_PATH}"
            ;;
        *)
            echo "Unsupported password replace policy: ${MTA_SERVER_PASSWORD_REPLACE_POLICY}"
            echo "Accepted values for MTA_SERVER_PASSWORD_REPLACE_POLICY are:"
            echo " - 'always'        (always replace password in config file)"
            echo " - 'unless-empty'  (replace password only if it's already set in config file)"
            echo " - 'when-empty'    (default - replace password only if it's not set in config file)"
            exit 1
            ;;
    esac

    checksum_after="$(md5sum "${MTA_SERVER_CONFIG_FILE_PATH}")"

    if [ "${checksum_before}" = "${checksum_after}" ]; then
        echo "Password HAS NOT been replaced!"
    else
        echo "Password has been replaced!"
    fi;
    
    ln -sf /resources "${DATA_DIR}/resources"
    ln -sf /resource-cache "${DATA_DIR}/resource-cache"

    "${MTA_SERVER_ROOT_DIR}/mta-server-arm64" --config "${MTA_SERVER_CONFIG_FILE_NAME}" $@
}

main $@
