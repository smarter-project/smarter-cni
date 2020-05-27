#!/bin/bash

echo "Copying CNI plugins into host locations"
cp -r /host/etc/cni /etc
cp -r /host/opt/cni /opt

# if there no existing loopback plugin then install the smarter one
if [ ! -f "/opt/cni/bin/loopback" ]; then
    mv /opt/cni/bin/smarter-loopback /opt/cni/bin/loopback
fi


echo "Creating bridge configuration"

CIDR=${CIDR:-"172.38.0.0/16"}
GW=${GW:="172.38.0.0"}

NC=$(echo $CIDR | sed -e 's/\//\\\//')
     

sed -e "s/CIDR/\"$NC\"/" /host/etc/cni/net.d/smarter-bridge.conf | sed -e "s/GW/\"$GW\"/" > /etc/cni/net.d/smarter-bridge.conf

echo "Done"

while true; do :; done & kill -STOP $! && wait $!
