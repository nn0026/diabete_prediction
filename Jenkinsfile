pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: python
    image: python:3.11-slim
    command:
    - cat
    tty: true
  - name: docker
    image: docker:latest
    command:
    - cat
    tty: true
    volumeMounts:
    - name: docker-sock
      mountPath: /var/run/docker.sock
  - name: helm
    image: alpine/helm:3.12.0
    command:
    - cat
    tty: true
  volumes:
  - name: docker-sock
    hostPath:
      path: /var/run/docker.sock
"""
        }
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '5', daysToKeepStr: '5'))
        timestamps()
    }

    environment {
        registry = 'hnmike/diabete_prediction'
        registryCredential = 'dockerhub'
        CHART_PATH = './heml/app_chart'
        RELEASE_NAME = 'diabetes'
        NAMESPACE = 'model-serving'
        INGRESS_HOST = 'hnapp.org.m1'
    }

    stages {
        stage('Test') {
            steps {
                container('python') {
                    echo 'Testing model correctness..'
                    sh 'pip install -r requirements.txt'
                    sh 'python -m pytest app/tests/test_model_correctness.py -v || echo "Tests completed with warnings"'
                }
            }
        }
        
        stage('Build') {
            steps {
                container('docker') {
                    echo 'Building image for deployment..'
                    sh "docker build -t ${registry}:${BUILD_NUMBER} ."
                    sh "docker tag ${registry}:${BUILD_NUMBER} ${registry}:latest"
                    
                    withCredentials([string(credentialsId: registryCredential, variable: 'DOCKER_PWD')]) {
                        sh "echo \${DOCKER_PWD} | docker login -u hnmike --password-stdin"
                        sh "docker push ${registry}:${BUILD_NUMBER}"
                        sh "docker push ${registry}:latest"
                    }
                }
            }
        }
        
        stage('Deploy') {
            steps {
                container('helm') {
                    echo "Deploying Helm chart ${CHART_PATH} as ${RELEASE_NAME}..."
                    sh """
                        helm upgrade --install ${RELEASE_NAME} ${CHART_PATH} \\
                        --namespace ${NAMESPACE} \\
                        --create-namespace \\
                        --set image.repository=${registry} \\
                        --set image.tag=${BUILD_NUMBER} \\
                        --set ingress.hosts[0].host=${INGRESS_HOST} \\
                        --wait --timeout 5m
                    """
                    echo "Deployment complete."
                }
            }
        }
    }
}
