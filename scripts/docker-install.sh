#!/bin/bash
# From https://docs.docker.com/install/linux/docker-ce/centos/
yum install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce docker-ce-cli containerd.io


mkdir -p /etc/systemd/system/docker.service.d
cat <<EOF > /etc/systemd/system/docker.service.d/10-docker-opts.conf
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock --iptables=false --ip-masq=false
EOF

# Setup daemon
mkdir -p /etc/docker
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF

systemctl daemon-reload
systemctl enable docker
systemctl restart docker
