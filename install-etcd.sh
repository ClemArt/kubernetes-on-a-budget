#!/bin/bash
# From https://github.com/etcd-io/etcd/releases/tag/v3.4.2
set -e

ETCD_VER=v3.4.2

if [ ! -f /opt/etcd/etcd ]; then
  mkdir -p /opt/etcd

  # choose either URL
  GOOGLE_URL=https://storage.googleapis.com/etcd
  GITHUB_URL=https://github.com/etcd-io/etcd/releases/download
  DOWNLOAD_URL=${GITHUB_URL}

  curl -L ${DOWNLOAD_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o /opt/etcd-${ETCD_VER}-linux-amd64.tar.gz

  tar xzvf /opt/etcd-${ETCD_VER}-linux-amd64.tar.gz -C /opt/etcd --strip-components=1
fi

/opt/etcd/etcd --version
/opt/etcd/etcdctl version