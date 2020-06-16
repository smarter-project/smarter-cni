#!/bin/bash

echo "Copying CNI plugins into host locations"

if [ -d /usr/libexec/cni ]; then  
    DEST_DIR="/usr/libexec/cni"
else
    DEST_DIR="/opt/cni/bin"
fi

echo "Destination dir: ${DEST_DIR}"

cp  /host/opt/cni/bin/smarter-bridge      ${DEST_DIR}/smarter-bridge
cp  /host/opt/cni/bin/smarter-host-local  ${DEST_DIR}/smarter-host-local



# if there no existing loopback plugin then install the smarter one
if [ ! -f "/opt/cni/bin/loopback" ]; then
    cp /host/opt/cni/bin/smarter-loopback ${DEST_DIR}/loopback
fi


echo "Remove any existing smartnet0 bridge"
ip link show smartnet0
status=$? 

if [ $status -eq 0 ]; then
    ip link set smartnet0 down
    ip link delete smartnet0
fi
   


echo "Creating bridge configuration"

CIDR=${CIDR:-"172.38.0.0/16"}
GW=${GW:="172.38.0.0"}

NC=$(echo $CIDR | sed -e 's/\//\\\//')
     

sed -e "s/CIDR/\"$NC\"/" /host/etc/cni/net.d/0-smarter-bridge.conf | sed -e "s/GW/\"$GW\"/" > /etc/cni/net.d/0-smarter-bridge.conf

echo "Done"

while true; do :; done & kill -STOP $! && wait $!
