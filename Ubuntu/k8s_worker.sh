#!/bin/bash
if [[ "$EUID" = 0 ]]; then
    echo "[INFO] EJECUTANDO COMO ROOT"
    
    # Añadir repositorio de Docker
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
    
    # Añadir repositorio de Kubernetes
    cat << EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
    deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
    # Actualizar e instalar paquetes necesarios
    sudo apt update
    sudo apt install -y docker-ce=5:19.03.10~3-0~ubuntu-focal kubelet=1.18.5-00 kubeadm=1.18.5-00 kubectl=1.18.5-00
else
    sudo -k # make sure to ask for password on next sudo
    if sudo true; then
        echo "[INFO] CONTRASEÑA CORRECTA"
    else
        echo "[ERROR] CONTRASEÑA INCORRECTA"
        exit 1
    fi
fi

