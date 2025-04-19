# Input variables for the Terraform GKE configuration

variable "project_id" {
  description = "The GCP project ID where resources will be created."
  type        = string
  # No default - will require input or TF_VAR_project_id=mlecourse-455815
}

variable "region" {
  description = "The primary GCP region for deploying resources (e.g., 'asia-southeast1')."
  type        = string
  default     = "asia-southeast1" # Updated default
}

variable "zone" {
  description = "The GCP zone for the GKE cluster master and default node pool (e.g., 'asia-southeast1-a'). Should be within the specified region."
  type        = string
  default     = "asia-southeast1-a" # Updated default
}

variable "cluster_name" {
  description = "The name for the GKE cluster."
  type        = string
  default     = "diabetes-mlops-cluster"
}

variable "machine_type" {
  description = "The machine type for the GKE nodes (e.g., 'e2-medium', 'n1-standard-2')."
  type        = string
  default     = "e2-medium" # Keeping default, can be overridden
}

variable "initial_node_count" {
  description = "Initial number of nodes for the primary node pool (used if autoscaling is disabled)."
  type        = number
  default     = 1
}

variable "min_node_count" {
  description = "Minimum number of nodes for the node pool autoscaler."
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Maximum number of nodes for the node pool autoscaler."
  type        = number
  default     = 3
}