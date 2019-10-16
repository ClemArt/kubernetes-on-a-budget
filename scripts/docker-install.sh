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

systemctl daemon-reload
systemctl enable --now docker