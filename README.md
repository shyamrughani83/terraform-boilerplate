# Terraform AWS Infrastructure Boilerplate

A comprehensive Terraform boilerplate for AWS infrastructure that includes VPC, EC2, RDS, S3, and Security Groups modules.

## Architecture

This boilerplate creates:
- **VPC** with public and private subnets across multiple AZs
- **Security Groups** for web, application, database, ALB, and ECS tiers
- **EC2 instances** in both public (web) and private (app) subnets
- **RDS MySQL database** in private subnets
- **S3 bucket** with encryption and versioning
- **ECR repository** for container images
- **ECS cluster** with Fargate and Application Load Balancer
- **EKS cluster** with managed node groups

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0 installed
- An AWS key pair for EC2 instances

## Quick Start

1. **Clone and configure:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

2. **Initialize and deploy:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

3. **Clean up:**
   ```bash
   terraform destroy
   ```

## Configuration

### Required Variables

Edit `terraform.tfvars`:

```hcl
project_name = "my-project"
environment  = "dev"
aws_region   = "us-west-2"
key_name     = "my-key-pair"
db_password  = "SecurePassword123!"
```

### Optional Customization

- **VPC CIDR**: Default `10.0.0.0/16`
- **Instance Types**: Default `t3.micro`
- **Database**: Default MySQL 8.0 on `db.t3.micro`

## Module Structure

```
modules/
├── vpc/              # VPC, subnets, NAT, IGW
├── security-groups/  # Security groups for all tiers
├── ec2/             # Web and app instances
├── rds/             # MySQL database
├── s3/              # S3 bucket with security
├── ecr/             # Container registry
├── ecs/             # ECS Fargate cluster with ALB
└── eks/             # EKS cluster with managed nodes
```

## Outputs

After deployment, you'll get:
- VPC and subnet IDs
- Instance IDs and IP addresses
- Database endpoint (sensitive)
- S3 bucket name and ARN
- ECR repository URL
- ECS cluster name and load balancer DNS
- EKS cluster name and endpoint

## Security Features

- Private subnets for database and app tiers
- Security groups with least privilege access
- S3 bucket encryption and public access blocking
- RDS encryption at rest

## Container Services

**Choose ECS OR EKS** (not both):

### ECS (Fargate)
- Serverless containers
- Integrated with ALB
- Auto-scaling enabled
- CloudWatch logging

### EKS (Kubernetes)
- Managed Kubernetes
- Worker nodes in private subnets
- Auto-scaling node groups
- CloudWatch logging

**To use only one:**
Comment out the unwanted module in `main.tf`

## Customization

To add new resources:
1. Create a new module in `modules/`
2. Add module call in `main.tf`
3. Add variables in `variables.tf`
4. Add outputs in `outputs.tf`

## Best Practices

- Always use `terraform plan` before `apply`
- Store state remotely (S3 + DynamoDB)
- Use separate environments (dev/staging/prod)
- Review security group rules regularly
- Enable CloudTrail and monitoring

## License

MIT License - feel free to use and modify as needed.