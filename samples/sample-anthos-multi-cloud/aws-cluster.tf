data "google_container_aws_versions" "versions" {
  project = data.google_project.current.project_id
  location = var.regions[0]
}

resource "google_container_aws_cluster" "primary" {

  depends_on = [
        aws_iam_role.aws_cluster_anthos_api_role,
        aws_iam_role.aws_cluster_anthos_cp_role,
        aws_iam_policy_attachment.aws_cluster_anthos_api_role_policy_attachment,
        aws_iam_policy_attachment.aws_cluster_anthos_cp_role_policy_attachment,
    ]
  
  location = var.regions[0]
  name     = "${data.google_project.current.name}-aws-cluster"
  description = "A sample aws cluster"

  authorization {
    admin_users {
      username = var.admin_user
    }
  }

  aws_region = "ap-southeast-1"

  control_plane {
    aws_services_authentication {
      role_arn          = aws_iam_role.aws_cluster_anthos_api_role.arn
      role_session_name = "${aws_iam_role.aws_cluster_anthos_api_role.name}-session"
    }

    config_encryption {
      kms_key_arn = aws_kms_key.anthos_cluster.arn
    }

    database_encryption {
      kms_key_arn = aws_kms_key.anthos_cluster.arn
    }

    iam_instance_profile = aws_iam_instance_profile.anthos_cp_instance_profile.arn
    subnet_ids           = aws_subnet.private[*].id
    version   = "${data.google_container_aws_versions.versions.valid_versions[0]}"
    instance_type        = "t3.medium"

    main_volume {
      iops        = 3000
      kms_key_arn = aws_kms_key.anthos_cluster.arn
      size_gib    = 30
      volume_type = "GP3"
    }

    root_volume {
      iops        = 3000
      kms_key_arn = aws_kms_key.anthos_cluster.arn
      size_gib    = 10
      volume_type = "GP3"
    }

    ssh_config {
      ec2_key_pair = "zenon"
    }

    tags = {
      owner = var.admin_user
    }
  }

  fleet {
    project = data.google_project.current.number
  }

  networking {
    pod_address_cidr_blocks     = ["10.2.0.0/16"]
    service_address_cidr_blocks = ["10.1.0.0/16"]
    vpc_id                      = aws_vpc.vpc.id
  }

  
}

resource "google_container_aws_node_pool" "primary" {
  depends_on = [
        aws_iam_role.aws_cluster_anthos_np_role,
        aws_iam_policy_attachment.aws_cluster_anthos_np_role_policy_attachment
    ]

  count    = length(aws_subnet.private)
  name      = "${data.google_project.current.name}-node-pool-${count.index}"
  location = var.regions[0]
  subnet_id = aws_subnet.private[count.index].id
  version   = "${data.google_container_aws_versions.versions.valid_versions[0]}"

  autoscaling {
    max_node_count = 2
    min_node_count = 1
  }

  cluster = google_container_aws_cluster.primary.name

  config {
    config_encryption {
      kms_key_arn = aws_kms_key.anthos_cluster.arn
    }

    iam_instance_profile = aws_iam_instance_profile.aws_cluster_anthos_np_instance_profile.arn
    instance_type        = "t3.medium"


    root_volume {
      iops        = 3000
      kms_key_arn = aws_kms_key.anthos_cluster.arn
      size_gib    = 10
      volume_type = "gp3"
    }

    ssh_config {
      ec2_key_pair = "zenon"
    }

    tags = {
      owner = var.admin_user
    }

  }

  max_pods_constraint {
    max_pods_per_node = 110
  }

}