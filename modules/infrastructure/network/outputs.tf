output "cloud_router" {
  value = var.cloud_router ? google_compute_router.router[0].name : ""
}

output "public_subnets" {
  value = google_compute_subnetwork.public.*
}

output "private_subnets" {
  value = google_compute_subnetwork.private.*
}

output "db_subnets" {
  value = google_compute_subnetwork.db.*
}