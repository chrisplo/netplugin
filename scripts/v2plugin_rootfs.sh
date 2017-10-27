#!/bin/bash

# Script to create the docker v2 plugin
# run this script from contiv/netplugin directory
# requires NETPLUGIN_CONTAINER_TAG for contivrootfs image
# requires CONTIV_NETPLUGIN_NAME, the Network Driver name for requests to
#   dockerd, should look like contiv/v2plugin:$NETPLUGIN_CONTAINER_TAG

set -euo pipefail

echo "Creating rootfs for v2plugin: ${CONTIV_V2PLUGIN_NAME}"

# clear out old plugin completely
sudo rm -rf install/v2plugin/rootfs
mkdir -p install/v2plugin/rootfs

# config.json is docker's runtime configuration for the container
# delete comments and replace placeholder with ${CONTIV_V2PLUGIN_NAME}
sed '/##/d;s/__CONTIV_V2PLUGIN_NAME__/${CONTIV_V2PLUGIN_NAME}/' \
    install/v2plugin/config.template > install/v2plugin/config.json

# make and copy over binaries for the docker build
make tar

# copy over binaries
cp ${NETPLUGIN_TAR_FILE} install/v2plugin/

DOCKER_IMAGE=contivrootfs:${NETPLUGIN_CONTAINER_TAG}
docker build -t ${DOCKER_IMAGE} \
    --build-arg TAR_FILE=$(basename "${NETPLUGIN_TAR_FILE}") install/v2plugin

# creates a ready to run container but doesn't run it
DOCKER_CONTAINER=$DOCKER_IMAGE
id=$(docker create $DOCKER_CONTAINER true)

# create the rootfs based on the created container contents
# must have gnu tar, bsd tar does not work, make tar already verified gnu
TAR=$(command -v gtar || echo command -v tar || echo "Could not find tar")
docker export "${id}" | sudo "${TAR}" -x -C install/v2plugin/rootfs

# clean up created container
docker rm -vf "${id}"

echo netplugin\'s docker plugin rootfs is at install/v2plugin/rootfs
