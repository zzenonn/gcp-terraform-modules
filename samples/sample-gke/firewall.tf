resource "google_compute_firewall" "allow_icmp" {
  count         = var.vpc_id == null ? 1 : 0
  name          = "allow-icmp"
  network       = google_compute_network.vpc.id
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "allow_ssh" {
  count         = var.vpc_id == null ? 1 : 0
  name          = "allow-ssh"
  network       = google_compute_network.vpc.id
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall" "allow_healthcheck" {
  name          = "allow-healthcheck"
  network       = google_compute_network.vpc.id
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  source_tags   = ["allow-health-checks"]

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}