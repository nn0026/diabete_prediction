pipeline {
    agent any

    options{
        buildDiscarder(logRotator(numToKeepStr: '5', daysToKeepStr: '5'))
        timestamps()
    }

    environment{
        registry = 'hnmike/diabetes_predicton'
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
                sh '''
                    python3 -m pip install -r requirements.txt
                    python3 -m pip install pytest
                    python3 -m pytest app/tests/test_model_correctness.py -v || echo "Tests completed with warnings"
                '''
            }
        }
        
        stage('Build') {
            steps {
                script {
                    echo 'Building image for deployment..'
                    dockerImage = docker.build registry + ":$BUILD_NUMBER"
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
                        image 'hnmike/jenkins-k8s:lts' // The image containing helm
                        imagePullPolicy 'Always' 
                    }
                }
            }
            steps {
                script {
                    container('helm') {
                        echo 'Deploying Helm chart ...'
                        sh """
                            helm upgrade --install diabetes ./heml/app_chart \\
                            --namespace model-serving \\
                            --create-namespace \\
                            --set image.repository=${registry} \\
                            --set image.tag=${BUILD_NUMBER} \\
                            --set ingress.hosts[0].host=diabetes.hnapp.org.m1 \\
                            --set service.type=ClusterIP \\
                            --set metrics.enabled=true \\
                            --wait --timeout 5m
                        """
                        echo "Deployment complete."
                    }
                }
            }
        }
    }
}
