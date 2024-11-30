pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        CLUSTER_NAME = 'my-eks-cluster'
        AWS_ACCOUNT_ID = '575108934554'
        ECR_REPO = 'my-repository'
        AWS_CREDENTIALS_ID = 'AWS'
        DOCKER_WORKDIR = 'Docker/3tier-nodejs'
        KUBECONFIG = credentials('kubeconfig')
    }

    stages {
        stage('Configure AWS and Kubeconfig') {
            steps {
                script {
                    echo "Configuring AWS credentials and kubeconfig for EKS cluster..."
                    withAWS(region: AWS_REGION, credentials: AWS_CREDENTIALS_ID) {
                        sh "aws eks --region ${AWS_REGION} update-kubeconfig --name ${CLUSTER_NAME} "
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
                        docker compose up -d
                    '''
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
                        docker tag 3tier-nodejs-backend:latest ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:backend-latest
                        docker tag 3tier-nodejs-frontend:latest ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:frontend-latest
                        docker tag mongo:latest ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:mongo-latest
                    '''

                    echo "Pushing Docker images to ECR..."
                    sh '''
                        docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:backend-latest
                        docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:frontend-latest
                        docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:mongo-latest
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    echo "Deploying Kubernetes resources to EKS..."
                    sh '''
                        kubectl apply -f K8S/frontend.yml 
                        kubectl apply -f K8S/backend.yml 
                        kubectl apply -f K8S/mongodb.yml 
                        kubectl apply -f K8S/frontend-ingress.yml 
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
