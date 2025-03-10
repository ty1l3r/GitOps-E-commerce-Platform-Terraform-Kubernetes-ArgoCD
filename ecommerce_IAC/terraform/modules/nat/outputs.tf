output "nat_gateway_ids" {
  value = aws_nat_gateway.main[*].id
}

output "eip_ids" {
  value = aws_eip.nat[*].id
}