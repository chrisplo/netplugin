#!/bin/bash

# Script to create the docker v2 plugin
# run this script from contiv/netplugin directory
# requires NETPLUGIN_CONTAINER_TAG for contivrootfs image
# requires CONTIV_NETPLUGIN_NAME, the Network Driver name for requests to
#   dockerd, should look like contiv/v2plugin:$NETPLUGIN_CONTAINER_TAG

set -euo pipefail

echo "Creating rootfs for v2plugin: ${CONTIV_V2PLUGIN_NAME}"

# clear out old plugin completely
sudo rm -rf install/v2plugin/rootfs install/v2plugin/config.json

# config.json is docker's runtime configuration for the container
# delete comments and replace placeholder with ${CONTIV_V2PLUGIN_NAME}
sed '/##/d;s/__CONTIV_V2PLUGIN_NAME__/${CONTIV_V2PLUGIN_NAME}/' \
    install/v2plugin/config.template > install/v2plugin/config.json

DOCKER_IMAGE=contivrootfs:${NETPLUGIN_CONTAINER_TAG}
docker build -t ${DOCKER_IMAGE} install/v2plugin
# creates a ready to run container but doesn't run it
id=$(docker create $DOCKER_IMAGE true)
mkdir -p install/v2plugin/rootfs
sudo docker export "${id}" | sudo gtar -x -C install/v2plugin/rootfs
# clean up created container
docker rm -vf "${id}"

echo netplugin\'s docker plugin rootfs is at install/v2plugin/rootfs
