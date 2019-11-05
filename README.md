# smarter-cni - A Kubernetes CNI for IoT with Edge Compute

## README

This repo contains information required to build and install the smarter-cni.

We assume that docker is already installed.


### dnsmasq

We use dnsmasq running in a docker container (named **mydns**) to provide the facility for pods that use host-networking to find a deployed pod by name.

Prebuilt docker images are provided for three Linux platforms:

|File | Platform |
|:---------|------|
|arm32v6_dnsmasq-0.1.targz | 32-bit Arm |
|arm64v8_dnsmasq-0.1.tar.gz | 64-bit Arm |
|dnsmasq-0.1.tar.gz | 64-bit x86 |


Instructions for building the images for each of the platforms can be found in the **dnsmasq** directory.


### Loopback

The standard CNI **loopback** plugin is provided as a binary for each of the platforms in the relevant directory:

* arm32v6
* arm64v8
* amd64

### cni

The **cni** directory contains the actual CNI plugin consisting of two shell-scripts plus a configuration file.

### install.sh

The **install.sh** script installs all the components and will usually need to be run using sudo.

``sudo ./install.sh``

1. Copies the CNI loopback and c2d plugins into the default directory (/opt/cni/bin)
2. Copies the CNI configuration for the c2d plugin into the default directory (/opt/cni/net.d)
3. Stops any running instance of the mydns container if present
4. Ensures that the dnsmasq docker image is available
5. Creates the docker user-defined network **mynet**
5. Starts the mydns container connected to mynet
