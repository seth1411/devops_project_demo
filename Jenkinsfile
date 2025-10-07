pipeline {
    agent any

    environment {
        // Your Docker Hub Username (must be all lowercase)
        DOCKERHUB_USER = '1411ayush' 
        
        // The ID you created in Manage Credentials
        DOCKER_CRED_ID = 'b9ce59ae-b9f5-4ada-b061-933157c5915d' 
        
        APP_NAME = 'hello-app'
        IMAGE_TAG = "${DOCKERHUB_USER}/${APP_NAME}:${env.BUILD_NUMBER}"
        K8S_MANIFEST = 'deployment.yaml'
        
        // Define the placeholder you need to replace in deployment.yaml
        PLACEHOLDER_IMAGE = "${DOCKERHUB_USER}/${APP_NAME}:latest" 
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
                    docker.build(IMAGE_TAG, "-f Dockerfile .")

                    // 2. Push to Docker Hub using stored credentials
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
                    
                    // --- CORRECTION HERE ---
                    // 1. Use sed to replace the placeholder 'image: ...:latest' with the actual IMAGE_TAG.
                    //    We use the BUILD_NUMBER tag instead of 'latest' to ensure deterministic deployments.
                    //
                    //    The '/bin/sh' container will run the 'sed' command. 
                    //    Note: The original deployment.yaml should initially use a standard image name/tag, 
                    //    e.g., image: 1411ayush/hello-app:latest (or a placeholder like V0.0.0)
                    
                    // This uses a multi-command shell script to correctly handle the substitution.
                    sh """
                        LATEST_IMAGE_URL="${PLACEHOLDER_IMAGE}"
                        NEW_IMAGE_URL="${IMAGE_TAG}"
                        
                        # Replace the latest tag with the new build number tag in the YAML file
                        # Uses 'gsed' on macOS/BSD and 'sed' on Linux
                        # We are replacing the entire 'image: ...' line to ensure clean application.
                        sed -i.bak "s|image: \${LATEST_IMAGE_URL}|image: \${NEW_IMAGE_URL}|" ${K8S_MANIFEST}
                    """

                    // 2. Apply the changes to the local Kubernetes cluster
                    sh "kubectl apply -f ${K8S_MANIFEST}"
                    
                    echo "Deployment to Kubernetes complete. Access on NodePort 30080."
                }
            }
        }
    }
}