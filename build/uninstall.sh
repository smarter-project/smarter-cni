#!/bin/bash

echo "Removing CNI plugins from host locations"

# if we installed the smarter loopback then remove it
if [ ! -f /opt/cni/bin/smarter_loopback ]; then
   rm /opt/cni/bin/loopback
fi

rm -rf /etc/cni/net.d/smarter-bridge.conf
rm -rf /opt/cni/bin/smarter*

echo "Remove smartnet0 bridge"
ip link show smartnet0
status=$? 

if [ $status -eq 0 ]; then
    ip link set smartnet0 down
    ip link delete smartnet0
fi


echo "Done"
