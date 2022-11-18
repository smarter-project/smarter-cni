FROM golang:1.17 as build

#RUN echo "deb http://ftp.de.debian.org/debian bullseye-backports main" >>  /etc/apt/sources.list && apt-get update && apt-get -uy upgrade
#RUN apt-get install -y golang-1.17 git && ln -s /usr/lib/go-1.17/bin/go /usr/bin/go

WORKDIR /root

RUN git clone https://github.com/containernetworking/plugins.git 
WORKDIR plugins
COPY my_patch .
RUN git apply my_patch

WORKDIR /root

WORKDIR /root/plugins

RUN CGO_ENABLED=0 ./build_linux.sh

FROM debian:stable-slim

RUN apt-get update -y;apt-get -y upgrade;apt-get install -y iptables;apt-get clean

RUN mkdir -p /host/opt/cni/bin 
RUN mkdir -p /host/etc/cni/net.d

COPY --from=build /root/plugins/bin/bridge     /host/opt/cni/bin/bridge
COPY --from=build /root/plugins/bin/host-local /host/opt/cni/bin/host-local
COPY --from=build /root/plugins/bin/loopback /host/opt/cni/bin/loopback
COPY --from=build /root/plugins/bin/portmap /host/opt/cni/bin/portmap

COPY 0-smarter-bridge.conflist /host/etc/cni/net.d
COPY smartercni.sh /smartercni.sh

ENTRYPOINT ["/smartercni.sh"]
