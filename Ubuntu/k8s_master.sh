#!/bin/bash
## FUNCIONES
main () {
if [[ "$EUID" = 0 ]]; then
    echo "[INFO] EJECUTANDO COMO ROOT"
    node_config
else
    echo "[ERROR] EJECUTANDO COMO NO ROOT"
    exit 1
fi

}

node_config () {
    ##### Disable Firewall
    sudo ufw disable
    ##### Disable swap
    sudo swapoff -a; sed -i '/swap/d' /etc/fstab
    ##### Update sysctl settings for Kubernetes networking
    sudo cat >>/etc/sysctl.d/kubernetes.conf<<EOF
    net.bridge.bridge-nf-call-ip6tables = 1
    net.bridge.bridge-nf-call-iptables = 1
EOF
    sudo sysctl --system
    ##### Install docker engine
    sudo apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt update
    sudo apt install -y docker-ce=5:19.03.10~3-0~ubuntu-focal containerd.io

    ### Kubernetes Setup
    ##### Add Apt repository
    sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
    sudo echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list

    ##### Install Kubernetes components
    sudo apt update && apt install -y kubeadm=1.18.5-00 kubelet=1.18.5-00 kubectl=1.18.5-00

    ##### In case you are using LXC containers for Kubernetes nodes
    sudo mknod /dev/kmsg c 1 11
    sudo echo '#!/bin/sh -e' >> /etc/rc.local
    sudo echo 'mknod /dev/kmsg c 1 11' >> /etc/rc.local
    sudo chmod +x /etc/rc.local
    check_node
}

check_node () {
node_type="0"
while [ $node_type -eq 0 ]
do
    read -p "Selecciona el tipo de nodo: master (1) o worker (2): " node_type
    if [ $node_type -eq 1 ];then
        echo "[INFO] Has elegido el nodo master."
        master_config
    elif [ $node_type -eq 2 ];then
        echo "[INFO] Has elegido el nodo worker."
        worker_config
    else
        echo ""
        echo "[ERROR] El nodo elegido no es correcto."
        node_type="0"
    fi
done
}


master_config () {
    ## On kmaster
    ##### Initialize Kubernetes Cluster
    sudo kubeadm init --apiserver-advertise-address=192.168.1.240 --pod-network-cidr=10.99.0.0/16  --ignore-preflight-errors=all

    ##### Deploy Calico network
    sudo kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://docs.projectcalico.org/v3.14/manifests/calico.yaml

    ##### Cluster join command
    sudo kubeadm token create --print-join-command

    ##### To be able to run kubectl commands as non-root user
    #mkdir -p $HOME/.kube
    #sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    #sudo chown $(id -u):$(id -g) $HOME/.kube/config
}

worker_config () {
    echo "[INFO] Introduce el token generado en el Master"
}

## EJECUCIOn
main










