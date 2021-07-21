#!/bin/bash
# Añadir repositorio de Docker
if [[ "$EUID" = 0 ]]; then
    echo "[INFO] EJECUTANDO COMO ROOT"
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

    # Añadir repositorio de Kubernetes
    cat << EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
    deb https://apt.kubernetes.io/ kubernetes-xenial main
    EOF

    # Actualizar e instalar paquetes
    sudo apt update
    sudo apt install -y docker-ce=5:19.03.10~3-0~ubuntu-focal kubelet=1.18.5-00 kubeadm=1.18.5-00 kubectl=1.18.5-00

    #En el Master arrancarlo como Master
    sudo kubeadm init --pod-network-cidr=10.244.0.0/16
    # Si da error, consultar esta guía con la parte de Docker. 
    # https://kubernetes.io/docs/setup/production-environment/container-runtimes/#docker

    # Crear directorios de trabajo
    sudo mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
    kubectl apply -f https://docs.projectcalico.org/v3.14/manifests/calico.yaml
else
    sudo -k # make sure to ask for password on next sudo
    if sudo true; then
        echo "(2) correct password"
    else
        echo "(3) wrong password"
        exit 1
    fi
fi


