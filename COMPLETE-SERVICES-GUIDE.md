# Complete AWS Services Guide - Terraform Boilerplate

## 📋 Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [VPC - Virtual Private Cloud](#vpc---virtual-private-cloud)
3. [EC2 - Elastic Compute Cloud](#ec2---elastic-compute-cloud)
4. [Security Groups](#security-groups)
5. [RDS - Relational Database Service](#rds---relational-database-service)
6. [S3 - Simple Storage Service](#s3---simple-storage-service)
7. [ECR - Elastic Container Registry](#ecr---elastic-container-registry)
8. [ECS - Elastic Container Service](#ecs---elastic-container-service)
9. [EKS - Elastic Kubernetes Service](#eks---elastic-kubernetes-service)
10. [Deployment Guide](#deployment-guide)
11. [Access & Security](#access--security)
12. [Troubleshooting](#troubleshooting)

---

## Architecture Overview

### 🏗️ Complete Infrastructure Layout
```
Internet
    ↓
Internet Gateway
    ↓
┌─────────────────────────────────────────────────────────┐
│                  PUBLIC SUBNETS                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐  │
│  │ Web Servers │  │ Bastion     │  │ Load Balancer   │  │
│  │ (HTTP/HTTPS)│  │ Host (SSH)  │  │ (ALB)           │  │
│  └─────────────┘  └─────────────┘  └─────────────────┘  │
└─────────────────────┬───────────────────────────────────┘
                      │ (NAT Gateway)
┌─────────────────────┴───────────────────────────────────┐
│                  PRIVATE SUBNETS                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐  │
│  │ App Servers │  │ Private     │  │ ECS/EKS         │  │
│  │             │  │ Instance    │  │ Containers      │  │
│  └─────────────┘  └─────────────┘  └─────────────────┘  │
│                                                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐  │
│  │ RDS MySQL   │  │ ECR         │  │ S3 Bucket       │  │
│  │ Database    │  │ Registry    │  │ (Storage)       │  │
│  └─────────────┘  └─────────────┘  └─────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### 🎯 Key Architecture Benefits
- **Multi-AZ High Availability**: Resources across 2+ availability zones
- **Security Layers**: Public/private subnet isolation
- **Scalable Design**: Auto-scaling containers and databases
- **Secure Access**: Bastion host for private resource access

---

## VPC - Virtual Private Cloud

### 📋 Overview
Creates the foundational network infrastructure with public and private subnets across multiple availability zones.

### ✨ Key Features
- **Network Isolation**: Separate public and private subnets
- **Multi-AZ Design**: High availability across zones
- **Internet Connectivity**: Internet Gateway + NAT Gateways
- **DNS Support**: Internal DNS resolution enabled

### 🔧 Configuration
```hcl
vpc_cidr           = "10.0.0.0/16"      # 65,536 IP addresses
availability_zones = ["us-west-2a", "us-west-2b"]
public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets    = ["10.0.10.0/24", "10.0.20.0/24"]
```

### 📊 Resources Created
- **1 VPC** with DNS hostnames enabled
- **4 Subnets** (2 public + 2 private)
- **1 Internet Gateway** for public access
- **2 NAT Gateways** for private outbound access
- **Route Tables** with proper routing

### 🛡️ Security Features
- Private subnets have no direct internet access
- Controlled routing through NAT gateways
- Support for VPC Flow Logs (optional)

---

## EC2 - Elastic Compute Cloud

### 📋 Overview
Provides virtual machines in both public and private subnets with different access patterns and security configurations.

### ✨ Key Features
- **Multi-Tier Deployment**: Web, app, and private instances
- **Bastion Host**: Secure jump server for private access
- **Auto-Configuration**: User data scripts for setup
- **Flexible Sizing**: Configurable instance types

### 🔧 Instance Types

#### **Web Servers (Public Subnets)**
- **Purpose**: Internet-facing web applications
- **Access**: Direct internet access via Internet Gateway
- **Security**: HTTP/HTTPS + SSH access
- **Configuration**: Apache/Nginx pre-installed

#### **App Servers (Private Subnets)**
- **Purpose**: Application logic and processing
- **Access**: Only via bastion host
- **Security**: SSH from bastion only
- **Configuration**: Java runtime pre-installed

#### **Bastion Host (Public Subnet)**
- **Purpose**: Secure access to private instances
- **Access**: SSH from internet (configurable IP ranges)
- **Security**: SSH only, no other services
- **Configuration**: Minimal setup with monitoring tools

#### **Private Instance (Private Subnet)**
- **Purpose**: Secure internal operations
- **Access**: Only via bastion host
- **Security**: No public IP, bastion-only SSH
- **Configuration**: Database clients and tools

### 📊 Configuration Variables
```hcl
instance_type         = "t3.micro"    # Web/App instances
bastion_instance_type = "t3.micro"    # Bastion host
private_instance_type = "t3.micro"    # Private instance
key_name              = "my-key-pair" # SSH key pair
```

### 🚀 Use Cases
- **Web Applications**: Frontend in public, backend in private
- **Development**: Secure development environment via bastion
- **Database Administration**: Private instance with DB tools
- **Internal Services**: Private processing and monitoring

---

## Security Groups

### 📋 Overview
Network-level firewall rules that control traffic to and from AWS resources using least privilege principles.

### ✨ Key Features
- **Stateful Firewall**: Automatic return traffic handling
- **Least Privilege**: Minimal required access only
- **Service-Specific**: Dedicated security groups per service
- **Reference-Based**: Security groups can reference each other

### 🔧 Security Group Types

#### **Web Security Group**
```
Inbound:  HTTP (80), HTTPS (443), SSH (22) from 0.0.0.0/0
Outbound: All traffic to 0.0.0.0/0
Purpose:  Internet-facing web servers
```

#### **App Security Group**
```
Inbound:  App Port (8080) from Web SG, SSH from Bastion SG
Outbound: All traffic to 0.0.0.0/0
Purpose:  Application servers in private subnets
```

#### **Database Security Group**
```
Inbound:  MySQL (3306), PostgreSQL (5432) from App SG
Outbound: All traffic to 0.0.0.0/0
Purpose:  RDS database instances
```

#### **Bastion Security Group**
```
Inbound:  SSH (22) from 0.0.0.0/0 (configurable)
Outbound: All traffic to 0.0.0.0/0
Purpose:  Jump server for private access
```

#### **Private Security Group**
```
Inbound:  SSH (22) from Bastion SG only
Outbound: All traffic to 0.0.0.0/0
Purpose:  Private instances with no public access
```

#### **ALB Security Group**
```
Inbound:  HTTP (80), HTTPS (443) from 0.0.0.0/0
Outbound: All traffic to 0.0.0.0/0
Purpose:  Application Load Balancer
```

#### **ECS Security Group**
```
Inbound:  HTTP (80) from ALB SG only
Outbound: All traffic to 0.0.0.0/0
Purpose:  ECS Fargate containers
```

### 🛡️ Security Best Practices
- **No Direct Database Access**: Database only accessible from app tier
- **Bastion-Only Private Access**: Private instances only via bastion
- **Service Isolation**: Each service has dedicated security group
- **Minimal Ports**: Only required ports are opened

---

## RDS - Relational Database Service

### 📋 Overview
Managed MySQL database service deployed in private subnets with encryption, backups, and high availability features.

### ✨ Key Features
- **Managed Service**: Automated patching and maintenance
- **High Availability**: Multi-AZ deployment option
- **Security**: Encryption at rest and in transit
- **Backup & Recovery**: Automated backups with point-in-time recovery

### 🔧 Configuration
```hcl
db_instance_class = "db.t3.micro"     # Instance size
db_name          = "myappdb"          # Database name
db_username      = "admin"            # Master username
db_password      = "SecurePass123!"   # Master password (sensitive)
```

### 📊 Database Specifications
- **Engine**: MySQL 8.0
- **Storage**: 20GB GP2 (auto-scaling to 100GB)
- **Encryption**: Enabled at rest
- **Backup**: 7-day retention period
- **Maintenance**: Automated during maintenance window

### 🛡️ Security Features
- **Private Subnets**: No direct internet access
- **Security Groups**: Access only from application tier
- **Encryption**: Data encrypted at rest and in transit
- **Subnet Groups**: Database deployed across multiple AZs

### 🚀 Access Methods
```bash
# Via Bastion Host (SSH Tunnel)
ssh -i key.pem -L 3306:db-endpoint:3306 ec2-user@bastion-ip
mysql -h localhost -P 3306 -u admin -p

# Via Private Instance
ssh bastion-ip
ssh private-instance-ip
mysql -h db-endpoint -u admin -p
```

---

## S3 - Simple Storage Service

### 📋 Overview
Secure object storage bucket with encryption, versioning, and public access blocking for application data and backups.

### ✨ Key Features
- **Unlimited Storage**: Scalable object storage
- **Security**: Encryption and access controls
- **Versioning**: Object version management
- **Lifecycle Policies**: Automated data management

### 🔧 Configuration
- **Bucket Naming**: `{project-name}-{environment}-{random-suffix}`
- **Versioning**: Enabled for data protection
- **Encryption**: AES256 server-side encryption
- **Public Access**: Completely blocked

### 📊 Security Features
```hcl
# Encryption Configuration
server_side_encryption = "AES256"

# Public Access Block
block_public_acls       = true
block_public_policy     = true
ignore_public_acls      = true
restrict_public_buckets = true

# Versioning
versioning_status = "Enabled"
```

### 🚀 Use Cases
- **Application Data**: Store application files and assets
- **Database Backups**: Automated RDS backup storage
- **Log Storage**: Application and system logs
- **Static Content**: Web application static assets

### 🔧 Access Methods
- **IAM Roles**: Service-based access (recommended)
- **Bucket Policies**: Fine-grained access control
- **VPC Endpoints**: Private access from VPC (optional)

---

## ECR - Elastic Container Registry

### 📋 Overview
Private Docker container registry for storing and managing container images with security scanning and lifecycle policies.

### ✨ Key Features
- **Private Registry**: Secure container image storage
- **Image Scanning**: Vulnerability scanning on push
- **Lifecycle Policies**: Automated image cleanup
- **Integration**: Native integration with ECS/EKS

### 🔧 Configuration
```hcl
repository_name = "{project-name}-{environment}"
image_tag_mutability = "MUTABLE"
scan_on_push = true
```

### 📊 Lifecycle Policies
```json
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Keep last 10 tagged images",
      "selection": {
        "tagStatus": "tagged",
        "tagPrefixList": ["v"],
        "countType": "imageCountMoreThan",
        "countNumber": 10
      },
      "action": { "type": "expire" }
    },
    {
      "rulePriority": 2,
      "description": "Delete untagged images older than 1 day",
      "selection": {
        "tagStatus": "untagged",
        "countType": "sinceImagePushed",
        "countUnit": "days",
        "countNumber": 1
      },
      "action": { "type": "expire" }
    }
  ]
}
```

### 🚀 Usage Workflow
```bash
# Build and tag image
docker build -t my-app .
docker tag my-app:latest {account}.dkr.ecr.{region}.amazonaws.com/{repo}:latest

# Push to ECR
aws ecr get-login-password --region {region} | docker login --username AWS --password-stdin {account}.dkr.ecr.{region}.amazonaws.com
docker push {account}.dkr.ecr.{region}.amazonaws.com/{repo}:latest
```

---

## ECS - Elastic Container Service

### 📋 Overview
Serverless container orchestration service using AWS Fargate with Application Load Balancer integration and auto-scaling capabilities.

### ✨ Key Features
- **Serverless Containers**: No EC2 management required
- **Auto Scaling**: Automatic scaling based on metrics
- **Load Balancing**: Integrated Application Load Balancer
- **Service Discovery**: Built-in service discovery
- **Health Checks**: Automated health monitoring

### 🔧 Configuration
```hcl
# Task Configuration
task_cpu          = "256"    # CPU units (0.25 vCPU)
task_memory       = "512"    # Memory in MB
container_port    = 80       # Application port
desired_count     = 2        # Number of tasks

# Service Configuration
launch_type = "FARGATE"
network_mode = "awsvpc"
```

### 📊 Architecture Components
- **ECS Cluster**: Container orchestration cluster
- **Task Definition**: Container specification
- **ECS Service**: Manages desired task count
- **Application Load Balancer**: Distributes traffic
- **Target Groups**: Health check and routing
- **CloudWatch Logs**: Centralized logging

### 🛡️ Security Features
- **Private Subnets**: Containers run in private subnets
- **Security Groups**: Network-level access control
- **IAM Roles**: Task and execution roles
- **No Public IPs**: Containers not directly accessible

### 🚀 Deployment Process
1. **Build Image**: Create Docker image
2. **Push to ECR**: Store in container registry
3. **Update Task Definition**: Reference new image
4. **Deploy Service**: ECS handles rolling deployment

### 📈 Monitoring
- **CloudWatch Metrics**: CPU, memory, network usage
- **Application Logs**: Centralized in CloudWatch Logs
- **Health Checks**: ALB health check monitoring
- **Service Events**: ECS service event tracking

---

## EKS - Elastic Kubernetes Service

### 📋 Overview
Managed Kubernetes service with worker nodes in private subnets, providing full Kubernetes API compatibility and integration with AWS services.

### ✨ Key Features
- **Managed Control Plane**: AWS manages Kubernetes masters
- **Auto Scaling**: Cluster and pod auto-scaling
- **AWS Integration**: Native integration with AWS services
- **Security**: IAM integration and network policies
- **Monitoring**: CloudWatch and Kubernetes metrics

### 🔧 Configuration
```hcl
# Cluster Configuration
kubernetes_version = "1.28"
endpoint_private_access = true
endpoint_public_access = true

# Node Group Configuration
node_instance_type = "t3.medium"
desired_nodes = 2
min_nodes = 1
max_nodes = 4
```

### 📊 Architecture Components
- **EKS Cluster**: Managed Kubernetes control plane
- **Node Groups**: Managed worker nodes
- **VPC Integration**: Nodes in private subnets
- **IAM Roles**: Cluster and node group roles
- **CloudWatch Logging**: Cluster audit and API logs

### 🛡️ Security Features
- **Private Worker Nodes**: Nodes in private subnets only
- **IAM Integration**: AWS IAM for authentication
- **Network Policies**: Kubernetes network policies
- **Encryption**: Secrets encryption at rest
- **Security Groups**: Node-level network controls

### 🚀 Deployment Workflow
```bash
# Configure kubectl
aws eks update-kubeconfig --region {region} --name {cluster-name}

# Deploy applications
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

# Check status
kubectl get pods
kubectl get services
```

### 📈 Scaling Options
- **Horizontal Pod Autoscaler**: Scale pods based on metrics
- **Vertical Pod Autoscaler**: Adjust pod resource requests
- **Cluster Autoscaler**: Scale worker nodes automatically
- **Manual Scaling**: kubectl scale commands

---

## Deployment Guide

### 🚀 Quick Start Deployment

#### **1. Prerequisites**
```bash
# Install required tools
terraform --version  # >= 1.0
aws --version        # AWS CLI configured
```

#### **2. Configuration**
```bash
# Clone and configure
cd terraform-boilerplate
cp terraform.tfvars.example terraform.tfvars

# Edit configuration
vim terraform.tfvars
```

#### **3. Deploy Infrastructure**
```bash
# Initialize Terraform
terraform init

# Review plan
terraform plan

# Deploy infrastructure
terraform apply
```

#### **4. Verify Deployment**
```bash
# Check outputs
terraform output

# Test bastion access
ssh -i key.pem ec2-user@$(terraform output -raw bastion_public_ip)
```

### 🔧 Configuration Options

#### **Choose Container Service**
```hcl
# Option 1: Use ECS (comment out EKS module in main.tf)
# Option 2: Use EKS (comment out ECS module in main.tf)
# Option 3: Use both (for comparison/migration)
```

#### **Environment-Specific Settings**
```hcl
# Development
instance_type = "t3.micro"
desired_nodes = 1
db_instance_class = "db.t3.micro"

# Production
instance_type = "t3.large"
desired_nodes = 3
db_instance_class = "db.r5.large"
```

---

## Access & Security

### 🔐 Bastion Host Access

#### **Connect to Bastion**
```bash
ssh -i your-key.pem ec2-user@<bastion-public-ip>
```

#### **Access Private Instances**
```bash
# From bastion, connect to private resources
ssh ec2-user@<private-instance-ip>
ssh ec2-user@<app-server-ip>
```

#### **SSH Agent Forwarding (Recommended)**
```bash
# Add key to SSH agent
ssh-add your-key.pem

# Connect with agent forwarding
ssh -A ec2-user@<bastion-public-ip>

# Now you can SSH to private instances without copying keys
ssh ec2-user@<private-instance-ip>
```

#### **Database Access via SSH Tunnel**
```bash
# Create SSH tunnel for database
ssh -i key.pem -L 3306:<db-endpoint>:3306 ec2-user@<bastion-public-ip>

# Connect to database via localhost
mysql -h localhost -P 3306 -u admin -p
```

### 🛡️ Security Best Practices

#### **Network Security**
- All databases in private subnets
- Bastion host as single entry point
- Security groups with least privilege
- No direct internet access to private resources

#### **Access Control**
- SSH key-based authentication only
- Regular key rotation
- Restrict bastion access to specific IP ranges
- Use AWS Systems Manager Session Manager as alternative

#### **Data Protection**
- Encryption at rest for RDS and S3
- SSL/TLS for data in transit
- Regular automated backups
- VPC Flow Logs for network monitoring

---

## Troubleshooting

### 🔍 Common Issues & Solutions

#### **Terraform Deployment Issues**
```bash
# Issue: Provider authentication
Solution: aws configure

# Issue: Resource conflicts
Solution: terraform import <resource> <id>

# Issue: State lock
Solution: terraform force-unlock <lock-id>
```

#### **Network Connectivity Issues**
```bash
# Issue: Can't reach internet from private subnet
Check: NAT Gateway status and route tables
Command: aws ec2 describe-nat-gateways

# Issue: Can't SSH to instances
Check: Security groups and key pairs
Command: aws ec2 describe-security-groups
```

#### **Container Service Issues**
```bash
# ECS Task not starting
Check: Task definition, ECR permissions, CloudWatch logs
Command: aws ecs describe-tasks --cluster <cluster> --tasks <task-id>

# EKS Node not joining
Check: IAM roles, security groups, subnet routing
Command: kubectl get nodes
```

#### **Database Connection Issues**
```bash
# Can't connect to RDS
Check: Security groups, subnet groups, endpoint
Command: aws rds describe-db-instances

# Connection timeout
Check: VPC routing, NAT Gateway, security groups
```

### 📊 Monitoring Commands

#### **Infrastructure Health**
```bash
# Check all resources
terraform show

# Verify outputs
terraform output

# Check AWS resources
aws ec2 describe-instances
aws rds describe-db-instances
aws ecs list-clusters
aws eks list-clusters
```

#### **Application Health**
```bash
# ECS service status
aws ecs describe-services --cluster <cluster> --services <service>

# EKS cluster status
kubectl get pods --all-namespaces
kubectl get services

# Load balancer health
aws elbv2 describe-target-health --target-group-arn <arn>
```

### 🚨 Emergency Procedures

#### **Scale Down for Cost Savings**
```bash
# Stop ECS services
aws ecs update-service --cluster <cluster> --service <service> --desired-count 0

# Scale down EKS nodes
aws eks update-nodegroup-config --cluster-name <cluster> --nodegroup-name <nodegroup> --scaling-config minSize=0,maxSize=0,desiredSize=0
```

#### **Backup Critical Data**
```bash
# Manual RDS snapshot
aws rds create-db-snapshot --db-instance-identifier <db-id> --db-snapshot-identifier manual-backup-$(date +%Y%m%d)

# S3 backup
aws s3 sync s3://source-bucket s3://backup-bucket
```

---

## 📞 Support & Resources

### **AWS Documentation**
- [VPC User Guide](https://docs.aws.amazon.com/vpc/)
- [EC2 User Guide](https://docs.aws.amazon.com/ec2/)
- [ECS Developer Guide](https://docs.aws.amazon.com/ecs/)
- [EKS User Guide](https://docs.aws.amazon.com/eks/)
- [RDS User Guide](https://docs.aws.amazon.com/rds/)

### **Terraform Resources**
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)

### **Cost Optimization**
- Use AWS Cost Explorer for cost analysis
- Set up billing alerts
- Regular review of unused resources
- Consider Reserved Instances for production

---

*This guide covers all services in the Terraform boilerplate. For specific issues, refer to the troubleshooting section or AWS documentation.*