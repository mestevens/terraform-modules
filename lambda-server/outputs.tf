output "role_id" {
  value = aws_iam_role.role.id
}

output "lambda_arn" {
  value = aws_lambda_function.lambda.arn
}
