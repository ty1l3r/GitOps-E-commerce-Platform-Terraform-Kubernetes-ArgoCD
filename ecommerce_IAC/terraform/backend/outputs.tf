output "state_bucket_name" {
  value = aws_s3_bucket.terraform_state.id
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.terraform_locks.id
}

output "state_bucket_arn" {
  value = aws_s3_bucket.terraform_state.arn
}

output "dynamodb_table_arn" {
  value = aws_dynamodb_table.terraform_locks.arn
}