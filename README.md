# Terraform AWS Infrastructure Boilerplate

A production-ready, comprehensive Terraform boilerplate for AWS infrastructure that includes all essential services with security best practices and container orchestration capabilities.

## 🏗️ Complete Infrastructure

```
Internet → Internet Gateway → Public Subnets → Private Subnets
    ↓           ↓                    ↓              ↓
  Users    Load Balancer      Bastion Host    App Servers
           Web Servers        Private EC2     Containers
                                              Database
```

### 🚀 Services Included

| Service | Purpose | Key Features |
|---------|---------|-------------|
| **VPC** | Network Foundation | Multi-AZ, Public/Private Subnets, NAT Gateways |
| **EC2** | Virtual Machines | Web, App, Bastion, Private instances |
| **RDS** | Managed Database | MySQL 8.0, Encryption, Automated Backups |
| **S3** | Object Storage | Encryption, Versioning, Public Access Blocked |
| **ECR** | Container Registry | Image Scanning, Lifecycle Policies |
| **ECS** | Container Service | Fargate, Auto-scaling, Load Balancer |
| **EKS** | Kubernetes Service | Managed Control Plane, Auto-scaling Nodes |
| **Security Groups** | Network Security | 7 Dedicated Groups, Least Privilege |
| **ALB** | Load Balancer | Application Load Balancer for containers |
| **Bastion** | Secure Access | Jump server for private resources |

## 📋 Prerequisites

- **AWS CLI** configured with appropriate credentials
- **Terraform** >= 1.0 installed
- **AWS Key Pair** for EC2 instances
- **Docker** (optional, for container services)
- **kubectl** (optional, for EKS management)

## 🚀 Quick Start

### 1. **Configure**
```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

### 2. **Choose Container Service** (Optional)
```bash
# Option A: Use ECS (comment out EKS module in main.tf)
# Option B: Use EKS (comment out ECS module in main.tf) 
# Option C: Deploy both for comparison
```

### 3. **Deploy**
```bash
terraform init
terraform plan
terraform apply
```

### 4. **Access**
```bash
# Get bastion IP
terraform output bastion_public_ip

# SSH to bastion
ssh -i your-key.pem ec2-user@<bastion-ip>
```

### 5. **Clean Up**
```bash
terraform destroy
```

## ⚙️ Configuration

### **Required Variables**
```hcl
project_name = "my-awesome-project"
environment  = "dev"
aws_region   = "us-west-2"
key_name     = "my-key-pair"
db_password  = "SecurePassword123!"
```

### **Container Services** (Choose One)
```hcl
# ECS Configuration
ecs_task_cpu       = "256"
ecs_task_memory    = "512"
ecs_desired_count  = 2

# EKS Configuration
kubernetes_version     = "1.28"
eks_node_instance_type = "t3.medium"
eks_desired_nodes      = 2
```

### **Instance Sizing**
```hcl
# Development
instance_type = "t3.micro"
db_instance_class = "db.t3.micro"

# Production
instance_type = "t3.large"
db_instance_class = "db.r5.large"
```

## 📁 Module Structure

```
modules/
├── vpc/              # VPC, subnets, NAT, IGW, routing
├── security-groups/  # 7 security groups with least privilege
├── ec2/             # Web, app, bastion, private instances
├── rds/             # MySQL database with encryption
├── s3/              # Secure S3 bucket with versioning
├── ecr/             # Container registry with scanning
├── ecs/             # Fargate cluster with ALB integration
└── eks/             # Kubernetes cluster with managed nodes
```

## 📚 **Complete Documentation**

### **📖 [COMPLETE SERVICES GUIDE](COMPLETE-SERVICES-GUIDE.md)**
**→ Comprehensive guide covering all services, configurations, and usage**

### **🔐 [Bastion Access Guide](bastion-access.md)**
**→ Secure access to private instances via bastion host**

### **📋 Quick Reference**
- **Architecture**: Visual diagrams and component overview
- **All Services**: VPC, EC2, RDS, S3, ECR, ECS, EKS details
- **Security**: 7 security groups and access patterns
- **Deployment**: Step-by-step deployment guide
- **Troubleshooting**: Common issues and solutions
- **Best Practices**: AWS security and optimization tips

## 📊 Outputs

### **Network Information**
- VPC ID and subnet IDs
- Internet Gateway and NAT Gateway IDs

### **Compute Resources**
- **Bastion Host**: Public IP for secure access
- **Web Servers**: Instance IDs and IPs
- **App Servers**: Private instance IDs and IPs
- **Private Instance**: Secure instance IP (bastion-only access)

### **Container Services**
- **ECR Repository**: Container registry URL
- **ECS Cluster**: Service name and load balancer DNS
- **EKS Cluster**: Cluster endpoint and certificate data

### **Storage & Database**
- **RDS Endpoint**: Database connection string (sensitive)
- **S3 Bucket**: Bucket name and ARN

## 🛡️ Security Features

### **Network Security**
- **Multi-tier Architecture**: Public/private subnet isolation
- **Bastion Host**: Single secure entry point for private access
- **7 Security Groups**: Least privilege network access
- **No Direct Database Access**: Database only accessible from app tier

### **Data Protection**
- **RDS Encryption**: Database encryption at rest and in transit
- **S3 Security**: Encryption, versioning, public access blocked
- **Container Security**: ECR image scanning, private registries

### **Access Control**
- **SSH Key Authentication**: No password-based access
- **IAM Roles**: Service-specific permissions
- **Private Instances**: No public IP addresses
- **Controlled Routing**: Explicit route table management

## 🐳 Container Services

### **ECS (Elastic Container Service)**
```bash
# Serverless containers with Fargate
✅ No server management
✅ Integrated Application Load Balancer
✅ Auto-scaling based on metrics
✅ CloudWatch logging and monitoring
```

### **EKS (Elastic Kubernetes Service)**
```bash
# Managed Kubernetes cluster
✅ Full Kubernetes API compatibility
✅ Managed control plane
✅ Auto-scaling node groups
✅ AWS service integration
```

### **Usage Options**
- **Option 1**: Use ECS only (comment out EKS module)
- **Option 2**: Use EKS only (comment out ECS module)
- **Option 3**: Deploy both for comparison/migration

## 🔧 Customization

### **Adding New Services**
1. Create new module in `modules/`
2. Add module call in `main.tf`
3. Define variables in `variables.tf`
4. Add outputs in `outputs.tf`
5. Update security groups as needed

### **Environment Variations**
```hcl
# Development
instance_type = "t3.micro"
desired_nodes = 1
db_instance_class = "db.t3.micro"

# Staging
instance_type = "t3.small"
desired_nodes = 2
db_instance_class = "db.t3.small"

# Production
instance_type = "t3.large"
desired_nodes = 3
db_instance_class = "db.r5.large"
```

## 🎯 Use Cases

### **Web Applications**
- **Frontend**: Web servers in public subnets
- **Backend**: Application servers in private subnets
- **Database**: RDS MySQL in private subnets
- **Load Balancing**: ALB for high availability

### **Microservices Architecture**
- **Containers**: ECS Fargate or EKS for services
- **Service Discovery**: Built-in container orchestration
- **API Gateway**: Load balancer with path-based routing
- **Container Registry**: ECR for image management

### **Development Environment**
- **Secure Development**: Private instances via bastion
- **Database Administration**: SSH tunneling for DB access
- **Container Development**: ECR for image storage
- **Testing**: Isolated private environments

## 📈 Best Practices

### **Deployment**
- Always run `terraform plan` before `apply`
- Use remote state storage (S3 + DynamoDB)
- Implement separate environments (dev/staging/prod)
- Tag all resources consistently

### **Security**
- Regularly rotate SSH keys and passwords
- Review security group rules periodically
- Enable CloudTrail for audit logging
- Use AWS Config for compliance monitoring

### **Cost Optimization**
- Use appropriate instance sizes for workloads
- Implement auto-scaling for variable workloads
- Set up billing alerts and cost monitoring
- Regular cleanup of unused resources

## 🆘 Support

- **📖 [Complete Services Guide](COMPLETE-SERVICES-GUIDE.md)** - Detailed documentation
- **🔐 [Bastion Access Guide](bastion-access.md)** - Secure access instructions
- **🐛 Troubleshooting** - Check the Complete Services Guide
- **💡 Best Practices** - AWS optimization recommendations

## 📄 License

MIT License - Feel free to use, modify, and distribute as needed.