#!/bin/bash

echo "Copying CNI plugins into host locations"
cp -r /host/etc/cni /etc
cp -r /host/opt/cni /opt

echo "Done"

while true; do :; done & kill -STOP $! && wait $!
