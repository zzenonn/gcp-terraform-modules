# GKE cluster
resource "google_container_cluster" "primary" {
  name     = "${data.google_project.project.name}-gke"
  location = var.region
  node_locations = data.google_compute_zones.available.names

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  enable_autopilot = var.enable_autopilot

  network    = var.vpc_id
  subnetwork = var.subnet_id

  ip_allocation_policy {
      cluster_ipv4_cidr_block = var.pod_ip_addr_range
      services_ipv4_cidr_block = var.services_ip_addr_range
  }
}

# Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  count      = var.enable_autopilot ? 0 : 1
  name       = "${google_container_cluster.primary.name}-node-pool"
  location   = var.region

  cluster    = google_container_cluster.primary.name
  node_count = var.gke_num_nodes

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = data.google_project.project.name
    }

    machine_type = var.node_type
    tags         = ["gke-node", "${data.google_project.project.name}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

# Static global IP for ingress
resource "google_compute_global_address" "default" {
  name = "${data.google_project.project.name}-global-address"
}