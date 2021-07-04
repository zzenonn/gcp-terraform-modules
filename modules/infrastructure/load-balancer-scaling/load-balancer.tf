resource "google_compute_health_check" "health_check" {
  name                = "health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10 # 50 seconds

  http_health_check {
    port         = var.load_balancer_port
  }
}

resource "google_compute_region_instance_group_manager" "appserver" {
  count = length(var.regions)
  
  name = "appserver-igm-${var.regions[count.index]}"

  base_instance_name         = "webapp"
  region                     = var.regions[count.index]

  version {
    instance_template = var.instance_template
  }

  named_port {
    name = "custom"
    port = 80
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.health_check.id
    initial_delay_sec = 120
  }
}

resource "google_compute_region_autoscaler" "appserver" {
  count = length(var.regions)
  
  name   = "autoscaler-${var.regions[count.index]}"
  target = google_compute_region_instance_group_manager.appserver[count.index].id

  autoscaling_policy {
    max_replicas    = 5
    min_replicas    = 1
    cooldown_period = 60

    load_balancing_utilization {
      target = 80
    }
  }
}