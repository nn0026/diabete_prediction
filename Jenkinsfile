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
                    image 'python:3.11' 
                }
            }
            steps {
                echo 'Testing model correctness..'
                sh 'pip install -r requirements.txt && pytest'
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
                        name 'helm' // Name of the container to be used for helm upgrade
                        image 'fullstackdatascience/jenkins-k8s:lts' // The image containing helm
                        imagePullPolicy 'Always' // Always pull image in case of using the same tag
                    }
                }
            }
            steps {
                script {
                    container('helm') {
                        sh """
                            helm upgrade --install ${RELEASE_NAME} ${CHART_PATH} \\
                            --namespace ${NAMESPACE} \\
                            --create-namespace \\
                            --set image.repository=${registry} \\
                            --set image.tag=${env.BUILD_NUMBER} \\
                            --set ingress.enabled=true \\
                            --set ingress.hosts[0].host=${INGRESS_HOST} \\
                            --set metrics.enabled=true \\
                            --set metrics.servicemonitor.enabled=true \\
                            --set service.metricsPort=8099 \\
                            --wait --timeout 5m
                        """
                    }
                }
            }
        }
    }
}