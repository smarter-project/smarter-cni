#!/bin/bash

echo "Removing CNI plugins from host locations"

rm -rf /etc/cni/net.d
rm -rf /opt/cni/bin

echo "Done"
