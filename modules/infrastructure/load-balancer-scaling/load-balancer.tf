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
  for_each = toset(var.regions)
  
  name = "appserver-mig-${each.key}"

  base_instance_name         = "webapp"
  region                     = each.key

  version {
    instance_template = var.instance_templates[each.key].id
  }

  named_port {
    name = "custom"
    port = var.load_balancer_port
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.health_check.id
    initial_delay_sec = 120
  }
}

resource "google_compute_region_autoscaler" "appserver" {
  for_each = toset(var.regions)
  
  name   = "autoscaler-${each.key}"
  region = each.key
  target = google_compute_region_instance_group_manager.appserver[each.key].id

  autoscaling_policy {
    max_replicas    = 5
    min_replicas    = 1
    cooldown_period = 60

    load_balancing_utilization {
      target = 0.80
    }
  }
}



resource "google_compute_backend_service" "service" { 
  load_balancing_scheme = "EXTERNAL"

  dynamic "backend" {
    for_each = google_compute_region_instance_group_manager.appserver
    content {
      group          = backend.value.instance_group
      balancing_mode = "UTILIZATION"
      capacity_scaler = 1.0
      max_utilization = 0.8
    }
  }

  name        = "public-backend-service"
  protocol    = "HTTP"
  timeout_sec = 30

  health_checks = [google_compute_health_check.health_check.id]

  log_config {
    enable = true
    sample_rate = 1
  }
}

resource "google_compute_url_map" "urlmap" {
  name        = "urlmap"
  description = "Basic URL map."
  default_service = google_compute_backend_service.service.id


  # path_matcher {
  #     name            = "mysite"
  #     default_service = google_compute_backend_service.service.id
  # }
}

resource "google_compute_target_http_proxy" "webapp_lb" {
  name    = "load-balancer"
  url_map = google_compute_url_map.urlmap.id
}

resource "google_compute_global_forwarding_rule" "forwarding_rule_v6" {
  name       = "global-rule-v6"
  load_balancing_scheme = "EXTERNAL"
  ip_version = "IPV6"
  target     = google_compute_target_http_proxy.webapp_lb.id
  port_range = "80"
}

resource "google_compute_global_forwarding_rule" "forwarding_rule_v4" {
  name       = "global-rule-v4"
  load_balancing_scheme = "EXTERNAL"
  ip_version = "IPV4"
  target     = google_compute_target_http_proxy.webapp_lb.id
  port_range = "80"
}