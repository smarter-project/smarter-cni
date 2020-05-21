FROM debian:stable-slim as build


COPY host /host
COPY smartercni.sh /smartercni.sh
COPY uninstall.sh /uninstall.sh

ENTRYPOINT ["/smartercni.sh"]

