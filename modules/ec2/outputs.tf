output "web_instance_ids" {
  description = "IDs of the web instances"
  value       = aws_instance.web[*].id
}

output "app_instance_ids" {
  description = "IDs of the app instances"
  value       = aws_instance.app[*].id
}

output "web_instance_public_ips" {
  description = "Public IP addresses of the web instances"
  value       = aws_instance.web[*].public_ip
}

output "web_instance_private_ips" {
  description = "Private IP addresses of the web instances"
  value       = aws_instance.web[*].private_ip
}

output "app_instance_private_ips" {
  description = "Private IP addresses of the app instances"
  value       = aws_instance.app[*].private_ip
}

output "bastion_instance_id" {
  description = "ID of the bastion host"
  value       = aws_instance.bastion.id
}

output "bastion_public_ip" {
  description = "Public IP address of the bastion host"
  value       = aws_instance.bastion.public_ip
}

output "bastion_private_ip" {
  description = "Private IP address of the bastion host"
  value       = aws_instance.bastion.private_ip
}

output "private_instance_id" {
  description = "ID of the private instance"
  value       = aws_instance.private.id
}

output "private_instance_private_ip" {
  description = "Private IP address of the private instance"
  value       = aws_instance.private.private_ip
}