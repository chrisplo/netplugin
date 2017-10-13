# Docker v2plugin container with OVS / netplugin / netmaster

# Binaries have already been built in netplugin-build container
ARG NETPLUGIN_BUILD_TAG=latest
FROM netplugin-build:${NETPLUGIN_BUILD_TAG} as netplugin

FROM alpine:3.5
LABEL maintainer "Cisco Contiv (https://contiv.github.io)"

RUN mkdir -p /run/docker/plugins /etc/openvswitch /var/run/contiv/log \
 && echo 'http://dl-cdn.alpinelinux.org/alpine/v3.4/main' >> /etc/apk/repositories \
 && apk --no-cache add openvswitch=2.5.0-r0 iptables ca-certificates openssl curl bash \
 && wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://raw.githubusercontent.com/andyshinn/alpine-pkg-glibc/master/sgerrand.rsa.pub \
 && wget https://github.com/andyshinn/alpine-pkg-glibc/releases/download/2.23-r1/glibc-2.23-r1.apk \
 && apk --no-cache add glibc-2.23-r1.apk

COPY --from=netplugin /go/bin/netplugin /go/bin/netmaster /go/bin/netctl /
COPY startcontiv.sh /

ENTRYPOINT ["/startcontiv.sh"]
