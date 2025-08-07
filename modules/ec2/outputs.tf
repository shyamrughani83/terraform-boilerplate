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