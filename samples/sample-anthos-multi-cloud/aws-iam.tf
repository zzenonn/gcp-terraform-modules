resource "aws_kms_key" "anthos_cluster" {
    description             = "KMS Key for anthos cluster"
    deletion_window_in_days = 30
    policy                  = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Sid": "Allow service-linked role use of the customer managed key",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
                ]
            },
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:DescribeKey"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Allow attachment of persistent resources",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
                ]
            },
            "Action": [
                "kms:CreateGrant"
            ],
            "Resource": "*",
            "Condition": {
                "Bool": {
                    "kms:GrantIsForAWSResource": true
                }
            }
        }
    ]
}
EOF
}


resource "aws_iam_instance_profile" "anthos_cp_instance_profile" {
    name = "aws_cluster_anthos-cp-instance-profile"
    role = aws_iam_role.aws_cluster_anthos_cp_role.name
}

resource "aws_iam_role" "aws_cluster_anthos_cp_role" {
    name = "aws-cluster-anthos-cp-role"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}


resource "aws_iam_policy" "aws_cluster_anthos_cp_role_policy" {
    name        = "aws-cluster-anthos-cp-role-policy"
    description = "Policy for CP role"
    policy      = <<EOF
{
    "Statement": [
        {
            "Action": [
                "kms:GrantIsForAWSResource",
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:CreateGrant",
                "elasticloadbalancing:SetLoadBalancerPoliciesOfListener",
                "elasticloadbalancing:SetLoadBalancerPoliciesForBackendServer",
                "elasticloadbalancing:RegisterTargets",
                "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
                "elasticloadbalancing:ModifyTargetGroup",
                "elasticloadbalancing:ModifyLoadBalancerAttributes",
                "elasticloadbalancing:ModifyListener",
                "elasticloadbalancing:DetachLoadBalancerFromSubnets",
                "elasticloadbalancing:DescribeTargetHealth",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:DescribeLoadBalancers",
                "elasticloadbalancing:DescribeLoadBalancerPolicies",
                "elasticloadbalancing:DescribeLoadBalancerAttributes",
                "elasticloadbalancing:DescribeListeners",
                "elasticloadbalancing:DeregisterTargets",
                "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
                "elasticloadbalancing:DeleteTargetGroup",
                "elasticloadbalancing:DeleteLoadBalancerListeners",
                "elasticloadbalancing:DeleteLoadBalancer",
                "elasticloadbalancing:DeleteListener",
                "elasticloadbalancing:CreateTargetGroup",
                "elasticloadbalancing:CreateLoadBalancerPolicy",
                "elasticloadbalancing:CreateLoadBalancerListeners",
                "elasticloadbalancing:CreateLoadBalancer",
                "elasticloadbalancing:CreateListener",
                "elasticloadbalancing:ConfigureHealthCheck",
                "elasticloadbalancing:AttachLoadBalancerToSubnets",
                "elasticloadbalancing:ApplySecurityGroupsToLoadBalancer",
                "elasticloadbalancing:AddTags",
                "elasticfilesystem:DescribeMountTargets",
                "elasticfilesystem:DescribeFileSystems",
                "elasticfilesystem:DescribeAccessPoints",
                "elasticfilesystem:DeleteAccessPoint",
                "elasticfilesystem:CreateAccessPoint",
                "ec2:RevokeSecurityGroupIngress",
                "ec2:ModifyVolume",
                "ec2:ModifyInstanceAttribute",
                "ec2:DetachVolume",
                "ec2:DescribeVpcs",
                "ec2:DescribeVolumesModifications",
                "ec2:DescribeVolumes",
                "ec2:DescribeTags",
                "ec2:DescribeSubnets",
                "ec2:DescribeSnapshots",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeRouteTables",
                "ec2:DescribeRegions",
                "ec2:DescribeLaunchTemplateVersions",
                "ec2:DescribeInternetGateways",
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceTypes",
                "ec2:DescribeDhcpOptions",
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeAccountAttributes",
                "ec2:DeleteVolume",
                "ec2:DeleteTags",
                "ec2:DeleteSnapshot",
                "ec2:DeleteSecurityGroup",
                "ec2:DeleteRoute",
                "ec2:CreateVolume",
                "ec2:CreateTags",
                "ec2:CreateSnapshot",
                "ec2:CreateSecurityGroup",
                "ec2:CreateRoute",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:AttachVolume",
                "ec2:AttachNetworkInterface",
                "autoscaling:TerminateInstanceInAutoScalingGroup",
                "autoscaling:SetDesiredCapacity",
                "autoscaling:DescribeTags",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeAutoScalingGroups"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt"
            ],
            "Effect": "Allow",
            "Resource": "${aws_kms_key.anthos_cluster.arn}"
        }
    ],
    "Version": "2012-10-17"
}
EOF
}

resource "aws_iam_policy_attachment" "aws_cluster_anthos_cp_role_policy_attachment" {
    name       = "cp-role-policy-attachment"
    roles      = [aws_iam_role.aws_cluster_anthos_cp_role.name]
    policy_arn = aws_iam_policy.aws_cluster_anthos_cp_role_policy.arn
}


resource "aws_iam_instance_profile" "aws_cluster_anthos_np_instance_profile" {
    name = "aws-cluster-anthos-np-instance-profile"
    role = aws_iam_role.aws_cluster_anthos_np_role.name
}

resource "aws_iam_role" "aws_cluster_anthos_np_role" {
    name = "aws-cluster-anthos-np-role"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_policy" "np_role_policy" {
    name        = "np-role-policy"
    description = "Policy for NP role"
    policy      = <<EOF
{
    "Statement": [
        {
            "Action": [
                "ec2:DescribeTags",
                "ec2:DescribeInstances",
                "ec2:AttachNetworkInterface",
                "autoscaling:DescribeAutoScalingGroups"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt"
            ],
            "Effect": "Allow",
            "Resource": "${aws_kms_key.anthos_cluster.arn}"
        }
    ],
    "Version": "2012-10-17"
}
EOF
}

resource "aws_iam_policy_attachment" "aws_cluster_anthos_np_role_policy_attachment" {
    name       = "np-role-policy-attachment"
    roles      = [aws_iam_role.aws_cluster_anthos_np_role.name]
    policy_arn = aws_iam_policy.np_role_policy.arn
}


resource "aws_iam_role" "aws_cluster_anthos_api_role" {
    name = "aws-cluster-anthos-api-role"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "accounts.google.com"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "accounts.google.com:sub": "service-${data.google_project.current.number}@gcp-sa-gkemulticloud.iam.gserviceaccount.com"
                }
            }
        }
    ]
}
EOF
}

resource "aws_iam_policy" "api_role_policy" {
    name        = "api-role-policy"
    description = "Policy for API role"
    policy      = <<EOF
{
    "Statement": [
        {
            "Action": [
                "iam:GetInstanceProfile",
                "kms:GenerateDataKeyWithoutPlaintext",
                "kms:Encrypt",
                "kms:DescribeKey",
                "iam:PassRole",
                "iam:CreateServiceLinkedRole",
                "iam:AWSServiceName",
                "elasticloadbalancing:RemoveTags",
                "elasticloadbalancing:ModifyTargetGroupAttributes",
                "elasticloadbalancing:DescribeTargetHealth",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:DescribeLoadBalancers",
                "elasticloadbalancing:DescribeListeners",
                "elasticloadbalancing:DeleteTargetGroup",
                "elasticloadbalancing:DeleteLoadBalancer",
                "elasticloadbalancing:DeleteListener",
                "elasticloadbalancing:CreateTargetGroup",
                "elasticloadbalancing:CreateLoadBalancer",
                "elasticloadbalancing:CreateListener",
                "elasticloadbalancing:AddTags",
                "ec2:RunInstances",
                "ec2:RevokeSecurityGroupIngress",
                "ec2:RevokeSecurityGroupEgress",
                "ec2:ModifyNetworkInterfaceAttribute",
                "ec2:ModifyInstanceAttribute",
                "ec2:GetConsoleOutput",
                "ec2:DescribeVpcs",
                "ec2:DescribeSubnets",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSecurityGroupRules",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeLaunchTemplates",
                "ec2:DescribeKeyPairs",
                "ec2:DescribeInternetGateways",
                "ec2:DescribeInstances",
                "ec2:DescribeAccountAttributes",
                "ec2:DeleteVolume",
                "ec2:DeleteTags",
                "ec2:DeleteSecurityGroup",
                "ec2:DeleteNetworkInterface",
                "ec2:DeleteLaunchTemplate",
                "ec2:CreateVolume",
                "ec2:CreateTags",
                "ec2:CreateSecurityGroup",
                "ec2:CreateNetworkInterface",
                "ec2:CreateLaunchTemplate",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:AuthorizeSecurityGroupEgress",
                "autoscaling:UpdateAutoScalingGroup",
                "autoscaling:TerminateInstanceInAutoScalingGroup",
                "autoscaling:EnableMetricsCollection",
                "autoscaling:DisableMetricsCollection",
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DeleteTags",
                "autoscaling:DeleteAutoScalingGroup",
                "autoscaling:CreateOrUpdateTags",
                "autoscaling:CreateAutoScalingGroup"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ],
    "Version": "2012-10-17"
}
EOF
}

resource "aws_iam_policy_attachment" "aws_cluster_anthos_api_role_policy_attachment" {
    name       = "api-role-policy-attachment"
    roles      = [aws_iam_role.aws_cluster_anthos_api_role.name]
    policy_arn = aws_iam_policy.api_role_policy.arn
}