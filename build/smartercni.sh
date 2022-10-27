#!/bin/bash

if [ -z "${DEST_DIR}" ]
then
    if [ -e /usr/libexec/cni ]; then  
	DEST_DIR="/usr/libexec/cni"
    else
	DEST_DIR="/opt/cni/bin"
    fi
fi

if [ ! -d "${DEST_DIR}" ]
then
    mkdir -p "${DEST_DIR}"
fi 

echo "Check for existence of CNI plugins"
plugins=( "bridge" "host-local" "portmap" "loopback")

for p in "${plugins[@]}"
do
    echo -n "Looking for ${p} in ${DEST_DIR} - "
    if [ ! -e ${DEST_DIR}/${p} ]; then
        echo "Not found - Installing $p"
        cp  /host/opt/cni/bin/${p}      ${DEST_DIR}/${p}
    else
	echo "Found"
    fi
done


if [ ! -d /etc/cni/net.d ]; then
    mkdir -p /etc/cni/net.d
fi

# set default policy for FORWARD chain
iptables-legacy -P FORWARD ACCEPT


echo "Creating bridge configuration"

CIDR=${CIDR:-"172.39.0.0/16"}
GW=${GW:="172.39.0.1"}

NC=$(echo $CIDR | sed -e 's/\//\\\//')
     

sed -e "s/CIDR/\"$NC\"/" /host/etc/cni/net.d/0-smarter-bridge.conflist | sed -e "s/GW/\"$GW\"/" > 0-smarter-bridge.conflist.tmp
mv 0-smarter-bridge.conflist.tmp /etc/cni/net.d/0-smarter-bridge.conflist


echo "Done"

while true; do :; done & kill -STOP $! && wait $!
