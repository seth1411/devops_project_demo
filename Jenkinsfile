pipeline {
    agent any

    environment {
        // !!! REPLACE THIS with your actual Docker Hub Username !!!
        DOCKERHUB_USER = 'YOUR_DOCKERHUB_USERNAME'
        
        // This is the ID you set in Jenkins Credentials Manager for Docker Hub login
        DOCKER_CRED_ID = 'dockerhub-credentials-id' 
        
        APP_NAME = 'hello-app'
        IMAGE_TAG = "${DOCKERHUB_USER}/${APP_NAME}:${env.BUILD_NUMBER}"
        K8S_MANIFEST = 'deployment.yaml'
    }

    stages {
        stage('Checkout Source') {
            steps {
                echo '1. Checking out source code from Git...'
                checkout scm
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                script {
                    echo "2. Building image: ${IMAGE_TAG}"
                    
                    // Build the Docker image
                    docker.build(IMAGE_TAG, "-f Dockerfile .")

                    // Push to Docker Hub using stored credentials
                    withCredentials([usernamePassword(credentialsId: DOCKER_CRED_ID, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh "docker login -u ${DOCKER_USER} -p ${DOCKER_PASS}"
                        sh "docker push ${IMAGE_TAG}"
                        sh "docker tag ${IMAGE_TAG} ${DOCKERHUB_USER}/${APP_NAME}:latest"
                        sh "docker push ${DOCKERHUB_USER}/${APP_NAME}:latest"
                    }
                    echo "Image pushed successfully to Docker Hub."
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    echo '3. Updating Kubernetes manifest and applying...'
                    
                    // Use sed to replace the placeholder image tag with the one just pushed (critical step!)
                    sh "sed -i '' 's|${DOCKERHUB_USER}/${APP_NAME}:latest|${IMAGE_TAG}|g' ${K8S_MANIFEST}"

                    // Apply the changes to the local Kubernetes cluster
                    sh "kubectl apply -f ${K8S_MANIFEST}"
                    
                    echo "Deployment to Kubernetes complete. Access on NodePort 30080."
                }
            }
        }
    }
}
