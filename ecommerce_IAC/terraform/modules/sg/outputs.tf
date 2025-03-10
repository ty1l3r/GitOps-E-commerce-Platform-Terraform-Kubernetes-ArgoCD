output "mongodb_sg_id" {
  description = "ID du security group MongoDB"
  value       = aws_security_group.mongodb.id
}

output "services_sg_id" {
  description = "ID du security group services"
  value       = aws_security_group.services.id
}
