provider "aws" {
  region = "us-east-1"
}

resource "aws_db_instance" "default" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7.44"
  instance_class       = "db.t3.micro"
  db_name              = "mydatabase"
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.mysql5.7"
  publicly_accessible  = false
  skip_final_snapshot  = true
}

resource "aws_lambda_function" "my_lambda" {
  function_name = "hiberus-lambda-23"
  s3_bucket     = var.lambda_s3_bucket
  s3_key        = var.lambda_s3_key
  role          = "arn:aws:iam::471112872744:role/lambda_exec_role"
  handler       = "src/index.handler"
  runtime       = "nodejs14.x"

  environment {
    variables = {
      DB_HOST     = aws_db_instance.default.endpoint
      DB_NAME     = "hiberus"
      DB_USER     = var.db_username
      DB_PASSWORD = var.db_password
      PORT        = "3000"
    }
  }
}

resource "aws_apigatewayv2_api" "api" {
  name          = "my_api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id             = aws_apigatewayv2_api.api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.my_lambda.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "GET /"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

output "api_endpoint" {
  value = aws_apigatewayv2_stage.default_stage.invoke_url
}
