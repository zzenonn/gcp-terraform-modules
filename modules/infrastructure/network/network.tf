resource "google_compute_subnetwork" "public" {
  count         = var.public_subnets
  name          = "public-subnet-${count.index}"
  ip_cidr_range = cidrsubnet(var.public_cidr, var.public_new_bits, count.index)
  network       = var.vpc_id
  region        = var.region
}

resource "google_compute_subnetwork" "private" {
  count         = var.private_subnets
  name          = "private-subnet-${count.index}"
  ip_cidr_range = cidrsubnet(var.private_cidr, var.private_new_bits, count.index)
  network       = var.vpc_id
  region        = var.region
}

resource "google_compute_subnetwork" "db" {
  count         = var.db_subnets
  name          = "db-subnet-${count.index}"
  ip_cidr_range = cidrsubnet(var.db_cidr, var.db_new_bits, count.index)
  network       = var.vpc_id
  region        = var.region
}
