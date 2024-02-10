# Multi-Cloud Anthos

This project contains Terraform scripts for creating a multi-cloud Google Kubernetes Engine (GKE) cluster on Google Cloud Platform (GCP) and an Amazon Web Services (AWS) cluster using Anthos on AWS.

## Project Structure

The project is organized into several Terraform files, each responsible for a specific set of resources:

- `main.tf`: This is the main entry point for Terraform. It sets up the GCP and AWS providers and calls the other modules to create resources.
- `variables.tf`: This file defines all the variables used across the project.
- `aws-cluster.tf`: This file contains the Terraform configuration for creating the AWS cluster using Anthos.
- `aws-data.tf`: This file contains data sources for AWS resources.
- `aws-iam.tf`: This file contains the Terraform configuration for creating IAM roles and policies in AWS.
- `aws-network.tf`: This file contains the Terraform configuration for setting up the network in AWS, including VPC, subnets, and NAT gateways.
- `firewall.tf`: This file contains the Terraform configuration for setting up firewall rules in GCP.
- `network.tf`: This file contains the Terraform configuration for setting up the network in GCP, including VPC and subnets.

## Usage

To use these scripts, you will need to have Terraform installed on your machine. You can download Terraform from the [official website](https://www.terraform.io/downloads.html).

You will also need to have the AWS CLI and GCP CLI installed and configured with your account credentials.

Once you have Terraform and the necessary CLIs installed, you can initialize Terraform with the following command:

```bash
terraform init
```

This will download the necessary provider plugins for AWS and GCP.

Next, you can check what changes Terraform will make with the following command:

```bash
terraform plan
```

If everything looks correct, you can apply the changes with the following command:

```bash
terraform apply
```

Terraform will ask for confirmation before making any changes. Type `yes` to confirm.

To destroy the resources created by Terraform, use the following command:

```bash
terraform destroy
```

Again, Terraform will ask for confirmation before destroying any resources. Type `yes` to confirm.

## Variables

The `variables.tf` file contains all the variables used in the project. You can change the values of these variables to customize the resources that are created.

For example, you can change the `vpc_cidr` variable to use a different CIDR block for the VPC, or you can change the `regions` variable to create resources in different regions.

## Note

Please ensure that you have the necessary permissions in your AWS and GCP accounts to create and manage the resources defined in these scripts. Also, remember that you may incur charges in your AWS and GCP accounts for the resources created by these scripts.
