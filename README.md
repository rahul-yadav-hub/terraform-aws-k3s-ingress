# Terraform K3S Cluster Deployment Project

This Terraform project enables single-click, fully automated deployment of a multi-node k3s(v1.24.17+k3s1) cluster on a custom VPC, seamlessly integrated with AWS cloud controller. The module is designed to simplify the provisioning of Kubernetes clusters with unparalleled ease and efficiency.

## Features

- **Single-Click Automation**: Deploy your entire Kubernetes cluster with just one click, saving time and effort.
- **Modular Design**: Built on Terraform modules for easy customization and adaptability to diverse environments.
- **Scalable VPC Configuration**: Create custom VPCs with any number of public and private subnets to match your unique needs.
- **Seamless AWS Integration**: Leverages AWS cloud controller for smooth interaction with your cloud infrastructure, ensuring reliability and performance.
- **Custom IAM Roles and Policies**: Automatically creates custom IAM roles and policies for cluster nodes to access other AWS resources securely.
- **Highly Available Cluster Nodes**: Utilizes multiple Availability Zones (AZs) for cluster nodes to ensure high availability and fault tolerance.
- **Secure Deployment**: Deployed in private subnets for enhanced security, safeguarding your cluster from unauthorized access.
- **NGINX Ingress Controller**: Integrated NGINX ingress controller for efficient management of inbound traffic to your cluster services.

## Usage

1. **Clone the Repository**: Clone this repository to your local machine.

    ```shell
    git clone <repository_url>
    ```

2. **Navigate to the Project Directory**: Change directory to the cloned repository.

    ```shell
    cd <repository_name>
    ```

3. **Update Terraform Variables**: Modify the `testing.auto.tfvars` file to specify your desired configuration parameters for testing.

4. **Deploy the Kubernetes Cluster**: Run Terraform commands to initialize, plan, and apply the changes.

    ```shell
    terraform init
    terraform plan
    terraform apply
    ```

5. **Verify Cluster Deployment**: Once the Terraform deployment completes successfully, verify the deployment by accessing the Kubernetes cluster using `kubectl` commands.

6. **Deploy Sample nginx application with ingress**: Use the `test-deploy.yml` manifest file to deploy same application and test.
Update host name value for ingress.

    ```shell
    kubectl apply -f test-deploy.yml
    ```
7. **Delete the cluster**: To delete alll the resources and cluster, you need to first delete the ingress load balancer manually from the AWS console and its associated security group.
    ```shell
    terraform destroy --auto-approve
    ```






