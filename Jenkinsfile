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
            steps {
                script {
                    echo 'Running tests with Docker build...'
                    sh '''
                        docker build -t test-image -f Dockerfile .
                        docker run --rm test-image bash -c "
                            cd /app &&
                            pip install pytest pytest-cov joblib numpy &&
                            ls -la /app/tests &&
                            python -m pytest /app/tests/test_model_correctness.py -v
                        "
                        docker rmi test-image 
                    '''
                }
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
            agent {
                kubernetes {
                    containerTemplate {
                        name 'helm'
                        image 'fullstackdatascience/jenkins-k8s:lts'
                        imagePullPolicy 'Always'
                    }
                }
            }
            steps {
                script {
                    container('helm') {
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
}
