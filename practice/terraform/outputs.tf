output "sqs_url" {
  value       = aws_sqs_queue.myapp.url
  description = "The URL for the created Amazon SQS queue"
}

output "keda_operator_iam_role_arn" {
  value       = aws_iam_role.keda_operator.arn
  description = "The ARN of the IAM role created for the keda-operator ServiceAccount"
}

output "myapp_iam_role_arn" {
  value       = aws_iam_role.myapp.arn
  description = "The ARN of the IAM role created for the myapp ServiceAccount"
}

output "sqs_scaler_iam_role_arn" {
  value       = aws_iam_role.sqs_scaler.arn
  description = "The ARN of the IAM role created for the AWS SQS Queue Scaler"
}
