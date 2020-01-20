# smarter-cni - A Kubernetes CNI for IoT with Edge Compute

## README

This repo contains information required to build and install the smarter-cni.

We assume that docker is already installed.

## About smarter-cni
### Networking
The networking configuration for a node (Edge Gateway) using smarter-cni can be viewed in two ways:

* External view: the physical network interfaces (ethernet, wifi, cellular, etc.) on the node are managed by the network that each interface is connected to. The system makes no assumptions about the IP addresses provided or DNS names for the node. It is expected that at least one interface provides access to the Internet so that the node can connect to the cloud-based Kubernetes master. We assume that the external interfaces of the node will be externally configured by DHCP, BOOTP, etc.

* Internal view: smarter-cni uses a Docker user-defined network to which all the Kubernetes pods are connected via virtual interfaces (only pods that use host networking do not have a virtual interface). Each deployed pod has an interface allocated from this user-defined network, receiving an allocated address from within the range of the user-defined network.

### DNS

Docker provides an automatically enabled, embedded DNS resolver (127.0.0.11) for user-defined networks. When a Kubernetes pod is started on a node, smarter-cni captures the Kubernetes pod name and creates a DNS record in the embedded DNS server. It is this mechanism that enables pods running on the same node to discover each other's IP addresses via DNS lookup of their names. Each node also runs a containerized dnsmasq connected to the user-defined network with a static address. Pods using host networking are configured to look up DNS entries via this dnsmasq and can therefore also discover IP addresses via DNS lookup of pod names (which wouldn't normally be possible as host networked pods cannot access the embedded DNS resolver directly).

# Installation

## dnsmasq

We use dnsmasq running in a docker container (named **mydns**) to provide the facility for pods that use host-networking to find a deployed pod by name.

Prebuilt docker images are provided for three Linux platforms:

|File | Platform |
|:---------|------|
|arm32v6_dnsmasq-0.1.targz | 32-bit Arm |
|arm64v8_dnsmasq-0.1.tar.gz | 64-bit Arm |
|dnsmasq-0.1.tar.gz | 64-bit x86 |


Instructions for building the images for each of the platforms can be found in the **dnsmasq** directory.


## Loopback

The standard CNI **loopback** plugin is provided as a binary for each of the platforms in the relevant directory:

* arm32v6
* arm64v8
* amd64

## cni

The **cni** directory contains the actual CNI plugin consisting of two shell-scripts plus a configuration file.

## install.sh

The **install.sh** script installs the above components and will usually need to be run using sudo.

``sudo ./install.sh``

1. Copies the CNI loopback and c2d plugins into the default directory (/opt/cni/bin)
2. Copies the CNI configuration for the c2d plugin into the default directory (/opt/cni/net.d)
3. Stops any running instance of the mydns container if present
4. Ensures that the dnsmasq docker image is available
5. Creates the docker user-defined network **mynet**
5. Starts the mydns container connected to mynet



# Example usage using smarter-cni with k3s

Once smarter-cni is installed on a node it can be used as the CNI when the node is joined to a Kubernetes cluster. In our *IoT-Edge-Compute* setup we do not run the Kubernetes kube-proxy or core-dns pods/services - they are used to provide cross-node (ie cross-Edge Gateway) functionality that we explicitly do not support.

Here is an example of using smarter-cni with k3s and Docker as the container runtime engine (we assume that Docker is already present). We will run the k3s server on one node (**the master**) and the k3s agent on another node (**the worker**)

## On both the Master and Worker Node

* Download the latest k3s binary from [https://github.com/rancher/k3s/releases/latest](https://github.com/rancher/k3s/releases/latest). Both 64-bit and 32-bit Arm platforms are supported as well as x86. Install the k3s binary on both the master and worker nodes as `/usr/local/bin/k3s` making sure it is executable.


## On the Master Node

* Start the k3s server on the master node using:

`$ /usr/local/bin/k3s server --docker --no-flannel --no-deploy coredns --no-deploy traefik --disable-agent > server.log 2>&1 &`

This will start the k3s server using docker as the container runtime engine and switches the CNI from the default (flannel) to that specified in the /etc/cni/net.d directory. This command also prevents coredns and traefik being deployed as we do not use that functionality. This command will generate logging information so it's best to redirect standard error and standard output to file as shown

Note that in this setup the master node is not running the k3s agent and will therefore not run any applications that are deployed into the cluster.


* Find the token that a worker will need to join the cluster. This is located at /var/lib/rancher/k3s/server/node-token on the master node.

For example:

```
$ cat /var/lib/rancher/k3s/server/node-token

K1093b183760bf9caa3d3862975cfdc5452a84fe258ee672d545dd2d27900045162::node:a6208aefd1e9bf2644b0c7eb10a76756
```

## On the Worker Node
* Put the token from the master into an environment variable on the worker node:

`$ export TOKEN="K1093b183760bf9caa3d3862975cfdc5452a84fe258ee672d545dd2d27900045162::node:a6208aefd1e9bf2644b0c7eb10a76756"`

* Run the k3s agent on the worker node filling in the IP of the master node and providing the token:

`$ k3s agent --docker --no-flannel --server=https://<IP_OF_SERVER>:6443 --token ${TOKEN} > worker.log 2>&1 &`

This will start the k3s agent and join the worker to the cluster. This command will also generate logging information so it's best to redirect standard error and standard output to file as shown.

* Now on the master node you should be able to see the state of the cluster using:

``$ /usr/local/bin/k3s kubectl get nodes -o wide`` which should produce output like:

```
NAME    STATUS   ROLES    AGE    VERSION         INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                         KERNEL-VERSION   CONTAINER-RUNTIME
pike2   Ready    <none>   4d1h   v1.16.2-k3s.1   10.2.14.69    <none>        Raspbian GNU/Linux 10 (buster)   4.19.75-v7+      docker://19.3.5
```

The ``Ready`` status shows that the worker node has joined the cluster correctly.


The same ```k3s agent``` command can be run on other nodes (on which smarter-cni and k3s have been installed) to add more nodes to the cluster.

```
NAME    STATUS   ROLES    AGE   VERSION         INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                         KERNEL-VERSION   CONTAINER-RUNTIME
pike2   Ready    <none>   47h   v1.16.3-k3s.2   10.2.14.69    <none>        Raspbian GNU/Linux 10 (buster)   4.19.75-v7+      docker://19.3.5
pike1   Ready    <none>   47h   v1.16.3-k3s.2   10.2.14.53    <none>        Raspbian GNU/Linux 10 (buster)   4.19.50-v7+      docker://18.9.0
```


## Running an application

Here is a YAML description for an example application that can be deployed to the cluster. It's described as a Kubernetes **dameonset** and will be deployed on each node in the cluster:

```
kind: DaemonSet
apiVersion: apps/v1
metadata:
  name: example
  labels:
    k3s-app: example
spec:
  selector:
    matchLabels:
      name: example
  template:
    metadata:
      labels:
        name: example
    spec:
      hostname: example
      containers:
      - name: example-dummy-pod
        image: alpine
        command: ["/bin/ash", "-ec", "while :; do date; sleep 5 ; done"]

```

This application consists of a shell command running in an Alpine Linux image. It prints the current date and time onto standard out every five seconds.

To deploy: put the YAML description into a file and then apply it to the cluster:

```
$ k3s kubectl apply -f example.yaml
daemonset.apps/example created
```

The nodes may need to pull the Alpine Docker image after which the application should start running:

```
$ k3s kubectl get daemonsets,pods -o wide
NAME                     DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE   CONTAINERS          IMAGES   SELECTOR
daemonset.apps/example   2         2         2       2            2           <none>          85s   example-dummy-pod   alpine   name=example

NAME                READY   STATUS    RESTARTS   AGE   IP           NODE    NOMINATED NODE   READINESS GATES
pod/example-ksd9z   1/1     Running   0          85s   172.38.0.3   pike2   <none>           <none>
pod/example-f6mvv   1/1     Running   0          85s   172.38.0.3   pike1   <none>           <none>
```

You can use the k3s command to view the output from the application running. For example, looking at the output of a particular pod:

```
$ k3s kubectl logs pod/example-ksd9z
Fri Dec  6 15:56:39 UTC 2019
Fri Dec  6 15:56:44 UTC 2019
Fri Dec  6 15:56:49 UTC 2019
```


The application can be removed from all the nodes with a single command:

```
$ k3s kubectl delete daemonset.apps/example
daemonset.apps "example" deleted
```

