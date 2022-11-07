# SMARTER Container Network Interface

A Kubernetes CNI for IoT with Edge Compute

For more information view https://getsmarter.io
## TL;DR

```console
helm repo add smarter https://smarter-project.gitlab.io/documentation/charts
helm install my-smarter-cni smarter-cni
```

## Overview

The networking configuration for a node (Edge Gateway) using smarter-cni can be viewed in two ways:

- External view: the physical network interfaces (ethernet, wifi, cellular, etc.) on the node are managed by the network that each interface is connected to. The system makes no assumptions about the IP addresses provided or DNS names for the node. It is expected that at least one interface provides access to the Internet so that the node can connect to the cloud-based Kubernetes server. We assume that the external interfaces of the node will be externally configured by DHCP, BOOTP, etc.

- Internal view: smarter-cni uses a Linux bridge network to which all the Kubernetes pods are connected via virtual interfaces (only pods that use host networking do not have a virtual interface). Each deployed (non-host networked) pod has an interface allocated from this network, receiving an allocated address from within the range of the network.

## Values

The configuration.nodeSelector value allows the nodeSelector to be changed in a higher level chart simplyfyng deploying multiple services at the same time; CNI, DNS and device-manager with a single label for example.

### DNS

A seperate chart (smarter-dns) is available to provide a DNS server that enables Kubernetes pods to discover the IP address of pods running on the same node via their "hostname" (as defined in the Pod YAML description).
Processes runnning natively on the node can query this DNS server also.

## Deployment

### On the node
Deploying this container onto a Kubernetes node will provide the CNI binaries and configuration used by the Container Runtime Interface (CRI) to deploy Kubernetes pods on that node. For this reason smarter-cni would usually be one of the first deployed pods on a node.

For smarter-cni to be scheduled to run on a node, the node must have the 'smarter.cni=deploy' label
This can be added using:

```
kubectl label node <NODENAME> smarter.cni=deploy
```

## Uninstalling the Chart

```
helm delete my-smarter-cni
```
