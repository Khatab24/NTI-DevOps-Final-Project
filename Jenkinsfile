pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        CLUSTER_NAME = 'my-eks-cluster'
        AWS_ACCOUNT_ID = '575108934554'
        ECR_REPO_BACKEND = '3tier-nodejs-backend'
        ECR_REPO_FRONTEND = '3tier-nodejs-frontend'
        ECR_REPO_MONGO = 'mongo'
        AWS_CREDENTIALS_ID = 'AWS'
        DOCKER_WORKDIR = 'Docker/3tier-nodejs'
    }

    stages {
        stage('Configure AWS and Kubeconfig') {
            steps {
                script {
                    echo "Configuring AWS credentials and kubeconfig for EKS cluster..."
                    withAWS(region: AWS_REGION, credentials: AWS_CREDENTIALS_ID) {
                        sh "aws eks --region ${AWS_REGION} update-kubeconfig --name ${CLUSTER_NAME}"
                    }
                }
            }
        }

        stage('Build Docker Images') {
            steps {
                script {
                    echo "Building Docker images..."
                    sh '''
                        cd ${DOCKER_WORKDIR}
                        docker compose up -d                    '''
                }
            }
        }

        stage('Push to AWS ECR') {
            steps {
                script {
                    echo "Authenticating Docker to AWS ECR..."
                    sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

                    echo "Tagging Docker images for ECR..."
                    sh '''
                        docker tag backend:latest ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_BACKEND}
                        docker tag frontend:latest ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_FRONTEND}
                        docker tag mongo:latest ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_MONGO}
                    '''

                    echo "Pushing Docker images to ECR..."
                    sh '''
                        docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_BACKEND}
                        docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_FRONTEND}
                        docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_MONGO}
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    echo "Deploying Kubernetes resources to EKS..."
                    sh '''
                        kubectl apply -f k8s/frontend.yml
                        kubectl apply -f k8s/backend.yml
                        kubectl apply -f k8s/mongo.yml
                        kubectl apply -f k8s/frontend-ingress.yml
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline executed successfully. Application deployed!"
        }
        failure {
            echo "Pipeline execution failed. Please check the logs for errors."
        }
    }
}
