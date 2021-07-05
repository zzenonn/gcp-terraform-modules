variable "vpc_id" {
  type        = string
  description = "Comes from networking template"
}

variable "regions" {
  type        = list(string)
  default     = []
  description = "What region(s) the MIG will use"
}


variable "instance_templates" {
  type        = map(any)
  description = "The template used for the managed instance group (MIG)"
}

variable "load_balancer_port" {
  type        = number
  default     = 80
  description = "Inbound port for the ELB"
}

