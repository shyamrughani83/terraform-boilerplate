# VPC (Virtual Private Cloud)

## 📋 Overview

The VPC module creates a complete networking foundation for your AWS infrastructure with public and private subnets, internet connectivity, and NAT gateways.

## 🏗️ Architecture

```
VPC (10.0.0.0/16)
├── Public Subnets
│   ├── 10.0.1.0/24 (AZ-1)
│   └── 10.0.2.0/24 (AZ-2)
├── Private Subnets
│   ├── 10.0.10.0/24 (AZ-1)
│   └── 10.0.20.0/24 (AZ-2)
├── Internet Gateway
├── NAT Gateways (2)
└── Route Tables
```

## ✨ Key Features

### **Multi-AZ Design**
- **High Availability**: Resources distributed across multiple availability zones
- **Fault Tolerance**: Automatic failover capabilities
- **Load Distribution**: Even traffic distribution across zones

### **Network Segmentation**
- **Public Subnets**: Internet-accessible resources (web servers, load balancers)
- **Private Subnets**: Internal resources (app servers, databases)
- **Isolated Communication**: Secure internal networking

### **Internet Connectivity**
- **Internet Gateway**: Direct internet access for public subnets
- **NAT Gateways**: Secure outbound internet access for private subnets
- **Elastic IPs**: Static IP addresses for NAT gateways

### **DNS Support**
- **DNS Hostnames**: Enabled for all instances
- **DNS Resolution**: Internal DNS resolution within VPC

## 🔧 Configuration

### **Default Settings**
```hcl
vpc_cidr           = "10.0.0.0/16"
availability_zones = ["us-west-2a", "us-west-2b"]
public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets    = ["10.0.10.0/24", "10.0.20.0/24"]
```

### **Customizable Variables**
- **VPC CIDR**: Network address range
- **Subnet CIDRs**: Individual subnet address ranges
- **Availability Zones**: Target AZs for deployment
- **Tags**: Resource labeling and organization

## 📊 Resources Created

### **Core Networking**
- **1 VPC**: Main virtual network
- **4 Subnets**: 2 public + 2 private
- **1 Internet Gateway**: Public internet access
- **2 NAT Gateways**: Private internet access
- **2 Elastic IPs**: For NAT gateways

### **Routing**
- **1 Public Route Table**: Routes to Internet Gateway
- **2 Private Route Tables**: Routes to respective NAT Gateways
- **Route Table Associations**: Subnet-to-route-table mappings

## 🛡️ Security Features

### **Network Isolation**
- **Private Subnets**: No direct internet access
- **Controlled Routing**: Explicit route table management
- **Subnet Separation**: Logical separation of tiers

### **Access Control**
- **Security Groups**: Instance-level firewall rules
- **NACLs**: Subnet-level network access control
- **Flow Logs**: Network traffic monitoring (optional)

## 📈 Scalability

### **Subnet Expansion**
- **Additional Subnets**: Easy addition of more subnets
- **CIDR Expansion**: VPC CIDR can be extended
- **Multi-Region**: Template reusable across regions

### **Performance**
- **Enhanced Networking**: Support for SR-IOV and enhanced networking
- **Placement Groups**: Optimized instance placement
- **Dedicated Tenancy**: Hardware isolation (optional)

## 🔍 Monitoring

### **CloudWatch Metrics**
- **VPC Flow Logs**: Network traffic analysis
- **NAT Gateway Metrics**: Bandwidth and connection monitoring
- **Route Table Monitoring**: Route propagation tracking

### **Cost Optimization**
- **NAT Gateway Costs**: Monitor data transfer costs
- **Elastic IP Costs**: Track unused Elastic IPs
- **Cross-AZ Traffic**: Monitor inter-AZ data transfer

## 🚀 Use Cases

### **Web Applications**
- **Frontend**: Web servers in public subnets
- **Backend**: Application servers in private subnets
- **Database**: RDS instances in private subnets

### **Microservices**
- **API Gateway**: Public subnet for external access
- **Services**: Private subnets for internal services
- **Data Layer**: Private subnets for databases and caches

### **Development Environments**
- **Bastion Hosts**: Public subnet for secure access
- **Development Servers**: Private subnets for development
- **Testing Infrastructure**: Isolated private environments

## 🔧 Customization Examples

### **Single AZ Deployment**
```hcl
availability_zones = ["us-west-2a"]
public_subnets     = ["10.0.1.0/24"]
private_subnets    = ["10.0.10.0/24"]
```

### **Large Network**
```hcl
vpc_cidr        = "10.0.0.0/8"
public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnets = ["10.1.0.0/24", "10.2.0.0/24", "10.3.0.0/24"]
```

### **Multi-Tier Architecture**
```hcl
# Web tier
public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
# App tier
private_subnets = ["10.0.10.0/24", "10.0.20.0/24"]
# Database tier (additional private subnets)
database_subnets = ["10.0.100.0/24", "10.0.200.0/24"]
```

## 📋 Outputs

### **Network Information**
- **vpc_id**: VPC identifier
- **vpc_cidr_block**: VPC CIDR range
- **public_subnet_ids**: List of public subnet IDs
- **private_subnet_ids**: List of private subnet IDs

### **Gateway Information**
- **internet_gateway_id**: Internet Gateway ID
- **nat_gateway_ids**: List of NAT Gateway IDs
- **public_route_table_id**: Public route table ID
- **private_route_table_ids**: List of private route table IDs

## 🔍 Troubleshooting

### **Common Issues**
1. **No Internet Access**: Check route tables and security groups
2. **Cross-Subnet Communication**: Verify security group rules
3. **NAT Gateway Issues**: Check Elastic IP allocation
4. **DNS Resolution**: Ensure DNS hostnames are enabled

### **Validation Commands**
```bash
# Check VPC configuration
aws ec2 describe-vpcs --vpc-ids <vpc-id>

# Verify route tables
aws ec2 describe-route-tables --filters "Name=vpc-id,Values=<vpc-id>"

# Check NAT Gateway status
aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=<vpc-id>"
```