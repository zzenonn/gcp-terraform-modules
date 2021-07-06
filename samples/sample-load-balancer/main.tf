provider "google" {
  region  = "asia-east2"
  project = "terraform-network-test"
}

data "google_client_config" "this" {
  provider = google
}

resource "google_compute_network" "vpc" {
  name                    = "main-vpc"
  auto_create_subnetworks = false
}

module "network" {
  source           = "../../modules/infrastructure/network"
  vpc_id           = google_compute_network.vpc.id
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
  for_each = toset(var.regions)

  vpc_id           = google_compute_network.vpc.id
  region           = each.key
  source           = "../../modules/infrastructure/network"
  private_cidr     = cidrsubnet("10.64.0.0/8", 6, index(var.regions, each.key) + 1)
  public_subnets   = 0
  private_subnets  = 1
  db_subnets       = 0
  private_new_bits = 10
  cloud_router     = false
}

module "lb_scaling" {
  depends_on = [
    google_compute_router_nat.nat
  ]
  source           = "../../modules/infrastructure/load-balancer-scaling"
  regions = local.regions
  vpc_id      = google_compute_network.vpc.id
  instance_templates = google_compute_instance_template.instance_template
}


resource "google_compute_router_nat" "nat" {
  name                               = "cloud-nat"
  router                             = module.network.cloud_router
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  dynamic "subnetwork" {
    for_each = toset(local.regions)
    content {
      name = try(module.network_other_region[subnetwork.key].private_subnets[0].name, module.network.private_subnets[0].name)

      source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
    }
  }
}

resource "google_compute_instance_template" "instance_template" {
  for_each = toset(local.regions)

  name_prefix  = "instance-template-"
  machine_type = "e2-micro"

  region       = each.key

  tags = ["allow-health-checks"]

  disk {
    source_image = "debian-10"
    auto_delete       = true
    boot              = true
    disk_size_gb      = 10
  }

  network_interface {
    network = google_compute_network.vpc.id
    subnetwork = try(module.network_other_region[each.key].private_subnets[0].name, module.network.private_subnets[0].name)
  }

  metadata_startup_script = var.startup_script

  lifecycle {
    create_before_destroy = true
  }
}