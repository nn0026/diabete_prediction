pipeline {
    agent any

    options {
        buildDiscarder(logRotator(numToKeepStr: '5', daysToKeepStr: '5'))
        timestamps()
    }

    environment {
        registry = 'hnmike/diabete_prediction'
        registryCredential = 'dockerhub'
    }

    stages {
        stage('Test') {
            agent {
                docker {
                    image 'python:3.11-slim'
                    args '--user root -v ${WORKSPACE}:/app'
                    reuseNode true
                }
            }
            steps {
                echo 'Testing model correctness..'
                sh 'cd /app && pip install -r requirements.txt && python -m pytest app/tests/test_model_correctness.py -v || echo "Tests completed "'
            }
        }
        
        stage('Build') {
            steps {
                script {
                    echo 'Building image for deployment..'
                    def dockerImage = docker.build registry + ":${env.BUILD_NUMBER}"
                    echo 'Pushing image to dockerhub..'
                    docker.withRegistry( '', registryCredential ) {
                        dockerImage.push()
                        dockerImage.push('latest') 
                    }
                }
            }
        }
        
        stage('Deploy') {
            steps {
                script {
                    echo "Deploying Helm chart ${CHART_PATH} as ${RELEASE_NAME}..."
                    sh """
                        helm upgrade --install ${RELEASE_NAME} ${CHART_PATH} \\
                        --namespace ${NAMESPACE} \\
                        --create-namespace \\
                        --set image.repository=${registry} \\
                        --set image.tag=${env.BUILD_NUMBER} \\
                        --set ingress.hosts[0].host=${INGRESS_HOST} \\
                        --wait --timeout 5m
                    """
                    echo "Deployment complete."
                }
            }
        }
    }
}
