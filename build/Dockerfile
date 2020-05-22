FROM debian:stable-slim as build

RUN apt-get update && apt-get -uy upgrade
RUN apt-get install -y golang git

RUN git clone https://github.com/containernetworking/plugins.git

WORKDIR plugins

RUN ./build_linux.sh

FROM debian:stable-slim

RUN mkdir -p /host/opt/cni/bin 
RUN mkdir -p /host/etc/cni/net.d

COPY --from=build /plugins/bin/* /host/opt/cni/bin/

COPY bridge.conf /host/etc/cni/net.d
COPY smartercni.sh /smartercni.sh
COPY uninstall.sh /uninstall.sh

ENTRYPOINT ["/smartercni.sh"]

