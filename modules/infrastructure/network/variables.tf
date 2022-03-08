variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "region" {
  type        = string
  default     = null
  description = "Region to deploy networks"
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

variable "public_subnets" {
  type        = number
  default     = 1
  description = "Number of public subnets"
}

variable "private_subnets" {
  type        = number
  default     = 1
  description = "Number of private subnets"
}

variable "db_subnets" {
  type        = number
  default     = 1
  description = "Number of DB subnets"
}

variable "public_new_bits" {
  type        = number
  default     = 8
  description = "Bits to add to the original public subnet prefix length"
}

variable "private_new_bits" {
  type        = number
  default     = 8
  description = "Bits to add to the original private subnet prefix length"
}

variable "db_new_bits" {
  type        = number
  default     = 8
  description = "Bits to add to the original DB subnet prefix length"
}

variable "cloud_router" {
  type        = bool
  default     = true
  description = "If a cloud nat and router need to be created."
}

variable "db_port" {
  type        = number
  default     = 5432
  description = "Port of the database being used"
}

resource "google_compute_router" "router" {
  count   = var.cloud_router ? 1 : 0
  name    = "cloud-router"
  network = var.vpc_id
  region  = var.region
}

