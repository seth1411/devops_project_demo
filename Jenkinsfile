pipeline {
    agent any

    environment {
        DOCKERHUB_USER = '1411ayush' 
        // CRITICAL: Ensure this ID exactly matches your Username/Password credential ID in Jenkins
        DOCKER_CRED_ID = 'b9ce59ae-b9f5-4ada-b061-933157c5915d' 
        
        APP_NAME = 'hello-app'
        IMAGE_TAG = "${DOCKERHUB_USER}/${APP_NAME}:${env.BUILD_NUMBER}"
        K8S_MANIFEST = 'deployment.yaml'
        
        // Defining the placeholder used in deployment.yaml for SED
        OLD_IMAGE_URL = '1411ayush/hello-app:latest' 
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
                    
                    // 1. Build the Docker image
                    sh "docker build -t ${IMAGE_TAG} -f Dockerfile ."

                    // 2. Login and Push to Docker Hub using stored credentials
                    withCredentials([usernamePassword(credentialsId: DOCKER_CRED_ID, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh "docker login -u ${DOCKER_USER} -p ${DOCKER_PASS}"
                        sh "docker push ${IMAGE_TAG}"
                        sh "docker tag ${IMAGE_TAG} ${DOCKERHUB_USER}/${APP_NAME}:latest"
                        sh "docker push ${DOCKERHUB_USER}/${APP_NAME}:latest"
                        sh "docker logout"
                    }
                    echo "Image pushed successfully to Docker Hub."
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    echo '3. Updating Kubernetes manifest and applying...'
                    
                    // CRITICAL FIX: The sed command for in-place replacement requires different syntax 
                    // on different Linux/BSD systems. This command is more robust.
                    
                    // Substitute the old tag with the new build number tag in the YAML file
                    // Uses 's|OLD|NEW|g' format.
                    sh "sed -i 's|${OLD_IMAGE_URL}|${IMAGE_TAG}|g' ${K8S_MANIFEST}"

                    // Apply the changes to the local Kubernetes cluster
                    sh "kubectl apply -f ${K8S_MANIFEST}"
                    
                    echo "Deployment to Kubernetes complete. Check http://localhost:30080"
                }
            }
        }
    }
}