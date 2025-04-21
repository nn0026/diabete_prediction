# Diabetes Prediction Project - End-to-End MLOps Pipeline

## Table of Contents
* [Project Overview](#project-overview)
  * [Introduction](#introduction)
  * [Key Features](#key-features)
  * [Technology Stack](#technology-stack)
* [System Architecture](#system-architecture)
  * [MLOps Pipeline](#mlops-pipeline)
  * [Kubernetes Architecture](#kubernetes-architecture)
* [Repository Structure](#repository-structure)
* [Getting Started](#getting-started)
  * [Prerequisites](#prerequisites)
  * [Environment Setup](#environment-setup)
  * [Installation Guide](#installation-guide)
* [Project Implementation](#project-implementation)
  * [1. Infrastructure Setup](#1-infrastructure-setup)
    * [1.1. GCP Project Configuration](#11-gcp-project-configuration)
    * [1.2. GKE Cluster Deployment with Terraform](#12-gke-cluster-deployment-with-terraform)
    * [1.3. Jenkins Deployment with Ansible](#13-jenkins-deployment-with-ansible)
  * [2. Application Deployment](#2-application-deployment)
    * [2.1. Nginx Ingress Controller](#21-nginx-ingress-controller)
    * [2.2. Prediction API Deployment](#22-prediction-api-deployment)
  * [3. Monitoring & Observability](#3-monitoring--observability)
    * [3.1. Prometheus & Grafana Setup](#31-prometheus--grafana-setup)
    * [3.2. Custom Metrics Dashboard](#32-custom-metrics-dashboard)
    * [3.3. Alert Configuration](#33-alert-configuration)
  * [4. Distributed Tracing](#4-distributed-tracing)
    * [4.1. Jaeger Implementation](#41-jaeger-implementation)
  * [5. CI/CD Pipeline](#5-cicd-pipeline)
    * [5.1. Jenkins Configuration](#51-jenkins-configuration)
    * [5.2. GitHub Integration](#52-github-integration)
    * [5.3. Automated Deployment](#53-automated-deployment)
* [Usage Guide](#usage-guide)
  * [API Documentation](#api-documentation)
  * [Model Training & Evaluation](#model-training--evaluation)
  * [Monitoring Dashboard](#monitoring-dashboard)
* [Development Tools](#development-tools)
  * [MLflow Deployment](#mlflow-deployment)
  * [Data Version Control](#data-version-control)
  * [Pre-commit Hooks](#pre-commit-hooks)
* [Future Improvements](#future-improvements)
* [Additional Resources](#additional-resources)

## Project Overview

### Introduction

This project implements an end-to-end MLOps pipeline for diabetes prediction using machine learning. The goal is to create a scalable, maintainable, and production-ready system that can predict diabetes based on various health metrics. This repository showcases best practices in MLOps including experiment tracking, CI/CD pipelines, containerization, Kubernetes orchestration, and monitoring.

The system demonstrates how to build and deploy an ML model for diabetes prediction as a production-ready service on Google Cloud Platform (GCP) with full monitoring capabilities and automated deployment workflow.

![Project Pipeline](assets/project_pipeline.png)

### Key Features

* End-to-end MLOps pipeline for diabetes prediction
* Containerized deployment with Kubernetes orchestration
* CI/CD automation with Jenkins
* Infrastructure as Code using Terraform and Ansible
* Comprehensive monitoring with Prometheus, Grafana and distributed tracing with Jaeger
* Experiment tracking and model registry with MLflow
* Data versioning with DVC
* API development with FastAPI

### Technology Stack

* **Source Control**: Git/GitHub
* **CI/CD**: Jenkins
* **Experiment Tracking & Model Registry**: MLflow
* **API Framework**: FastAPI
* **Containerization**: Docker
* **Container Orchestration**: Kubernetes (GKE)
* **Package Manager**: Helm
* **Monitoring**: Prometheus & Grafana
* **Distributed Tracing**: Jaeger
* **Infrastructure as Code**: Ansible & Terraform
* **Ingress Controller**: Nginx Ingress
* **Cloud Platform**: Google Cloud Platform (GCP)
* **Data Version Control**: DVC

## System Architecture

### MLOps Pipeline

The MLOps pipeline implements the following workflow:

1. **Data Versioning** - Using DVC to track data changes
2. **Experiment Tracking** - Using MLflow to track experiments and models
3. **Model Training** - Jupyter notebooks for EDA and model training
4. **Model Registry** - MLflow for versioning and registering models
5. **Continuous Integration** - GitHub and Jenkins for CI/CD
6. **Containerization** - Docker for packaging the application
7. **Orchestration** - Kubernetes for container orchestration
8. **Infrastructure as Code** - Terraform and Ansible for provisioning
9. **Monitoring** - Prometheus and Grafana for observability
10. **Tracing** - Jaeger for distributed tracing

### Kubernetes Architecture

The application is deployed on a Google Kubernetes Engine (GKE) cluster with the following components:

* NGINX Ingress Controller for routing external traffic
* FastAPI application pods with the prediction model
* Prometheus and Grafana for monitoring and visualization
* Jaeger for distributed tracing
* Jenkins for CI/CD pipeline execution

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
<NGINX_INGRESS_IP>  tiennkapp.org.m1
<NGINX_INGRESS_IP>  prometheus.tiennk.com
<NGINX_INGRESS_IP>  grafana.tiennk.com
<NGINX_INGRESS_IP>  alertmanager.tiennk.com
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
1. Go to Grafana (http://grafana.tiennk.com)
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

Access the API documentation at http://tiennkapp.org.m1/docs. You can test the diabetes prediction API directly from the Swagger UI.

### Model Training & Evaluation

The model training process is documented in the `notebooks/EDA_and_experiments.ipynb` Jupyter notebook. It includes:
- Exploratory data analysis
- Feature engineering
- Model selection
- Hyperparameter tuning
- Model evaluation

### Monitoring Dashboard

Access the monitoring dashboards:
1. Grafana (http://grafana.tiennk.com): For system metrics and custom application metrics
2. Prometheus (http://prometheus.tiennk.com): For raw metrics and queries
3. Alertmanager (http://alertmanager.tiennk.com): For alert management

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

- [ ] Implement A/B testing for model deployment
- [ ] Add automated retraining pipeline
- [ ] Enhance security configurations
- [ ] Implement model explainability features
- [ ] Add data drift monitoring
- [x] ~~Building observability system on kubernetes (Prometheus and grafana)~~

## Additional Resources

- [Google Cloud Documentation](https://cloud.google.com/docs)
- [Kubernetes Documentation](https://kubernetes.io/docs/home/)
- [Terraform Documentation](https://developer.hashicorp.com/terraform/docs)
- [MLflow Documentation](https://www.mlflow.org/docs/latest/index.html)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Prometheus Documentation](https://prometheus.io/docs/introduction/overview/)
- [Grafana Documentation](https://grafana.com/docs/)
- [DVC Documentation](https://dvc.org/doc)
