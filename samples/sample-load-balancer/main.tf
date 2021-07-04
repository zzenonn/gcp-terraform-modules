provider "google" {
  region  = "asia-east2"
  project = "terraform-network-test"
}

data "google_client_config" "this" {
  provider = google
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

module "network_other_region" {
  count = length(var.regions)

  vpc_id           = module.network.vpc
  region           = var.regions[count.index]
  source           = "../../modules/infrastructure/network"
  private_cidr     = var.private_cidr
  public_subnets   = 0
  private_subnets  = 1
  db_subnets       = 0
  private_new_bits = 8
}

module "lb-scaling" {
  source           = "../../modules/infrastructure/load-balancer-scaling"
  regions = concat(var.regions, [data.google_client_config.this.region])
  vpc_id      = module.network.vpc
  instance_template = google_compute_instance_template.instance_template.id
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

# resource "google_compute_firewall" "allow_http" {
#   name    = "allow-http"
#   network = module.network.vpc
#   source_ranges = ["0.0.0.0/0"]
#   source_tags = ["loadbalancer"]
  
#   allow {
#     protocol = "tcp"
#     ports    = ["80"]
#   }
# }

resource "google_compute_firewall" "allow_healthcheck" {
  name    = "allow-healthcheck"
  network = module.network.vpc
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  source_tags = ["allow-health-checks"]
  
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}

resource "google_compute_instance_template" "instance_template" {
  name_prefix  = "instance-template-"
  machine_type = "e2-micro"

  tags = ["allow-health-checks"]

  disk {
    source_image = "debian-10"
    auto_delete       = true
    boot              = true
    disk_size_gb      = 10
  }

  network_interface {
    network = module.network.vpc
    subnetwork = module.network.private_subnets[0]
  }

  metadata_startup_script = var.startup_script

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_instance_template" "instance_template_other_regions" {
  count = length(var.regions)
  region          =  var.regions[count.index]

  name_prefix  = "instance-template-"
  machine_type = "e2-micro"

  tags = ["allow-health-checks"]

  disk {
    source_image = "debian-10"
    auto_delete       = true
    boot              = true
    disk_size_gb      = 10
  }

  network_interface {
    network = module.network.vpc
    subnetwork = module.network_other_region[count.index].private_subnets[0]
  }

  metadata_startup_script = var.startup_script

  lifecycle {
    create_before_destroy = true
  }
}