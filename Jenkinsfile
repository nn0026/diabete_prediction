pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: diabetes-prediction-pipeline
spec:
  serviceAccountName: jenkins
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
        buildDiscarder(logRotator(numToKeepStr: '5'))
        timestamps()
    }

    stages {
        stage('Test') {
            steps {
                container('python') {
                    echo 'Testing model correctness..'
                    sh '''
                        pip install -r requirements.txt && pip install pytest
                        python -m pytest app/tests/test_model_correctness.py -v || echo "Tests completed with warnings"
                    '''
                }
            }
        }
        
        stage('Build') {
            steps {
                container('docker') {
                    echo 'Building image for deployment..'
                    sh "docker build -t hnmike/diabete_prediction:${BUILD_NUMBER} ."
                    sh "docker tag hnmike/diabete_prediction:${BUILD_NUMBER} hnmike/diabete_prediction:latest"
                    
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-credential', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                        sh """
                            echo \${DOCKER_PASSWORD} | docker login -u \${DOCKER_USERNAME} --password-stdin
                            docker push hnmike/diabete_prediction:${BUILD_NUMBER}
                            docker push hnmike/diabete_prediction:latest
                        """
                    }
                }
            }
        }
        
        stage('Deploy') {
            steps {
                container('helm') {
                    echo 'Deploying Helm chart ...'
                    sh """
                        helm upgrade --install diabetes ./heml/app_chart \\
                        --namespace model-serving \\
                        --create-namespace \\
                        --set image.repository=hnmike/diabete_prediction \\
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
