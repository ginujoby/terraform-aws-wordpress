# Deploying Scalable WordPress on AWS with Terraform

This project provisions a WordPress environment on AWS using Terraform. It automates the deployment of the necessary AWS resources to run a scalable and secure WordPress site.

## Features

- **High Availability:** Deploys resources across multiple AWS Availability Zones for fault tolerance.
- **Auto Scaling:** Automatically adjusts the number of EC2 instances based on real-time demand.
- **Load Balancing:** Uses an Application Load Balancer to efficiently distribute incoming traffic.
- **Enhanced Security:** Implements private subnets, security groups, and IAM roles for robust protection.
- **Managed Database:** Utilizes Amazon RDS for a reliable, scalable MySQL backend.
- **Infrastructure as Code:** All resources are defined and managed using Terraform for repeatable, version-controlled deployments.

## Architecture Diagram

```
                                ┌───────────────────────────┐                                
                                │                           │                                
                                │         Internet          │                                
                                │                           │                                
                                └─────────────▲─────────────┘                                
                                              │                                              
                                ┌─────────────▼─────────────┐                                
                                │                           │                                
┌── VPC ────────────────────────│      Internet Gateway     │───────────────────────────────┐
│                               │                           │                               │
│                               └─────────────▲─────────────┘                               │
│                                             │                                             │
│                                             │                                             │
│                               ┌─────────────▼─────────────┐                               │
│                               │                           │                               │
│                               │ Application Load Balancer │                               │
│                               │                           │                               │
│                               └───────────────────────────┘                               │
│                                             ▲                                             │
│   ┌───────── Public Subnet 1 ─────────┐     │     ┌───────── Public Subnet 2 ─────────┐   │
│   │                                   │     │     │                                   │   │
│   │                                   │     │     │                                   │   │
│   │   ┌─────────────┐  ┌─────────┐    │     │     │    ┌─────────────┐                │   │
│   │   │             │  │         │    │     │     │    │             │                │   │
│   │   │ NAT Gateway │  │ Bastion │    │     │     │    │ NAT Gateway │                │   │
│   │   │             │  │         │    │     │     │    │             │                │   │
│   │   └─────────────┘  └─────────┘    │     │     │    └─────────────┘                │   │
│   │                                   │     │     │                                   │   │
│   └───────────────────────────────────┘     │     └───────────────────────────────────┘   │
│                                             │                                             │
│   ┌─────── Privat App Subnet 1 ───────┐     │     ┌─────── Privat App Subnet 2 ──────┐    │
│   │                                   │     ▼     │                                  │    │
│   │ ┌╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶┐ │    │
│   │ ╷ ┌──────────────────────────┐    │           │    ┌─────────────────────────┐ ╷ │    │
│   │ ╷ │                          │    │           │    │                         │ ╷ │    │
│   │ ╷ │     WordPress Instance   │    │    ASG    │    │   WordPress Instance    │ ╷ │    │
│   │ ╷ │                          │    │           │    │                         │ ╷ │    │
│   │ ╷ └──────────────────────────┘    │           │    └─────────────────────────┘ ╷ │    │
│   │ └╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶▲╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶┘ │    │
│   │                                   │     │     │                                  │    │
│   └───────────────────────────────────┘     │     └──────────────────────────────────┘    │
│                                             │                                             │
│   ┌─────── Privat Data Subnet 1 ──────┐     │     ┌────── Privat Data Subnet 2 ──────┐    │
│   │                                   │     │     │                                  │    │
│   │                                   │     │     │                                  │    │
│   │   ┌──────────────────────────┐    │     │     │    ┌─────────────────────────┐   │    │
│   │   │                          │◀─────────┘     │    │                         │   │    │
│   │   │      RDS Primary DB      │────────────────────▶│     RDS Standby DB      │   │    │
│   │   │                          │    │           │    │                         │   │    │
│   │   └──────────────────────────┘    │           │    └─────────────────────────┘   │    │
│   │                                   │           │                                  │    │
│   └───────────────────────────────────┘           └──────────────────────────────────┘    │
└───────────────────────────────────────────────────────────────────────────────────────────┘
```

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed
- AWS account and credentials configured
- Basic knowledge of AWS and Terraform

## Usage

1. Clone the repository:
    ```sh
    git clone https://github.com/yourusername/terraform-aws-wordpress.git
    cd terraform-aws-wordpress
    ```

2. Initialize Terraform:
    ```sh
    terraform init
    ```

3. Review and customize variables in `variables.tf` or create a `terraform.tfvars` file.

4. Plan and apply the configuration:
    ```sh
    terraform plan
    terraform apply
    ```

5. After deployment, note the output for the WordPress site URL.


## Cleanup

To destroy all resources created by this project:
```sh
terraform destroy
```

## License

This project is licensed under the MIT License.
