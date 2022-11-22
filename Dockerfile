FROM golang:1.19 as build

WORKDIR /root

RUN git clone https://github.com/containernetworking/plugins.git 
WORKDIR plugins
COPY my_patch .
RUN git apply my_patch

WORKDIR /root

WORKDIR /root/plugins

RUN CGO_ENABLED=0 ./build_linux.sh

FROM alpine:latest
RUN apk -U upgrade && apk add iptables bash

RUN mkdir -p /host/opt/cni/bin 
RUN mkdir -p /host/etc/cni/net.d

COPY --from=build /root/plugins/bin/bridge     /host/opt/cni/bin/bridge
COPY --from=build /root/plugins/bin/host-local /host/opt/cni/bin/host-local
COPY --from=build /root/plugins/bin/loopback /host/opt/cni/bin/loopback
COPY --from=build /root/plugins/bin/portmap /host/opt/cni/bin/portmap

COPY 0-smarter-bridge.conflist /host/etc/cni/net.d
COPY smartercni.sh /smartercni.sh

ENTRYPOINT ["/smartercni.sh"]

