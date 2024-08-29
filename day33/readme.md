Deploying a Multi-Tier Application Using Helm on Kubernetes and AWS Free Tier Services
This 2-hour activity combines the use of Helm in Kubernetes with deploying and integrating free-tier AWS services. You will deploy a multi-tier application on Minikube using Helm, manage Helm charts, secrets, and RBAC, and integrate AWS services like S3 for storage and RDS (MySQL) for the database. The project will focus on versioning, packaging, rollback, and proper management of cloud resources.
Estimated Duration: 2 Hours
Project Objectives:
Deploy a multi-tier application using Helm on Minikube.
Integrate AWS free-tier services (S3 and RDS).
Manage Helm charts, including versioning, packaging, and rollbacks.
Implement Helm secrets management and RBAC.
Handle dependencies between different components of the application.
Project Deliverables:
1. Setup Helm and Minikube
Ensure Minikube is running.
![img-1](<Screenshot from 2024-08-29 14-57-50.png>)
Install and configure Helm on the local machine.
2. AWS Services Setup
S3 Bucket: Create an S3 bucket for storing application assets (e.g., static files for the frontend).
![img-2](<Screenshot from 2024-08-29 14-23-23.png>)
RDS Instance: Set up an Amazon RDS MySQL instance in the free tier.
![img-3](<Screenshot from 2024-08-29 15-47-23.png>)
3. Create Helm Charts
Frontend Chart: Create a Helm chart for a frontend service (e.g., NGINX) that pulls static files from the S3 bucket.
Backend Chart: Create a Helm chart for a backend service (e.g., a Python Flask API) that connects to the RDS MySQL database.
Database Chart: Include configurations for connecting to the RDS MySQL instance in the backend chart.
![img-4](<Screenshot from 2024-08-29 15-02-09.png>)
![img-5](<Screenshot from 2024-08-29 15-02-14.png>)
4. Package Helm Charts
Package each Helm chart into a .tgz file.
Ensure charts are properly versioned.
![img-6](<Screenshot from 2024-08-29 15-03-41.png>)
5. Deploy Multi-Tier Application Using Helm
Deploy the database chart (connected to the RDS instance).
Deploy the backend chart with dependency on the database chart.
Deploy the frontend chart with dependency on the backend service, ensuring it pulls assets from the S3 bucket.
Manage Helm Secrets
Implement Helm secrets for managing sensitive data such as database credentials and S3 access keys.
Update the backend chart to use these secrets for connecting to the RDS instance and S3.
Implement RBAC
Define RBAC roles and role bindings to manage permissions for Helm deployments.
Ensure that only authorized users can deploy or modify the Helm releases.
Versioning and Rollback
Update the version of one of the Helm charts (e.g., update the frontend service).
Perform a rollback if necessary and validate the application functionality.
create helm-role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: helm-role
  namespace: default
rules:
  - apiGroups: [""]
    resources: ["pods", "services", "configmaps", "secrets", "endpoints", "persistentvolumeclaims"]
    verbs: ["watch", "create", "update", "patch", "delete"]
  - apiGroups: ["apps"]
    resources: ["deployments", "replicasets", "statefulsets"]
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
  - apiGroups: ["batch"]
    resources: ["jobs"]
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
  - apiGroups: ["helm.sh"]
    resources: ["releases"]
    verbs: ["get", "list", "watch", "create", "update", "delete"]
create helm-rolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: helm-rolebinding
  namespace: default # Change this to your desired namespace
subjects:
  - kind: ServiceAccount
    name: helm-service-account # Change this to the service account or user you want to grant permissions to
    namespace: default # Change this to the namespace of the service account
roleRef:
  kind: Role
  name: helm-role
  apiGroup: rbac.authorization.k8s.io
create helm-service-account.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: helm-service-account
  namespace: default
9. Validate Deployment
Ensure the frontend service is serving files from the S3 bucket.
Validate that the backend service is successfully communicating with the RDS MySQL database.
Test the overall functionality of the deployed application.
![img-7](<Screenshot from 2024-08-29 15-28-21.png>)
![img-8](<Screenshot from 2024-08-29 15-28-14.png>)
![img-9](<Screenshot from 2024-08-29 15-28-32.png>)
![img-10](<Screenshot from 2024-08-29 15-31-53.png>)
![imh-11](<Screenshot from 2024-08-29 15-31-59.png>)
![img-12](<Screenshot from 2024-08-29 15-32-06.png>)
![img-13](<Screenshot from 2024-08-29 15-32-12.png>)
![img-14](<Screenshot from 2024-08-29 15-41-53.png>)
![img-15](<Screenshot from 2024-08-29 15-42-37.png>)

