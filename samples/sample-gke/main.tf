provider "google" {
  project = "terraform-network-test-343501"
}

data "google_client_config" "this" {
  provider = google
}

resource "google_compute_network" "vpc" {
  name                    = "main-vpc"
  auto_create_subnetworks = false
}

module "network" {
  for_each = toset(var.regions)
  source           = "../../modules/infrastructure/network"
  region = each.key # Increments of 64 in the second octet
  vpc_id           = google_compute_network.vpc.id
  public_cidr      = cidrsubnet(var.vpc_cidr, 16, (index(var.regions, each.key) * 16384) ) #  10.*.0
  private_cidr     = cidrsubnet(var.vpc_cidr, 16, (index(var.regions, each.key) * 16384) + 128) # 10.*.128
  db_cidr          = cidrsubnet(var.vpc_cidr, 16, (index(var.regions, each.key) * 16384) + 192) # 10.*.192
  public_subnets   = 1
  private_subnets  = 1
  db_subnets       = 1
  public_new_bits  = 0
  private_new_bits = 0
  db_new_bits      = 0
  cloud_router     = true
}


module "gke_cluster" {
  for_each = toset(var.regions)
  source                 = "github.com/zzenonn/gcp-terraform-modules/modules/infrastructure/google-kubernetes"
  region                 = each.key
  vpc_id                 = google_compute_network.vpc.id
  subnet_id              = module.network[each.key].private_subnets[0].name
  pod_ip_addr_range      = "192.168.0.0/16"
  services_ip_addr_range = "172.16.0.0/16"
  node_type              = "e2-medium"
  gke_num_nodes          = 1
}


resource "google_compute_router_nat" "nat" {
  for_each = toset(var.regions)
  name                               = "${each.key}-cloud-nat"
  router                             = module.network[each.key].cloud_router
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  region = each.key
  

  dynamic "subnetwork" {
    for_each = toset(module.network[each.key].private_subnets[*])
    content {
      name = subnetwork.key.name

      source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
    }
  }
}

# resource "google_compute_instance_template" "instance_template" {
#   for_each = toset(local.regions)

#   name_prefix  = "instance-template-"
#   machine_type = "e2-micro"

#   region       = each.key

#   tags = ["allow-health-checks"]

#   disk {
#     source_image = "debian-10"
#     auto_delete       = true
#     boot              = true
#     disk_size_gb      = 10
#   }

#   network_interface {
#     network = google_compute_network.vpc.id
#     subnetwork = try(module.network_other_region[each.key].private_subnets[0].name, module.network.private_subnets[0].name)
#   }

#   metadata_startup_script = var.startup_script

#   lifecycle {
#     create_before_destroy = true
#   }
# }