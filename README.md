# Diabetes Prediction Project 
## Repository Structure

```
diabete_prediction/
├── app/                               # Main application code
│   ├── client.py                      # Client for API testing
│   ├── main.py                        # FastAPI application 
│   ├── tests/                         # Test cases for the application
│   └── utils/                         # Utility functions
├── assets/                            # Images and documentation resources
├── data/                              # Data files
│   └── raw_data/                      # Raw dataset files
├── examples/                          # Example usage scripts
├── heml/                              # Helm charts
│   ├── app_chart/                     # Helm chart for the application
│   ├── ingress-nginx/                 # Nginx ingress controller chart
│   ├── jaeger/                        # Jaeger tracing chart
│   └── prometheus-grafana/            # Prometheus & Grafana monitoring charts
├── local/                             # Local development setup
│   ├── ansible/                       # Ansible scripts for provisioning
│   └── custom_jenkins/                # Custom Jenkins configuration
├── models/                            # Trained ML models
│   ├── model.pkl                      # Serialized model file
│   └── scaler.gz                      # Feature scaler
├── mlartifacts/                       # MLflow tracking artifacts
├── mlruns/                            # MLflow runs and metadata
├── monitor/                           # Monitoring configurations
│   ├── grafana/                       # Grafana dashboards
│   └── prometheus/                    # Prometheus configurations
├── notebooks/                         # Jupyter notebooks
│   └── EDA_and_experiments.ipynb      # EDA and model training
├── terraform/                         # IaC for GCP resources
│   ├── main.tf                        # Main Terraform configuration
│   ├── providers.tf                   # Provider configurations
│   └── variables.tf                   # Variables for Terraform
├── virtualization/                    # Containerization configs
│   └── mlflow/                        # MLflow server setup
├── Dockerfile                         # Docker configuration
├── Jenkinsfile                        # Jenkins pipeline definition
├── data.dvc                           # DVC file for data versioning
├── requirements.txt                   # Production dependencies
└── requirements_dev.txt               # Development dependencies
```

## Getting Started

### Prerequisites

#### Google Cloud Platform Account

1. Register for a [Google Cloud Platform](https://console.cloud.google.com/) account
2. Create a new project
   - Navigate to the GCP console
   - Click on "New Project"
   - Enter a project name (e.g., "diabetes-prediction")
   - Click "Create"

3. Set up billing for your project
   - Create a billing account if you don't have one
   - Link the billing account to your project
   - New users can sign up for free trial credits

4. Enable required APIs:
   - Navigate to [Compute Engine API](https://console.cloud.google.com/marketplace/product/google/compute.googleapis.com)
   - Click "Enable"
   - Navigate to [Kubernetes Engine API](https://console.cloud.google.com/marketplace/product/google/container.googleapis.com)
   - Click "Enable"

![Create New Project](assets/CreateNewprojectGCP2.png)
![Enable Compute Engine API](assets/EnableComputeEngineAPI.png)
![Enable Kubernetes API](assets/enableK8s.png)

### Environment Setup

#### Install the gcloud CLI

Follow the instructions to [install gcloud CLI](https://cloud.google.com/sdk/docs/install#deb) for your operating system. After installation:

```bash
gcloud init
```

Follow the prompts to:
- Select your Google account
- Choose your GCP project
- Select your preferred region and zone

#### Required Tools

Install the following tools:

- [Docker](https://docs.docker.com/desktop/install/ubuntu/)
- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
- [Helm](https://helm.sh/docs/intro/install/)
- [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli#install-terraform)
- [kubectx + kubens](https://github.com/ahmetb/kubectx#manual-installation-macos-and-linux) (Optional)

#### Development Dependencies

Install the required Python packages:

```bash
pip install -r requirements_dev.txt
```

## Project Implementation

### 1. Infrastructure Setup

#### 1.1. GCP Project Configuration

Create a project in Google Cloud Platform as described in the Prerequisites section.

#### 1.2. GKE Cluster Deployment with Terraform

Navigate to the terraform directory and initialize:

```bash
cd ./terraform
terraform init
```

Authenticate with GCP:

```bash
gcloud auth application-default login
```

Create and apply the execution plan:

```bash
terraform plan
terraform apply
```

After successful creation, get the cluster credentials:

```bash
gcloud container clusters get-credentials <your_gke_name> --zone us-central1-c --project <your_project_id>
```

Switch to your GKE cluster:

```bash
kubectx <YOUR_GKE_CLUSTER>
```

#### 1.3. Jenkins Deployment with Ansible

Create a service account with Compute Admin permissions and download the JSON key file to `/local/ansible/secrets/`.

Create the Jenkins VM instance:

```bash
cd ./local/ansible/deploy_jenkins
ansible-playbook create_compute_instance.yaml
```

Note the external IP from the [VM instances page](https://console.cloud.google.com/compute/instances), update the inventory file, then run:

```bash
ansible-playbook -i ../inventory deploy_jenkins.yml
```

### 2. Application Deployment

#### 2.1. Nginx Ingress Controller

Install the NGINX ingress controller:

```bash
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace
```

Retrieve the Nginx Ingress IP address:

```bash
kubectl get service ingress-nginx-controller --namespace ingress-nginx
```

Configure your domain by adding entries to your `/etc/hosts` file:

```
<NGINX_INGRESS_IP>  hn.org.m1
<NGINX_INGRESS_IP>  prometheus.hn.com
<NGINX_INGRESS_IP>  grafana.hn.com
<NGINX_INGRESS_IP>  alertmanager.hn.com
```

#### 2.2. Prediction API Deployment

The deployment of the FastAPI application is handled by the CI/CD pipeline. For local development, you can run:

```bash
cd ./app
uvicorn main:app --reload
```

Access the API documentation at http://localhost:8000/docs or through the configured domain when deployed.

![Test API](assets/testAPI.png)

### 3. Monitoring & Observability

#### 3.1. Prometheus & Grafana Setup

Deploy Prometheus and Grafana to monitor your application:

```bash
cd ./prometheus-grafana
helm upgrade --install prometheus-grafana-stack -f values-prometheus.yaml \
  kube-prometheus-stack --namespace monitoring --create-namespace
```

Access the services:
- Prometheus: http://prometheus.tiennk.com
- Grafana: http://grafana.tiennk.com
- Alertmanager: http://alertmanager.tiennk.com

![Prometheus UI Example](assets/prometheusUIexample.png)

#### 3.2. Custom Metrics Dashboard

The application uses OpenTelemetry to expose custom metrics for API requests and response times. These metrics are scraped by Prometheus and visualized in Grafana.

To create a custom metrics dashboard:
1. Go to Grafana (http://grafana.hn.com)
2. Create a new dashboard
3. Add visualizations for the custom metrics:
   - `diabetespred_request_counter`: Number of API requests
   - `diabetespred_response_histogram_seconds`: Response time histogram

![OpenTelemetry Dashboard](assets/OpenteleDashboardStep5.png)

#### 3.3. Alert Configuration

Configure Prometheus alerts to be sent to Discord:

1. Create a webhook in your Discord server
   - Edit a channel's settings
   - Go to Integrations > Webhooks
   - Create a new webhook and copy the URL
   
2. Update the webhook URL in the `values-prometheus.yaml` file

![Discord Webhook](assets/Botdiscordconfig.png)

### 4. Distributed Tracing

#### 4.1. Jaeger Implementation

Deploy Jaeger for distributed tracing:

```bash
helm upgrade --install jaeger jaeger/jaeger \
  --namespace tracing --create-namespace \
  --set ingress.enabled=true \
  --set ingress.hosts[0]=jaeger.tiennk.com
```

Update your `/etc/hosts` file to include Jaeger:

```
<NGINX_INGRESS_IP>  jaeger.tiennk.com
```

The FastAPI application is instrumented with OpenTelemetry to send traces to Jaeger.

### 5. CI/CD Pipeline

#### 5.1. Jenkins Configuration

SSH to your Jenkins VM and verify that the Jenkins container is running:

```bash
ssh -i ~/.ssh/id_rsa username@jenkins_externalIP
sudo docker ps
```

Get the initial Jenkins password:

```bash
sudo docker exec -ti jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

Access Jenkins at http://jenkins_externalIP:8081/ and complete the setup wizard.

Install the necessary plugins:
- Docker Pipeline
- Kubernetes
- Google Cloud SDK

![Jenkins Plugins](assets/jenkinsInstallationplugin.gif)

#### 5.2. GitHub Integration

Create GitHub access tokens:
1. Go to GitHub Settings > Developer Settings > Personal access tokens
2. Generate a new token with appropriate permissions

Add the token as a credential in Jenkins.

![Generate GitHub Token](assets/generateGithubToken-crop.gif)

Set up a webhook in your GitHub repository to trigger the pipeline on code changes:
- URL: http://jenkins_externalIP:8081/github-webhook/
- Content type: application/json
- Events: Push, Pull requests

![Create Webhook](assets/createWebhook-crop.gif)

#### 5.3. Automated Deployment

Create a new Jenkins pipeline:
1. Go to Jenkins Dashboard > New Item
2. Select "Multibranch Pipeline"
3. Configure the GitHub source with your repository
4. Save and watch the pipeline run

![Jenkins Pipeline Success](assets/sucessPipeline.png)

The Jenkinsfile in the repository defines the CI/CD pipeline, which includes:
- Building the Docker image
- Running tests
- Pushing the image to DockerHub
- Deploying to Kubernetes using Helm

## Usage Guide

### API Documentation

Access the API documentation at http://hn.org.m1/docs. You can test the diabetes prediction API directly from the Swagger UI.

### Model Training & Evaluation

The model training process is documented in the `notebooks/EDA_and_experiments.ipynb` Jupyter notebook. It includes:
- Exploratory data analysis
- Feature engineering
- Model selection
- Hyperparameter tuning
- Model evaluation

### Monitoring Dashboard

Access the monitoring dashboards:
1. Grafana (http://grafana.hn.com): For system metrics and custom application metrics
2. Prometheus (http://prometheus.hn.com): For raw metrics and queries
3. Alertmanager (http://alertmanager.hn.com): For alert management

Example Prometheus query to check the average request rate:

```
rate(diabetespred_response_histogram_seconds_count[5m])
```

![Prometheus Query Example](assets/prometheusQueryExample.png)

## Development Tools

### MLflow Deployment

Deploy MLflow for experiment tracking and model registry:

```bash
pip install mlflow==2.1.1
docker compose -f ./virtualization/mlflow/mlflow-docker-compose.yml up -d
```

Access MLflow at http://localhost:5000/

![MLflow](assets/Mlflow.png)

### Data Version Control

Install and use DVC for data versioning:

```bash
pip install dvc==3.30.1
```

### Pre-commit Hooks

Set up pre-commit hooks to ensure code quality:

```bash
pip install pre-commit
pre-commit install
pre-commit run --all-files
```

YAML linting:

```bash
pip install yamllint
yamllint <yaml_file_name>.yaml
```

## Future Improvements
