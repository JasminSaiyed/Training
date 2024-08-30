Task 1 : Connection of worker node with master using kubeadm
Kubernetes Cluster Setup

This guide outlines the steps to set up a Kubernetes cluster using containerd as the container runtime and Calico for networking. Follow these instructions on both the Control Plane node and Worker nodes.
Prerequisites

    Ubuntu 20.04 or later
    Access to all nodes (Control Plane and Worker nodes)
    Root or sudo access on all nodes
![img-1](<Screenshot from 2024-08-29 17-31-57.png>)
![img-2](<Screenshot from 2024-08-29 17-32-04.png>)
![img-3](<Screenshot from 2024-08-29 17-32-08.png>)
![img-4](<Screenshot from 2024-08-29 22-51-31.png>)
1. Install Packages on All Nodes
- Configure Containerd

Create Configuration File:
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
- Load Modules
sudo modprobe overlay
sudo modprobe br_netfilter

Set System Configurations:
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
![img-5](<Screenshot from 2024-08-29 22-55-42.png>)
sudo sysctl --system
Install containerd:
sudo apt-get update && sudo apt-get install -y containerd.io
![img-6](<Screenshot from 2024-08-29 22-56-04.png>)
Create and Generate Default Configuration:

sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo systemctl restart containerd
Verify containerd is Running:
sudo systemctl status containerd
![img-7](<Screenshot from 2024-08-29 22-56-26.png>)


Disable Swap:
sudo swapoff -a
Install Dependency Packages:
sudo apt-get update && sudo apt-get install -y apt-transport-https curl
Add Kubernetes GPG Key and Repository:

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.27/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.27/deb/ /
EOF
sudo apt-get update
![img-8](<Screenshot from 2024-08-28 21-06-58.png>)
Install Kubernetes Packages:
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
Initialize the Cluster on the Control Plane Node

Initialize Kubernetes:

sudo kubeadm init --pod-network-cidr 192.168.0.0/16 --kubernetes-version 1.27.11

Set kubectl Access:

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

Test Access:

kubectl get nodes
 Install the Calico Network Add-On

Apply Calico Manifest:

kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml

Check Node Status:

kubectl get nodes
Join Worker Nodes to the Cluster

Create Join Command on Control Plane Node:

kubeadm token create --print-join-command
![img-9](<Screenshot from 2024-08-28 21-16-55.png>)

Run Join Command on Each Worker Node:

sudo kubeadm join <control-plane-endpoint>
![img-10](<Screenshot from 2024-08-28 22-25-07.png>)

Verify Cluster Status on Control Plane Node:

kubectl get nodes
![img-11](<Screenshot from 2024-08-30 11-44-23.png>)

TASK 2- Installation of Grafana
Step :1

    Install the prerequisite packages:

    (Prerequisite packages are software components or dependencies that are required for the installation or execution of a primary package, application, or software)

sudo apt-get install -y apt-transport-https software-properties-common wget

    Import the GPG key:

(Based on the provided search results, a GPG (GNU Privacy Guard) key is a cryptographic key used for encryption, decryption, signing, and verification of data and communications.)

sudo mkdir -p /etc/apt/keyrings/

wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null

![img-01](<Screenshot from 2024-08-30 11-50-28.png>)


    To add a repository for stable releases, run the following command:

echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list

    Run the following command to update the list of available packages:

sudo apt-get update

    To install Grafana OSS, run the following command:

# Installs the latest OSS release:

sudo apt-get install grafana
![img-02](<Screenshot from 2024-08-30 11-51-15.png>)

To install Grafana Enterprise, run the following command:

sudo apt-get install grafana-enterprise
![img-03](<Screenshot from 2024-08-30 11-52-07.png>)

    Verify installation

grafana-cli --version
![img-04](<Screenshot from 2024-08-30 11-52-47.png>)

    Now once it get installed start the server using

sudo systemctl start grafana-server.service

    And Then verify using

sudo systemctl status grafana-server.service
![img-05](<Screenshot from 2024-08-30 11-53-20.png>)
![img-06](<Screenshot from 2024-08-30 11-54-25.png>)
![img-07](<Screenshot from 2024-08-30 11-55-56.png>)
![img-08](<Screenshot from 2024-08-30 11-56-41.png>)