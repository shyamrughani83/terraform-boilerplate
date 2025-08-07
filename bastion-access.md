# Bastion Host Access Guide

## Overview
The bastion host provides secure SSH access to private instances in your infrastructure.

## Connecting to Private Instances

### 1. Connect to Bastion Host
```bash
ssh -i your-key.pem ec2-user@<bastion-public-ip>
```

### 2. From Bastion, Connect to Private Instances
```bash
# Connect to dedicated private instance
ssh ec2-user@<private-instance-ip>

# Connect to app instances
ssh ec2-user@<app-private-ip>

# Connect to database (if SSH enabled)
ssh ec2-user@<db-private-ip>
```

### 3. SSH Agent Forwarding (Recommended)
```bash
# Add key to SSH agent
ssh-add your-key.pem

# Connect with agent forwarding
ssh -A ec2-user@<bastion-public-ip>

# Now you can SSH to private instances without copying keys
ssh ec2-user@<app-private-ip>
```

### 4. SSH Tunneling for Services
```bash
# Create tunnel for database access
ssh -i your-key.pem -L 3306:<db-endpoint>:3306 ec2-user@<bastion-public-ip>

# Create tunnel via private instance for additional services
ssh -i your-key.pem -L 8080:<private-instance-ip>:8080 ec2-user@<bastion-public-ip>

# Now connect to database via localhost:3306
mysql -h localhost -P 3306 -u admin -p
```

## Security Best Practices

1. **Restrict Bastion Access**: Update security group to allow SSH only from your IP
2. **Use SSH Keys**: Never use password authentication
3. **Regular Updates**: Keep bastion host updated with security patches
4. **Monitoring**: Enable CloudWatch logging for SSH access
5. **Session Manager**: Consider using AWS Systems Manager Session Manager as alternative

## Troubleshooting

### Connection Issues
- Verify security group allows SSH (port 22)
- Check key pair permissions: `chmod 400 your-key.pem`
- Ensure bastion host is in public subnet
- Verify route table has internet gateway route

### Private Instance Access
- Confirm app security group allows SSH from bastion security group
- Verify private instances are in private subnets
- Check that same key pair is used for all instances