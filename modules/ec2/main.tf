# Data source for latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Web Instances
resource "aws_instance" "web" {
  count = length(var.public_subnet_ids)

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.public_subnet_ids[count.index]
  vpc_security_group_ids = [var.web_security_group_id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Web Server ${count.index + 1}</h1>" > /var/www/html/index.html
              EOF

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-web-${count.index + 1}"
    Type = "Web"
  })
}

# Bastion Host
resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.bastion_instance_type
  key_name               = var.key_name
  subnet_id              = var.public_subnet_ids[0]
  vpc_security_group_ids = [var.bastion_security_group_id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y htop
              echo "Bastion Host" > /tmp/bastion-info.txt
              EOF

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-bastion"
    Type = "Bastion"
  })
}

# Private Instance (accessible only via bastion)
resource "aws_instance" "private" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.private_instance_type
  key_name               = var.key_name
  subnet_id              = var.private_subnet_ids[0]
  vpc_security_group_ids = [var.private_security_group_id]
  associate_public_ip_address = false

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y htop mysql
              echo "Private Server - Access via Bastion Only" > /tmp/private-info.txt
              EOF

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-private"
    Type = "Private"
  })
}

# Application Instances
resource "aws_instance" "app" {
  count = length(var.private_subnet_ids)

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.private_subnet_ids[count.index]
  vpc_security_group_ids = [var.app_security_group_id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y java-1.8.0-openjdk
              echo "Application Server ${count.index + 1}" > /tmp/app-info.txt
              EOF

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-app-${count.index + 1}"
    Type = "Application"
  })
}