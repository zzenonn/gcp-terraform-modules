variable "vpc_id" {
  type        = string
  default     = null
  description = "Project id"
}

variable "region" {
  type        = string
  default     = "asia-east2"
  description = "Region to provision resources"
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

variable "db_port" {
  type        = number
  default     = 5432
  description = "Port of the database being used"
}

data "google_compute_zones" "zone" {
    region = var.region
}