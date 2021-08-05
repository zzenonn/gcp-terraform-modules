variable "vpc_id" {
  type        = string
  default     = null
  description = "Project id"
}

variable "regions" {
  type        = list(string)
  default     = []
  description = "Regions other than the provider region to deploy the application in."
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

locals {
  regions = concat(var.regions, [data.google_client_config.this.region])
}