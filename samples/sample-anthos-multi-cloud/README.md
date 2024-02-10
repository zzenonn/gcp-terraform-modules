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

## Multi-cluster

### Login to AWS Cluster
Make sure you log-in to the AWS cluster:

1. **Go to Navigation > Kubernetes Engine > Clusters**, scroll to the right, click on the 3 dots to open the dropdown menu of the **onprem-connect** cluster row, and click on the **Log in** option.

2. When prompted, use your Google Cloud account to login.

3. You should now see two clusters listed with green checkmarks which indicates both clusters are registered successfully.


### Anthos Config Management

Anthos Config Management allows for the centralized management and synchronization of Kubernetes cluster configurations across different environments, leveraging the power of Git repositories for configuration storage. This powerful tool enables seamless, automated deployment and maintenance of cluster configurations, ensuring consistency, compliance, and the application of best practices across all managed clusters.

#### Deployment Steps

To deploy the config management operators for synchronizing your clusters with the desired state defined in a Git repository, follow the steps outlined below. These steps involve setting environment variables, obtaining credentials for your Kubernetes clusters managed through GKE (Google Kubernetes Engine) and AWS, switching Kubernetes contexts to target each cluster, and applying the Config Management Operator configuration.

1. **Set Environment Variables**

   Begin by specifying your GCP region and project ID. Replace `"asia-southeast1"` with your target region and `<project_id>` with your Google Cloud Platform project ID.

   ```sh
   REGION="asia-southeast1" # replace with your region
   PROJECT_ID="<project_id>" # replace with your GCP project ID
   ```
2. **Deploy to Attached Clusters**

    To deploy the Config Management Operator to a GKE cluster, obtain the cluster credentials, switch your kubectl context to the GKE cluster, and apply the Config Management Operator YAML file.

    ```sh
    gcloud container fleet memberships get-credentials $PROJECT_ID-gke --project $PROJECT_ID
    kubectx gke=connectgateway_${PROJECT_ID}_${REGION}_${PROJECT_ID}-gke
    kubectx gke
    kubectl apply -f kubernetes-manifests/config-sync/config-management-operator.yaml
    ```

    Do the same with the AWS cluster
    ```sh
    gcloud container fleet memberships get-credentials $PROJECT_ID-aws-cluster --project $PROJECT_ID
    kubectx aws=connectgateway_${PROJECT_ID}_global_${PROJECT_ID}-aws-cluster
    kubectx aws
    kubectl apply -f kubernetes-manifests/config-sync/config-management-operator.yaml
    ```

3. **Configure Git Credentials Secret**

    If your cluster configurations are stored in a private Git repository, it's necessary to create a Kubernetes secret with your Git SSH credentials to implement the GitOps approach. The following command prepares a secret YAML file by replacing a placeholder with your base64-encoded SSH private key.

    ```sh
    sed "s|<base64-encoded-id_rsa.acm>|$(cat /path/to/your/id_rsa.acm | base64 | tr -d '\n')|g" kubernetes-manifests/config-sync/gitops-secret-ssh.yaml > kubernetes-manifests/config-sync/gitops-secret-ssh-filled.yaml
    ```
    Ensure you replace /path/to/your/id_rsa.acm with the actual path to your SSH private key file. This step is essential for authenticating the Config Management Operator with your Git repository, enabling it to fetch and apply the configurations.
    
## Note

Please ensure that you have the necessary permissions in your AWS and GCP accounts to create and manage the resources defined in these scripts. Also, remember that you may incur charges in your AWS and GCP accounts for the resources created by these scripts.
