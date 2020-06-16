FROM debian:stable-slim as build

RUN apt-get update && apt-get -uy upgrade
RUN apt-get install -y golang git

RUN git clone https://github.com/containernetworking/plugins.git

WORKDIR plugins

RUN ./build_linux.sh

FROM debian:stable-slim


RUN apt-get update
RUN apt-get install -y iproute2

RUN mkdir -p /host/opt/cni/bin 
RUN mkdir -p /host/etc/cni/net.d

COPY --from=build /plugins/bin/bridge     /host/opt/cni/bin/smarter-bridge
COPY --from=build /plugins/bin/host-local /host/opt/cni/bin/smarter-host-local
COPY --from=build /plugins/bin/loopback /host/opt/cni/bin/smarter-loopback

COPY 0-smarter-bridge.conf /host/etc/cni/net.d
COPY smartercni.sh /smartercni.sh
COPY uninstall.sh /uninstall.sh

ENTRYPOINT ["/smartercni.sh"]

