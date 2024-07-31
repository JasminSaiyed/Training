Day-9 Task
Stage 1: Setting Up the Kubernetes Cluster and Static Web App
1. Set Up Minikube:

    Ensure Minikube is installed and running on the local Ubuntu machine.
    Verify the Kubernetes cluster is functioning correctly.
2. Deploy Static Web App:
Create a Dockerfile for a simple static web application (e.g., an HTML page served by Nginx).
Build a Docker image for the static web application
3. Kubernetes Deployment:

    Write a Kubernetes deployment manifest to deploy the static web application.
    Write a Kubernetes service manifest to expose the static web application within the cluster.
    Apply the deployment and service manifests to the Kubernetes cluster.
4. Install and Configure Ingress Controller:

    Install an ingress controller (e.g., Nginx Ingress Controller) in the Minikube cluster.
    Verify the ingress controller is running and accessible.

5. Create Ingress Resource:

    Write an ingress resource manifest to route external traffic to the static web application.
    Configure advanced ingress rules for path-based routing and host-based routing (use at least two different hostnames and paths).
    Implement TLS termination for secure connections.
    Configure URL rewriting in the ingress resource to modify incoming URLs before they reach the backend services.
    Enable sticky sessions to ensure that requests from the same client are directed to the same backend pod.


index.html code

<!DOCTYPE html>
<html>
<head>
    <title>Static Web App</title>
</head>
<body>
    <h1>Hello, Kubernetes!</h1>
</body>
</html>

    ingress code

    apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: mystaticwebsite-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/affinity: "cookie"
spec:
  tls:
  - hosts:
    - anotherexample.com
    secretName: tls-secret
  rules:
  - host: anotherexample.com
    http:
      paths:
      - path: /app1
        pathType: Prefix
        backend:
          service:
            name: mystaticwebsite-service
            port:
              number: 80
  - host: anotherexample.com
    http:
      paths:
      - path: /app2
        pathType: Prefix
        backend:
          service:
            name: mystaticwebsite-service
            port:
              number: 80

 deployment code

 apiVersion: apps/v1
kind: Deployment
metadata:
  name: static-web
spec:
  replicas: 3
  selector:
    matchLabels:
      app: static-web
  template:
    metadata:
      labels:
        app: static-web
    spec:
      containers:
      - name: nginx
        image: jasmin001/day9:latest
        ports:
        - containerPort: 80

Dockerfile 

# Use the official Nginx image as the base image
FROM nginx:alpine

# Copy the static HTML file to the Nginx HTML directory
COPY index.html /usr/share/nginx/html/index.html

# Expose port 80
EXPOSE 80

hpa file

apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: webapp-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: webapp-deployment
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50

perfomed task image1


![alt text](<Screenshot from 2024-07-19 16-38-55.png>)

performed task image2


![alt text](<Screenshot from 2024-07-19 16-36-21.png>)

performed task image3


![alt text](<Screenshot from 2024-07-19 14-27-54.png>)

performed task image4


![alt text](<Screenshot from 2024-07-19 16-35-16.png>)

performed task image5


![alt text](<Screenshot from 2024-07-19 16-34-29.png>)
