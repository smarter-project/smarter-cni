#!/bin/sh

set -e

K8S_APT_FILE="/etc/apt/sources.list.d/kubernetes.list"

apt-get -y install curl

if [ -f $K8S_APT_FILE ]; then 
echo "Using existing k8s repo"
else
cat <<EOF | tee $K8S_APT_FILE
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
fi

rm -f *.deb
rm -rf opt
apt-get update
apt-get download kubernetes-cni

DEB=`ls *.deb`
if [ -f $DEB ]; then
   echo "Installing loopback plugin"
   mkdir -p /opt/cni/bin

   ar -x $DEB data.tar.xz
   xzcat data.tar.xz | tar  xf - ./opt/cni/bin/loopback 
   cp ./opt/cni/bin/loopback /opt/cni/bin
   chmod a+x /opt/cni/bin/loopback
   echo "Done"
   rm -f data.tar.xz
   rm -f *.deb
   rm -rf opt
else
  echo "Could not find kubernetes-cni pkg file"       
fi       

