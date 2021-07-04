resource "google_compute_subnetwork" "public" {
  count         = var.public_subnets
  name          = "public-subnet-${count.index}"
  ip_cidr_range = cidrsubnet(var.public_cidr, var.public_new_bits, count.index)
  network       = local.vpc_network
  region        = var.region
}

resource "google_compute_subnetwork" "private" {
  count         = var.private_subnets
  name          = "private-subnet-${count.index}"
  ip_cidr_range = cidrsubnet(var.private_cidr, var.private_new_bits, count.index)
  network       = local.vpc_network
  region        = var.region
}

resource "google_compute_subnetwork" "db" {
  count         = var.db_subnets
  name          = "db-subnet-${count.index}"
  ip_cidr_range = cidrsubnet(var.db_cidr, var.db_new_bits, count.index)
  network       = local.vpc_network
  region        = var.region
}

resource "google_compute_firewall" "allow_icmp" {
  name    = "allow-icmp"
  network = local.vpc_network
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = local.vpc_network
  source_ranges = ["0.0.0.0/0"]
  
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}