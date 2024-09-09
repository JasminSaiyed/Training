## Project: Modular E-Commerce Application Deployment with S3 Integration
Project Duration: 8 Hours
Project Overview: In this project, participants will deploy a modular e-commerce application using AWS services and DevOps tools. The application will be set up to fetch static assets from an S3 bucket. Participants will use Terraform to manage infrastructure as code with modularization, Docker for containerization, Kubernetes for orchestration, and Helm for deployments. The goal is to create a scalable, maintainable solution that integrates various AWS services and DevOps practices.
# Project Objectives:
    1. Modular Infrastructure: Use Terraform to create and manage modular infrastructure components.
    2. Static Asset Storage: Store and fetch static assets from an S3 bucket.
    3. Containerization: Package the application using Docker.
    4. Orchestration: Deploy the application on Kubernetes.
    5. CI/CD Pipeline: Automate the build and deployment process using Jenkins.
    6. Configuration Management: Use Ansible for configuration management.
    7. Deployment: Deploy the application using Helm charts.
    8. AWS Resources: Utilize AWS EC2 free tier instances for deployment.
# Project Tasks and Timeline
1. Set Up AWS EC2 Instances (30 Minutes)
    • Launch three EC2 instances of type t2.micro (1 master node, 2 worker nodes) within the free tier.
    • Configure security groups to allow necessary ports (e.g., 22 for SSH, 80 for HTTP, 443 for HTTPS).
    • SSH into the instances and prepare for Kubernetes installation.
![img-1](<Screenshot from 2024-09-02 18-04-05.png>)
![img-2](<Screenshot from 2024-09-02 18-07-03.png>)
![img-3](<Screenshot from 2024-09-02 18-05-35.png>)

2. Create and Configure S3 Bucket (30 Minutes)
    • Create an S3 bucket to store static assets (e.g., product images, stylesheets).
    • Upload sample static files to the S3 bucket.
    • Configure bucket policy to allow read access for the application.
![img-4](<Screenshot from 2024-09-02 18-08-09.png>)
![img-5](<Screenshot from 2024-09-02 18-08-30.png>)
![img-6](<Screenshot from 2024-09-02 18-08-41.png>)
![img-7](<Screenshot from 2024-09-02 18-08-50.png>)
3. Set Up Kubernetes Cluster (60 Minutes)
    • On Master Node:
        ◦ Install Kubeadm, Kubelet, and Kubectl.
        ◦ Initialize the Kubernetes cluster using Kubeadm.
        ◦ Set up a network plugin (e.g., Calico, Flannel).
![img-8](<Screenshot from 2024-09-02 18-07-03-1.png>)
![img-9](<Screenshot from 2024-09-02 18-07-12.png>)
    • On Worker Nodes:
        ◦ Join worker nodes to the master node.
    • Verify Cluster: Deploy a sample application (e.g., Nginx) to ensure the cluster is functional.
![img-10](<Screenshot from 2024-09-02 18-07-42.png>)
![img-11](<Screenshot from 2024-09-02 18-07-46.png>)
![img-12](<Screenshot from 2024-09-04 10-06-12.png>)
![img-13](<Screenshot from 2024-09-04 10-06-47.png>)
4. Modularize Infrastructure with Terraform (60 Minutes)
    • Create Terraform Modules:
        ◦ Network Module: Define VPC, subnets, and security groups.
create main.tf
resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "this" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-1"
}

output "vpc_id" {
  value = aws_vpc.this.id
}

output "subnet_id" {
  value = aws_subnet.this.id
}
        ◦ Compute Module: Define EC2 instances for Kubernetes nodes.
create main.tf
resource "aws_instance" "this" {
  ami           = "ami-0cab37bd176bb80d3"
  instance_type = "t2.micro"
  subnet_id     = var.subnet_id

  tags = {
    Name = "Kubernetes-Node"
  }

}

output "instance_id" {
  value = aws_instance.this.id
}

create variables.tf

variable "vpc_id" {
  description = "VPC ID where the instance will be deployed"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where the instance will be deployed"
  type        = string
}
variable "ami_id" {
  description = "The AMI ID to use for the EC2 instances"
  type        = string
}
        ◦ Storage Module: Define S3 bucket for static assets.
    • Main Configuration:
        ◦ Create a main.tf file to utilize the modules and provision the entire infrastructure.
create main.tf

resource "aws_s3_bucket" "this" {
  bucket = "unique-bucket-name-123456" # Replace with a new unique name
  acl    = "private"

  tags = {
    Name = "task1-jasmin"
  }
}


output "bucket_id" {
  value = aws_s3_bucket.this.id
}

create variables.tf

variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

     • Initialize and Apply:
        ◦ Run terraform init, terraform plan, and terraform apply to provision the infrastructure.
![img-13](<Screenshot from 2024-09-04 10-18-20.png>)
![img-14](<Screenshot from 2024-09-04 10-18-54.png>)
![img-15](<Screenshot from 2024-09-04 10-20-01.png>)
5. Containerize the Application with Docker (60 Minutes)
    • Dockerfile: Write Dockerfile for the e-commerce application.
    • Build Docker Image: Build Docker images using the Dockerfile.
    • Push to Registry: Push Docker images to a Docker registry (e.g., Docker Hub, Amazon ECR).
create Dockerfile
FROM nginx:alpine

# Copy the index.html to the Nginx HTML directory
COPY index.html /usr/share/nginx/html/index.html

# Expose port 80
EXPOSE 80
![img-16](<Screenshot from 2024-09-04 15-09-52.png>)

6. Configure Ansible for Application Deployment (30 Minutes)
    • Ansible Playbooks: Write playbooks to configure Kubernetes nodes and deploy the application.
    • Test Playbooks: Run Ansible playbooks to ensure correct configuration.
- create roles
- create ansible.cfg
[defaults]

private_key_file ="path of private key file"
remote_user = ubuntu
host_key_checking = False

gathering = smart
fact_caching = jsonfile
fact_caching_connection = /tmp/ansible_cache

[inventory_plugin.aws_ec2]
aws_access_key_id = "your access key id"
aws_secret_access_key = "secret access key "
aws_region = ap-northeast-2

[inventory]
enable_plugins = aws_ec2,yaml,ini
inventory=./aws_ec2.yml

- create aws_ec2.yml
plugin: aws_ec2
regions:
  - ap-northeast-2
filters:
  instance-state-name:
    - running
  tag:Name:
    - Jasmin-control
    - Jasmin-worker1
  tag:Node: 
    - Worker
    - Master
    -Worker
hostnames:
  - ip-address
compose:
  instance_id: instance_id
  ec2_region: placement.region
groups:
  master_nodes: "'Master' in tags['Node']"
  worker_nodes: "'Worker' in tags['Node']"

create deploy.yml
---
- name: Kubernetes Node Setup
  hosts: all
  become: yes
  roles:
    - k8s_nodes

- name: Setup Kubernetes Master Nodes
  hosts: master_nodes
  become: yes
  roles:
    - k8s_master

- name: Setup Kubernetes Worker Nodes
  hosts: worker_nodes
  become: yes
  roles:
    - k8s_worker

- create test_playbook.yml
---
- name: Test EC2 Inventory with Dynamic Data
  hosts: all
  tasks:
    - name: Print hostname and IP
      debug:
        msg: "Host: {{ inventory_hostname }} with instance-id: {{ instance_id }}"

    - name: Print instance tags
      debug:
 
7. Set Up Jenkins for CI/CD (60 Minutes)
    • Deploy Jenkins: Deploy Jenkins on Kubernetes using a Helm chart.
    • Configure Pipeline:
helm repo add jenkins https://charts.jenkins.io
helm install jenkins jenkins/jenkins

![img-17](<Screenshot from 2024-09-04 14-16-19.png>)
![img-18](<Screenshot from 2024-09-04 14-17-19.png>)

        ◦ Create a Groovy pipeline script in Jenkins for CI/CD.
        ◦ The pipeline should include stages for:
            ▪ Source Code Checkout: Pull code from the Git repository.
            ▪ Build Docker Image: Build Docker images from the Dockerfile.
            ▪ Push Docker Image: Push Docker image to Docker registry.
            ▪ Deploy to Kubernetes: Use Helm charts to deploy the Docker image to Kubernetes.
pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/your-repo/your-app.git'
            }
        }
        stage('Build') {
            steps {
                script {
                    sh 'docker build -t <your-docker-repo>/my-ecommerce-app:latest .'
                }
            }
        }
        stage('Push') {
            steps {
                script {
                    sh 'docker push <your-docker-repo>/my-ecommerce-app:latest'
                }
            }
        }
        stage('Deploy') {
            steps {
                script {
                    sh 'helm upgrade --install my-app ./helm/my-app'
                }
            }
        }
    }
}

![img-19](<Screenshot from 2024-09-02 17-41-38.png>)
![img-20](<Screenshot from 2024-09-02 18-06-37.png>)
8. Deploy the Application with Helm (60 Minutes)
    • Create Helm Charts: Define Helm charts for the e-commerce application deployment.
        ◦ Include configuration to fetch static files from the S3 bucket

Create Helm Charts:

Define Helm charts for your application.

helm/my-app/values.yaml

image:
  repository: <your-docker-repo>/final-task
  tag: latest

s3:
  bucket: "my-static-assets-bucket"

helm/my-app/templates/deployment.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
        - name: my-app
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          ports:
            - containerPort: 80
9. Clean Up Resources
Use Terraform to destroy all provisioned infrastructure:

terraform destroy
