pipeline{

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
