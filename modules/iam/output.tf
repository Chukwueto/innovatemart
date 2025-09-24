output "developer_access_key_id" {
  value       = aws_iam_access_key.developer_key.id
  description = "Access Key ID for the IAM user"
}

output "developer_console_username" {
  value = aws_iam_user.developer.name
}

output "developer_console_temp_password" {
  value     = aws_iam_user_login_profile.developer_console.password
  sensitive = true
}


output "developer_secret_access_key" {
  value       = aws_iam_access_key.developer_key.secret
  description = "Secret Access Key for the IAM user"
  sensitive   = true
}

output "developer_arn" {
  value       = aws_iam_user.developer.arn
  description = "ARN of the IAM user"
}
