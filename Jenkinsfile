pipeline {
    agent any

    environment {
        AWS_REGION      = 'us-east-1'
        IMAGE_NAME      = 'config-service'
        ECR_REGISTRY    = 'public.ecr.aws/z1z0w2y6'
        DOCKER_BUILD_NUMBER = "${BUILD_NUMBER}"
        EKS_CLUSTER_NAME = 'main-cluster'
        NAMESPACE = 'fintech'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                script {
                    try {
                        bat 'mvn clean package -DskipTests'
                    } catch (Exception e) {
                        echo "Maven build failed: ${e.message}"
                        echo "Stack trace: ${e.stackTrace}"
                        error "Maven build stage failed"
                    }
                }
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                script {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-credentials',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        try {
                            // Configure Docker credential store
                            bat 'REG ADD HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\RunOnce /v DockerCredentialWincred /t REG_SZ /d "docker-credential-wincred.exe store"'
                            
                            // Docker login
                            bat """
                                @echo off
                                aws ecr-public get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}
                            """

                            // Build and tag image
                            bat """
                                docker build -t ${ECR_REGISTRY}/${IMAGE_NAME}:latest -t ${ECR_REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER} . --no-cache || (echo "Docker build failed" && exit /b 1)
                            """

                            // Push the tags
                            bat """
                                docker push ${ECR_REGISTRY}/${IMAGE_NAME}:latest || (echo "Docker push latest failed" && exit /b 1)
                                docker push ${ECR_REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER} || (echo "Docker push ${BUILD_NUMBER} failed" && exit /b 1)
                            """
                        } catch (Exception e) {
                            echo "Docker build/push failed: ${e.message}"
                            echo "Stack trace: ${e.stackTrace}"
                            error "Docker build/push stage failed"
                        }
                    }
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                script {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-credentials',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        try {
                            // Configure kubectl
                            bat """
                                aws eks update-kubeconfig --region ${AWS_REGION} --name ${EKS_CLUSTER_NAME} || (echo "Failed to update kubeconfig" && exit /b 1)
                            """

                            // Create namespace if doesn't exist
                            bat """
                                kubectl create namespace ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f - || (echo "Failed to create/update namespace" && exit /b 1)
                            """

                            // Create ConfigMap for service configurations
                            bat """
                                kubectl create configmap service-configurations --from-file=src/main/resources/configurations/ -n ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f - || (echo "Failed to create/update ConfigMap" && exit /b 1)
                            """

                            // Apply K8s manifests
                            bat """
                                kubectl apply -f k8s/configmap.yaml -n ${NAMESPACE} || (echo "Failed to apply configmap" && exit /b 1)
                                kubectl apply -f k8s/deployment.yaml -n ${NAMESPACE} || (echo "Failed to apply deployment" && exit /b 1)
                                kubectl apply -f k8s/service.yaml -n ${NAMESPACE} || (echo "Failed to apply service" && exit /b 1)
                            """

                            // Check pod status
                            bat """
                                echo "Checking pod status:"
                                kubectl get pods -n ${NAMESPACE} -l app=config-service || (echo "Failed to get pod status" && exit /b 1)
                            """

                        } catch (Exception e) {
                            echo "Deployment failed: ${e.message}"
                            echo "Stack trace: ${e.stackTrace}"
                            error "Deployment stage failed"
                        }
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline succeeded! Config Server deployed successfully.'
        }
        failure {
            echo 'Pipeline failed! Check the logs for details.'
        }
        always {
            bat """
                docker rmi ${ECR_REGISTRY}/${IMAGE_NAME}:latest ${ECR_REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER} || exit /b 0
            """
            cleanWs()
        }
    }
}
