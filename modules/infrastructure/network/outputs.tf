output "vpc" {
  value = local.vpc_network
}

output "cloud_router" {
  value = google_compute_router.router[0].name
}

output "public_subnets" {
  value = google_compute_subnetwork.public.*.name
}

output "private_subnets" {
  value = google_compute_subnetwork.private.*.name
}

output "db_subnets" {
  value = google_compute_subnetwork.db.*.name
}