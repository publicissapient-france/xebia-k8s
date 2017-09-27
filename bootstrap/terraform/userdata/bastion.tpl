#!/bin/bash

KUBESPRAY_ROOT_DIR=/srv/kubespray
KUBESPRAY_REPO_DIR=$KUBESPRAY_ROOT_DIR/repo
KUBESPRAY_REPO_URL=https://github.com/kubernetes-incubator/kubespray.git

apt update
apt install -y python-pip unzip git
pip install ansible==${ansible_version}

wget https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_linux_amd64.zip -O /tmp/terraform.zip && \
    unzip /tmp/terraform.zip -d /usr/local/bin && \
    rm /tmp/terraform.zip

curl -o /usr/local/bin/kubectl -L https://storage.googleapis.com/kubernetes-release/release/${kubectl_version}/bin/linux/amd64/kubectl && \
    chmod a+x /usr/local/bin/kubectl

mkdir -p $KUBESPRAY_REPO_DIR && \
    git clone $KUBESPRAY_REPO_URL $KUBESPRAY_REPO_DIR && \
    cd $KUBESPRAY_REPO_DIR && \
    git checkout ${kubespray_version}
