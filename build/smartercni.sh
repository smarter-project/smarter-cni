#!/bin/bash

echo "Copying CNI plugins into host locations"

if [ -e /usr/libexec/cni/loopback ]; then  
    DEST_DIR="/usr/libexec/cni"
else
    if [ ! -d /opt/cni/bin ]; then
        mkdir -p /opt/cni/bin
    fi 
    DEST_DIR="/opt/cni/bin"
fi

echo "Destination dir: ${DEST_DIR}"

cp  /host/opt/cni/bin/smarter-bridge      ${DEST_DIR}/smarter-bridge
cp  /host/opt/cni/bin/smarter-host-local  ${DEST_DIR}/smarter-host-local



# if there no existing loopback plugin then install the smarter one
if [ ! -f "/opt/cni/bin/loopback" ]; then
    cp /host/opt/cni/bin/smarter-loopback ${DEST_DIR}/loopback
fi


if [ ! -d /etc/cni/net.d ]; then
    mkdir -p /etc/cni/net.d
fi

iptables-legacy -P FORWARD ACCEPT

echo "Creating bridge configuration"

CIDR=${CIDR:-"172.39.0.0/16"}
GW=${GW:="172.39.0.1"}

NC=$(echo $CIDR | sed -e 's/\//\\\//')
     

sed -e "s/CIDR/\"$NC\"/" /host/etc/cni/net.d/0-smarter-bridge.conf | sed -e "s/GW/\"$GW\"/" > /etc/cni/net.d/0-smarter-bridge.conf

echo "Done"

while true; do :; done & kill -STOP $! && wait $!
