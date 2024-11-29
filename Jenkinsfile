pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS = credentials('docker credentials')  // Docker Hub credentials
        AWS_REGION = 'us-east-1'  // AWS region
        CLUSTER_NAME = 'my-eks-cluster'  // EKS cluster name
        AWS_ACCOUNT_ID = '575108934554'  // Your AWS account ID
        ECR_REPO = 'my-repository'  // Your ECR repository name
    }

    stages {
        stage('Configure Kubeconfig') {
            steps {
                script {
                    // Ensure AWS CLI is installed and AWS credentials are configured
                    sh "aws eks --region ${AWS_REGION} update-kubeconfig --name ${CLUSTER_NAME}"
                }
            }
        }

        stage('Build Docker Images') {
            steps {
                script {
                    echo "Building Docker images..."
                    sh '''
                        cd Docker/3tier-nodejs/
                        docker-compose build
                    '''
                }
            }
        }

        stage('Push to AWS ECR') {
            steps {
                script {
                    echo "Authenticating Docker to AWS ECR..."
                    sh '''
                        aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                    '''

                    echo "Tagging Docker images for ECR..."
                    sh '''
                        docker tag 3tier-nodejs-backend:latest ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:3tier-nodejs-backend
                        docker tag 3tier-nodejs-frontend:latest ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:3tier-nodejs-frontend
                        docker tag mongo:latest ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:mongo
                    '''

                    echo "Pushing Docker images to ECR..."
                    sh '''
                        docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:3tier-nodejs-backend
                        docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:3tier-nodejs-frontend
                        docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:mongo
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    echo "Deploying to EKS cluster..."
                    sh '''
                        kubectl apply -f k8s/frontend.yml
                        kubectl apply -f k8s/backend.yml
                        kubectl apply -f k8s/mongodb.yml
                        kubectl apply -f k8s/frontend-ingress.yml
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "Deployment was successful!"
        }
        failure {
            echo "Deployment failed!"
        }
    }
}
