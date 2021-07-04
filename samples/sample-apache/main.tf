provider "google" {
  region  = "asia-east2"
  project = "terraform-network-test"
}

module "network" {
  source           = "../../modules/infrastructure/network"
  public_cidr      = var.public_cidr
  private_cidr     = var.private_cidr
  db_cidr          = var.db_cidr
  public_subnets   = 1
  private_subnets  = 1
  db_subnets       = 1
  public_new_bits  = 8
  private_new_bits = 8
  db_new_bits      = 8
  cloud_router     = true
}



resource "google_compute_router_nat" "nat" {
  name                               = "cloud-nat"
  router                             = module.network.cloud_router
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  dynamic "subnetwork" {
    for_each = [for subnet in module.network.private_subnets : {
      name = subnet
    }]
    content {
      name = subnetwork.value.name

      source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
    }
  }
}

resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = module.network.vpc
  source_ranges = ["0.0.0.0/0"]
  source_tags = ["webserver"]
  
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}

resource "google_compute_instance" "webserver" {
  name         = "sample-apache"
  machine_type = "e2-micro"
  zone         = "asia-east2-b"
  
  tags = ["webapp"]

  boot_disk {
    initialize_params {
      size = 10
      image = "debian-10"
    }
  }

  network_interface {
    network = module.network.vpc
    subnetwork = module.network.public_subnets[0]
    access_config {} # Assigns a public ip
  }

  metadata_startup_script = <<EOF
#! /bin/bash
apt update
apt -y install apache2
cat <<EOF > /var/www/html/index.html
<html><body><p>Linux startup script added directly.</p></body></html>
EOF

}