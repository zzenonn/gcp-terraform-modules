variable "vpc_id" {
  type        = string
  default     = null
  description = "Project id"
}

variable "networks" {
  type = object({
    cidr_block       = string
    public_subnets   = list(string)
    private_subnets  = list(string)
    db_subnets       = list(string)
    nat_gateways     = number
  })
  default = {
    cidr_block       = "10.0.0.0/16"
    public_subnets   = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
    private_subnets  = ["10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]
    db_subnets       = ["10.0.6.0/24", "10.0.7.0/24", "10.0.8.0/24"]
    nat_gateways     = 1
  }
  description = "All information regarding network configuration is stored in this object."
}

variable "admin_user" {
  type        = string
  default     = "Admin"
  description = "Admin user for Anthos cluster. Needs to be a google account"
}

variable "enable_autopilot" {
  type        = bool
  default     = false
  description = "Enable GKE autopilot"
}

variable "regions" {
  type        = list(string)
  default     = []
  description = "Regions other than the provider region to deploy the application in."
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/8"
  description = "VPC CIDR Block"
}

variable "public_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "Public CIDR Block"
}

variable "private_cidr" {
  type        = string
  default     = "10.64.0.0/16"
  description = "Private CIDR Block"
}

variable "db_cidr" {
  type        = string
  default     = "10.192.0.0/16"
  description = "DB CIDR Block"
}

variable "startup_script" {
  type        = string
  default     = <<EOF
#!/bin/bash
apt update
apt -y install apache2
systemctl start apache2
systemctl enable apache2
EOF
  description = "Startup script for applications."
}

variable "db_port" {
  type        = number
  default     = 5432
  description = "Port of the database being used"
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "Environment (e.g., dev, prod, etc)"
}

data "aws_availability_zones" "azs" {
  # Ignore local zones
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  regions = concat(var.regions, [data.google_client_config.this.region])
  name_tag_prefix = "${data.google_project.current.name}-${var.environment}"
}