# Terraform block to configure required providers and backend state storage

terraform {
  required_providers {
    # Define the Google Cloud provider requirements
    google = {
      source  = "hashicorp/google"
      # Pin to a specific minor version range for stability
      # Check latest compatible version: https://registry.terraform.io/providers/hashicorp/google/latest
      version = "~> 5.10" # Example: Use versions 5.10.x
    }
    # Add other providers here if needed (e.g., helm, kubernetes)
  }

  # --- Backend Configuration (Recommended for Collaboration/CI/CD) ---
  # Uncomment and configure to store state remotely in Google Cloud Storage
  # Ensure the GCS bucket exists before running 'terraform init'
  # backend "gcs" {
  #   bucket  = "<YOUR_GCS_BUCKET_NAME_FOR_TFSTATE>" # REPLACE THIS
  #   prefix  = "mlops/diabetes-prediction/gke"      # Path within the bucket
  # }
  # ------------------------------------------------------------------
}

# Configure the Google Cloud provider
provider "google" {
  # Project and region are sourced from variables defined in variables.tf
  # Credentials are automatically sourced from 'gcloud auth application-default login'
  # or GOOGLE_APPLICATION_CREDENTIALS environment variable.
  # Explicitly set credentials using the service account key file
  credentials = "/home/hn/diabete_prediction/local/ansible/secrets/mlecourse-455815-5abd9a647f00.json"
  project     = var.project_id
  region      = var.region
  # zone = var.zone # Zone can also be set here if needed globally
}

# Optional: Configure Helm provider if managing Helm releases via Terraform
# provider "helm" {
#   kubernetes {
#     config_path = "~/.kube/config" # Or appropriate path
#   }
# }

# Optional: Configure Kubernetes provider if managing K8s resources directly via Terraform
# provider "kubernetes" {
#   config_path = "~/.kube/config" # Or appropriate path
# }