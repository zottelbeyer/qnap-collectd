FROM alpine AS builder

# Download QEMU, see https://github.com/docker/hub-feedback/issues/1261
ENV QEMU_URL https://github.com/balena-io/qemu/releases/download/v3.0.0%2Bresin/qemu-3.0.0+resin-arm.tar.gz
RUN apk add curl && curl -L ${QEMU_URL} | tar zxvf - -C . --strip-components 1

FROM arm32v5/debian:buster

# Add QEMU
COPY --from=builder qemu-arm-static /usr/bin

COPY rootfs_prefix/ /usr/src/rootfs_prefix/
COPY sources.list.d/nonfree.list /etc/apt/sources.list.d/nonfree.list
COPY collectd.conf /etc/collectd/collectd.conf
COPY NAS-MIB.txt /usr/share/snmp/mibs/NAS-MIB.txt
COPY QTS-MIB.txt /usr/share/snmp/mibs/QTS-MIB.txt

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
 && apt-get install --no-install-recommends -qy \
    collectd-core \
    collectd-utils \
    build-essential \
	snmp \
	snmp-mibs-downloader \
 && make -C /usr/src/rootfs_prefix/ \
 && apt-get -yq --purge remove build-essential \
 && apt-get -yq autoremove \
 && apt-get -yq clean \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /etc/apt/sources.list.d/*

ENV LD_PRELOAD /usr/src/rootfs_prefix/rootfs_prefix.so

ENTRYPOINT ["/usr/sbin/collectd"]
CMD ["-f"]
