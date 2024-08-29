 Launch AWS Instances
1.1. Create AWS EC2 Instances

Log in to AWS Management Console: Go to AWS Management Console.

Navigate to EC2 Dashboard: Select EC2 from the services menu.

Launch Instances:

    Click on Launch Instance.
    Choose an AMI: Select an appropriate Ubuntu Server AMI (e.g., Ubuntu 22.04 LTS).
    Choose an Instance Type: For testing, t2.micro or t3.micro are good options. For production, choose a type based on your requirements.
    Configure Instance: Set the number of instances, network, and subnet as needed. Ensure you have at least one public IP for access.
    Add Storage: Use default storage or adjust according to your needs.
    Add Tags: Optionally, tag your instances (e.g., Name=master-node for the control plane and Name=worker-node for the worker).
1. Log in to Control Node
2. Install Packages
On All Nodes (Control Plane and Workers)
Create the Configuration File for containerd:
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
![img-1](<Screenshot from 2024-08-28 16-19-01.png>)
![img-2](<Screenshot from 2024-08-28 16-55-09.png>)
Load the Modules:

sudo modprobe overlay
sudo modprobe br_netfilter
![img-3](<Screenshot from 2024-08-28 16-19-33.png>)
Set the System Configurations for Kubernetes Networking:

cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
![img-4](<Screenshot from 2024-08-28 16-20-05.png>)

Apply the New Settings:

sudo sysctl --system
![img-5](<Screenshot from 2024-08-28 16-20-36.png>)

Install containerd:

sudo apt-get update && sudo apt-get install -y containerd.io
![img-6](<Screenshot from 2024-08-28 16-57-01.png>)

Create the Default Configuration File for containerd:

sudo mkdir -p /etc/containerd
![img-7](<Screenshot from 2024-08-28 16-45-47.png>)

![img-8](<Screenshot from 2024-08-28 16-45-47-1.png>)
Generate the Default containerd Configuration and Save It:

sudo containerd config default | sudo tee /etc/containerd/config.toml

Restart containerd:

sudo systemctl restart containerd

Verify that containerd is Running:

sudo systemctl status containerd
![img-9](<Screenshot from 2024-08-28 21-04-50.png>)
Disable Swap:

sudo swapoff -a

Install Dependency Packages:

sudo apt-get update && sudo apt-get install -y apt-transport-https curl

Download and Add the GPG Key:

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.27/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

Add Kubernetes to the Repository List:

cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.27/deb/ /
EOF

Update the Package Listings:
sudo apt-get update
![img-10](<Screenshot from 2024-08-28 21-06-33.png>)

sudo apt-get install -y kubelet kubeadm kubectl

sudo apt-mark hold kubelet kubeadm kubectl

![img-11](<Screenshot from 2024-08-28 17-01-18.png>)
![img-12](<Screenshot from 2024-08-28 17-01-42.png>)

3. Initialize the Cluster
On the Control Plane Node, Initialize the Kubernetes Cluster:

sudo kubeadm init --pod-network-cidr 192.168.0.0/16 --kubernetes-version 1.27.11

Set kubectl Access:

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

Test Access to the Cluster:

kubectl get nodes
4. Install the Calico Network Add-On
On the Control Plane Node, Install Calico Networking:

kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml


Check the Status of the Control Plane Node:

kubectl get nodes

5. Join the Worker Nodes to the Cluster
On the Control Plane Node, Create the Token and Copy the Join Command:

kubeadm token create --print-join-command
![img-13](<Screenshot from 2024-08-28 17-51-30.png>)
![img-14](<Screenshot from 2024-08-28 21-16-55.png>)
On Each Worker Node, Paste the Full Join Command:

sudo kubeadm join…

![img-15](<Screenshot from 2024-08-28 22-24-27.png>)

On the Control Plane Node, View the Cluster Status:

kubectl get nodes
![img-16](<Screenshot from 2024-08-28 22-25-56.png>)