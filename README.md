# Kubernetes on a Budget
A small demonstration of how to run a k8s cluster on 3 lowcost VM, automatically provisionned with Vagrant and shell scripts.

# TOC
- [Kubernetes on a Budget](#kubernetes-on-a-budget)
- [TOC](#toc)
- [Installed components](#installed-components)
- [Automated Provisioning](#automated-provisioning)
  - [Provisioning VM, dependencies & Data plane](#provisioning-vm-dependencies--data-plane)
  - [Provisioning K8S](#provisioning-k8s)
- [Step by Step Provisioning](#step-by-step-provisioning)
- [Addons](#addons)
  - [Metrics](#metrics)
- [Troubleshoting](#troubleshoting)
  - [Entreprise proxy](#entreprise-proxy)
- [Sources & Credits](#sources--credits)

# Installed components

* docker @latest (v19)
* etcd @v3.4.2
* kubeadm @latest (v1.16)
* kubelet @latest (v1.16)
* kubectl @latest (v1.16)

# Automated Provisioning
## Provisioning VM, dependencies & Data plane
In a terminal run

    vagrant up --provision-with "prerequisite,file,placeholder,docker,etcd"

This installs prerequisites, provisioning shell scripts, then launches Docker and Etcd

Etcd is created as a 3 member cluster scatered accross the 3 VMs. It's provisioned by hand for demonstration purpose only. One could use kubeadm in the next step with the `--control-plane` option to provision a secured and resilient data plane.

## Provisioning K8S
In a terminal run

    vagrant provision --provision-with "k8s,kubeadm,k8s_cni"

This installs k8s binaries and uses kubeadm to bootstrap a control plane (kube-scheduler, kube-apiserver, coredns, kube-controller-manager).

**node-1** is the cluster's master, and the API endpoint is reachable at https://192.168.10.11:6443.

Installs WeaveNet **unencrypted** as a CNI plugin provider.

# Step by Step Provisioning

    vagrant provision --provision-with "provider1,provider2,..."

Each provider is a shell script with a specific goal (in order of provisioning) :

| name         | actions                                                                                                                                                          |
|--------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| prerequisite | Install prerequisites yum package                                                                                                                                |
| custom_ssl   | Copy the content of the `ssl` folder in working directory to the trusted CA sources of centos, then update the trust CA bundle                                   |
| file         | Copy `scripts` folder in `guest:/tmp/scripts`                                                                                                                    |
| placeholder  | Use `sed` to replace some `${PLACEHOLDER}` in the script files (sort of very light templating)                                                                   |
| docker       | Install and configure Docker daemon                                                                                                                              |
| etcd         | Install and configure a 3 nodes ETCD cluster. *Mandatory* to run k8s & kubeadm steps                                                                             |
| k8s          | Install k8s binaries                                                                                                                                             |
| kubeadm      | Boostrap node-1 as a k8s master, then join node-{2,3} as worker nodes. Configure the control plane and kubelet, using a totally insecure token to join the nodes |
| k8s_cni      | Install WeaveNet CNI plugin by applying the `net.yml` file to the cluster's master (*node-1*)                                                                    |

# Addons
## Metrics
See [metrics-server](./metrics-server/README.md)

# Troubleshoting
## Entreprise proxy

* Install the **vagrant-proxyconf** plugin : https://github.com/tmatilai/vagrant-proxyconf
* Make sure your **HTTP_PROXY**, **HTTPS_PROXY** and **NO_PROXY** environment variables are set with proxy URL
  * Typically

        HTTP_PROXY = http://myproxy.org:port    
        HTTPS_PROXY = http://myproxy.org:port
        NO_PROXY = localhost,127.0.0.1

If your proxy is of type MITM, you should create a `ssl` folder next to the `Vagrantfile` and put the proxy's root CA in here. Then you can use the `custom_ssl` provisioner to trust these new CA.

# Sources & Credits

* Hobby-kube : https://github.com/hobby-kube/guide
* Kubernetes the hard way : https://github.com/kelseyhightower/kubernetes-the-hard-way
* Kubernetes Docs : https://kubernetes.io/docs/home/
* Docker Docs : https://docs.docker.com/reference/
* Weave net : https://www.weave.works/docs/net/latest/kubernetes/