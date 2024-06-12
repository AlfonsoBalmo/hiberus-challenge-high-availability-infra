output "db_instance_endpoint" {
  value = aws_db_instance.default.endpoint
}

output "lambda_function_name" {
  value = aws_lambda_function.my_lambda.function_name
}
