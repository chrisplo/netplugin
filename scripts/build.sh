#!/bin/bash

set -exo pipefail

BUILD_TIME=$(date -u +%m-%d-%Y.%H-%M-%S.UTC)
VERSION=$(cat version/CURRENT_VERSION | tr -d '\n')
PKG_NAME=github.com/contiv/netplugin/version

# BUILD_VERSION overrides the version from CURRENT_VERSION
if [ -n "$BUILD_VERSION" ]; then
	VERSION=$BUILD_VERSION
fi

if [ -z "$USE_RELEASE" ]; then
	BUILD_VERSION="$VERSION-$BUILD_TIME"
else
	BUILD_VERSION="$VERSION"
fi

GIT_COMMIT=$(./scripts/getGitCommit.sh)

echo $BUILD_VERSION >$VERSION_FILE

GOGC=1500 go install \
	-ldflags "-X $PKG_NAME.version=$BUILD_VERSION \
	-X $PKG_NAME.buildTime=$BUILD_TIME \
	-X $PKG_NAME.gitCommit=$GIT_COMMIT \
	-s -w" \
	$TO_BUILD
