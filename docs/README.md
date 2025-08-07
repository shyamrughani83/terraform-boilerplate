# Terraform AWS Infrastructure Documentation

## 📚 Documentation Overview

This documentation provides comprehensive guides for all AWS services and components in the Terraform boilerplate.

## 📁 Documentation Structure

```
docs/
├── README.md                    # This file
├── architecture/
│   ├── overview.md             # High-level architecture
│   ├── network-design.md       # VPC and networking
│   └── security-model.md       # Security architecture
├── services/
│   ├── vpc.md                  # VPC configuration
│   ├── ec2.md                  # EC2 instances
│   ├── rds.md                  # Database service
│   ├── s3.md                   # Storage service
│   ├── ecr.md                  # Container registry
│   ├── ecs.md                  # Container service
│   ├── eks.md                  # Kubernetes service
│   └── security-groups.md      # Security groups
└── guides/
    ├── deployment.md           # Deployment guide
    ├── bastion-access.md       # Bastion host access
    ├── troubleshooting.md      # Common issues
    └── best-practices.md       # AWS best practices
```

## 🚀 Quick Start

1. **Architecture Overview**: Start with [architecture/overview.md](architecture/overview.md)
2. **Deployment**: Follow [guides/deployment.md](guides/deployment.md)
3. **Service Configuration**: Check individual service docs in [services/](services/)
4. **Access & Security**: Read [guides/bastion-access.md](guides/bastion-access.md)

## 🔧 Service Documentation

| Service | Description | Documentation |
|---------|-------------|---------------|
| **VPC** | Virtual Private Cloud | [services/vpc.md](services/vpc.md) |
| **EC2** | Virtual Machines | [services/ec2.md](services/ec2.md) |
| **RDS** | Managed Database | [services/rds.md](services/rds.md) |
| **S3** | Object Storage | [services/s3.md](services/s3.md) |
| **ECR** | Container Registry | [services/ecr.md](services/ecr.md) |
| **ECS** | Container Service | [services/ecs.md](services/ecs.md) |
| **EKS** | Kubernetes Service | [services/eks.md](services/eks.md) |
| **Security Groups** | Network Security | [services/security-groups.md](services/security-groups.md) |

## 📖 Guides

- **[Deployment Guide](guides/deployment.md)** - Step-by-step deployment
- **[Bastion Access](guides/bastion-access.md)** - Secure server access
- **[Troubleshooting](guides/troubleshooting.md)** - Common issues and solutions
- **[Best Practices](guides/best-practices.md)** - AWS security and optimization

## 🏗️ Architecture

- **[Overview](architecture/overview.md)** - Complete system architecture
- **[Network Design](architecture/network-design.md)** - VPC and subnets
- **[Security Model](architecture/security-model.md)** - Security implementation

## 💡 Need Help?

- Check [troubleshooting.md](guides/troubleshooting.md) for common issues
- Review [best-practices.md](guides/best-practices.md) for optimization tips
- Refer to individual service documentation for specific configurations