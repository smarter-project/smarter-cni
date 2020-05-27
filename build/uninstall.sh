#!/bin/bash

echo "Removing CNI plugins from host locations"

# if we installed the smarter loopback then remove it
if [ ! -f /opt/cni/bin/smarter_loopback ];
   rm /opt/cni/bin/loopback
fi

rm -rf /etc/cni/net.d/smarter-bridge.conf
rm -rf /opt/cni/bin/smarter*

echo "Done"
