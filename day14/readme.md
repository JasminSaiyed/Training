Project 01
Problem Statement:

You are tasked with setting up a CI/CD pipeline using Jenkins to streamline the deployment process of a simple Java application. The pipeline should accomplish the following tasks:

    Fetch the Dockerfile: The pipeline should clone a GitHub repository containing the source code of the Java application and a Dockerfile.

    Create a Docker Image: The pipeline should build a Docker image from the fetched Dockerfile.

    Push the Docker Image: The pipeline should push the created Docker image to a specified DockerHub repository.

    Deploy the Container: The pipeline should deploy a container using the pushed Docker image.

![alt text](<Screenshot from 2024-07-31 15-36-21.png>)


Jenkins pipeline script

ipeline{

    agent any

    environment{
        dockerImage = ''
        registry = 'jasmin001/day15'
        // registryCredentials = 'Docker'
    }

    stages{
        stage('Build Docker Image'){
            steps{
                script{ 
                    dockerImage = docker.build("${registry}:latest")
                }
            }
        }
        stage('Push Docker Image'){
            steps{
                script{
                    docker.withRegistry('', 'Docker'){
                        dockerImage.push()
                    }
                }
            }
        }
    }
}


dockerfile

FROM openjdk:11
COPY . /usr/src/myapp
WORKDIR /usr/src/myapp
RUN javac App.java
CMD ["java", "App"]



