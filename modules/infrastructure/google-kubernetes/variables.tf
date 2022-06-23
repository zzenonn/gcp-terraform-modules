variable "region" {
  type        = string
  default     = null
  description = "Region to deploy kubernetes"
}

variable "enable_autopilot" {
  type        = bool
  default     = false
  description = "Enable GKE autopilot"
}

variable "gke_num_nodes" {
  default     = 3
  description = "Number of gke nodes"
}

variable "vpc_id" {
  description = "VPC Network of the cluster"
}

variable "subnet_id" {
  description = "Subnet to provision the cluster in"
}

variable "pod_ip_addr_range" {
  default     = "192.168.0.0/16"
  description = "IP address range used by pods"
}

variable "services_ip_addr_range" {
  default     = "172.16.0.0/16"
  description = "IP address range used by services"
}

variable "node_type" {
  default     = "e2-medium"
  description = "Node type used by noed group"
}

data "google_project" "project" {}

data "google_compute_zones" "available" {}

