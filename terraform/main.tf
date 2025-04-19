# Main Terraform configuration for GKE Cluster

# Define the GKE cluster
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.zone # Deploying to a specific zone

  # Remove the default node pool as we will create a custom one
  remove_default_node_pool = true
  initial_node_count       = 1 # Required when removing default pool

  network    = "default" # Using the default VPC network
  subnetwork = "default" # Using the default subnetwork in the region

  # Enable recommended addons
  addons_config {
    http_load_balancing { # Needed for GKE Ingress (if used)
      disabled = false
    }
    horizontal_pod_autoscaling { # Enable HPA controller
      disabled = false
    }
    # network_policy_config { # Enable Network Policy enforcement if needed
    #   disabled = false
    # }
  }

  # Enable Workload Identity (Recommended for secure GCP API access from pods)
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog" # Corrected workload_pool
  }

  # Use a regular release channel for a balance of features and stability
  release_channel {
    channel = "REGULAR"
  }

  # Optional: Configure logging and monitoring integration with Google Cloud Operations
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  # Optional: Enhance security with Shielded Nodes
  # enable_shielded_nodes = true

  # Optional: Restrict access to the cluster master endpoint
  # master_authorized_networks_config {
  #   cidr_blocks {
  #     cidr_block   = "YOUR_IP_RANGE/32" # Replace with your IP range
  #     display_name = "My Office IP"
  #   }
  # }

  # Optional: Configure cluster as private for enhanced network isolation
  # private_cluster_config {
  #   enable_private_nodes    = true
  #   enable_private_endpoint = false # Set to true to make master endpoint private too
  #   master_ipv4_cidr_block  = "172.16.0.0/28" # Must not overlap with VPC subnets
  # }

  # Allow Terraform to destroy the cluster even if it has running workloads
  deletion_protection = false # Set to true for production clusters
}

# Define the primary node pool for the cluster
resource "google_container_node_pool" "primary_nodes" {
  name       = "${google_container_cluster.primary.name}-primary-pool"
  location   = var.zone
  cluster    = google_container_cluster.primary.name
  # initial_node_count = var.initial_node_count # For non-autoscaling pools
  # node_count can be omitted if autoscaling is enabled

  # Enable node auto-management features
  management {
    auto_repair  = true # Automatically repair unhealthy nodes
    auto_upgrade = true # Automatically upgrade node K8s versions
  }

  # Configure the nodes within the pool
  node_config {
    machine_type = var.machine_type
    disk_size_gb = 50      # Adjust disk size as needed
    disk_type    = "pd-standard" # Or "pd-ssd" for faster disks

    # Use default GCE service account - prefer Workload Identity for pod access to GCP APIs
    # service_account = "default"
    # oauth_scopes = [
    #   "https://www.googleapis.com/auth/cloud-platform"
    # ]

    # Add labels and taints if needed
    # labels = {
    #   app = "general-workloads"
    # }
    # taints = [
    #   {
    #     key    = "workload_type"
    #     value  = "general"
    #     effect = "NO_SCHEDULE"
    #   }
    # ]

    # Enable Shielded Nodes configuration matching the cluster setting
    # shielded_instance_config {
    #   enable_secure_boot          = true
    #   enable_integrity_monitoring = true
    # }
  }

  # Enable autoscaling for the node pool
  autoscaling {
    min_node_count = var.min_node_count # Use variable
    max_node_count = var.max_node_count # Use variable
  }

  # Ensure node pool is deleted when the cluster is deleted
  depends_on = [
    google_container_cluster.primary
  ]
}