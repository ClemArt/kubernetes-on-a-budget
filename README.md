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
  - [Provision VM](#provision-vm)
  - [Install Docker](#install-docker)
  - [Install Etcd](#install-etcd)
- [Troubleshoting](#troubleshoting)
  - [Entreprise proxy](#entreprise-proxy)

# Installed components

* docker @latest (v19)
* etcd @v3.4.2
* kubeadm @latest (v1.16)
* kubelet @latest (v1.16)
* kubectl @latest (v1.16)

# Automated Provisioning
## Provisioning VM, dependencies & Data plane
In a terminal run

    vagrant up --provision-with "ca_dependencies,file,placeholders,docker,etcd"

This installs CA certificates, provisioning shell scripts, then launches Docker and Etcd

Etcd is created as a 3 member cluster scatered accross the 3 VMs. It's provisioned by hand for demonstration purpose only. One could use kubeadm in the next step with the `--control-plane` option to provision a secured and resilient data plane.

## Provisioning K8S
In a terminal run

    vagrant provision --provision-with "k8s,kubeadm"

This installs k8s binaries and uses kubeadm to bootstrap a control plane (kube-scheduler, kube-apiserver, coredns, kube-controller-manager)

**node-1** is the cluster's master, and the API endpoint is reachable at https://192.168.10.11:6443

# Step by Step Provisioning
## Provision VM

    vagrant up --provision-with "ca_dependencies,file,placeholders"

## Install Docker

    vagrant provision --provision-with "docker"

## Install Etcd

    vagrant provision --provision-with "etcd"

# Troubleshoting
## Entreprise proxy

* Install the **vagrant-proxyconf** plugin : https://github.com/tmatilai/vagrant-proxyconf
* Make sure your **HTTP_PROXY**, **HTTPS_PROXY** and **NO_PROXY** environment variables are set with proxy URL
  * Typically

        HTTP_PROXY = http://myproxy.org:port    
        HTTPS_PROXY = http://myproxy.org:port
        NO_PROXY = localhost,127.0.0.1,192.168.10.0/24

If your proxy is of type MITM, you should create a `ssl` folder next to the `Vagrantfile` and put the proxy's root CA in here. Then you can use the `custom_ssl` provisioner to trust these new CA. 