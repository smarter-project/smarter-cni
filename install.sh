#!/bin/sh

set -e

NETWORK_SETUP="172.38.0.0/16"
GATEWAY_SETUP="172.38.0.1"
DNS_IP="172.38.0.2"

IMAGE_TO_USE="registry.gitlab.com/arm-research/smarter/smarter-dnsmasq:0.1"

case `uname -m` in
	aarch64)
		ARCHITECTURE="arm64v8";
		;;
	armv7l)
		ARCHITECTURE="arm32v6";
		;;
	x86_64)
		ARCHITECTURE="amd64"
		;;
	*)
		echo "I do not recognize the architecture of the machine "`uname -m`
		exit 1
		;;
esac


apt-get -y install jq
mkdir -p /etc/cni/net.d
cd cni
cp c2d.conf /etc/cni/net.d
mkdir -p /opt/cni/bin
cp c2d c2d-inner /opt/cni/bin
cp ../${ARCHITECTURE}/loopback /opt/cni/bin
cd ..
chmod a+x /opt/cni/bin/c2d /opt/cni/bin/c2d-inner /opt/cni/bin/loopback
cat <<EOF | tee /usr/bin/cni-iot-start
#!/bin/bash

MYDNSRUNNING=\`docker ps -a | grep mydns | wc -l\`
if [ \${MYDNSRUNNING} -gt 0 ]
then
	docker stop mydns 2>/dev/null
	docker rm mydns 2>/dev/null
fi
docker run -d --restart always --net=mynet --name=mydns --ip=${DNS_IP} ${IMAGE_TO_USE}
EOF

chmod a+x /usr/bin/cni-iot-start

docker stop mydns || true
docker rm mydns || true
docker network rm mynet || true
docker network create --subnet=${NETWORK_SETUP} --gateway=${GATEWAY_SETUP} mynet || true
if [ -e "${FILE_TO_LOAD_IMAGE}" ]
then
	docker image load -i ${FILE_TO_LOAD_IMAGE} || true
fi
/usr/bin/cni-iot-start
