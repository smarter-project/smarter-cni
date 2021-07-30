FROM debian:stable-slim as build

RUN apt-get update && apt-get -uy upgrade
RUN apt-get install -y golang git

RUN git clone https://github.com/containernetworking/plugins.git

WORKDIR plugins

RUN CGO_ENABLED=0 ./build_linux.sh

FROM debian:stable-slim


RUN apt-get update
RUN apt-get install -y iptables

RUN mkdir -p /host/opt/cni/bin 
RUN mkdir -p /host/etc/cni/net.d

COPY --from=build /plugins/bin/bridge     /host/opt/cni/bin/bridge
COPY --from=build /plugins/bin/host-local /host/opt/cni/bin/host-local
COPY --from=build /plugins/bin/loopback /host/opt/cni/bin/loopback
COPY --from=build /plugins/bin/portmap /host/opt/cni/bin/portmap

COPY 0-smarter-bridge.conflist /host/etc/cni/net.d
COPY smartercni.sh /smartercni.sh

ENTRYPOINT ["/smartercni.sh"]

