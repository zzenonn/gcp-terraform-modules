variable "vpc_id" {
  type        = string
  default     = null
  description = "Project id"
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

variable "regions" {
  type        = list(any)
  description = "Regions to include"
}

variable "startup_script" {
  type        = string
  description = "Startup script for VMs"
}