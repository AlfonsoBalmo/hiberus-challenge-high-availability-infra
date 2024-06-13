provider "aws" {
  region = "us-east-1"
}

# Reemplaza con el ID de tu VPC existente
data "aws_vpc" "selected" {
  id = "vpc-04212d0c27780ff5e"
}

# Subnets - actualiza con las subnets de tu VPC existente
data "aws_subnet" "subnet1" {
  id = "subnet-0123456789abcdef0" # Reemplaza con tu subnet ID
}

data "aws_subnet" "subnet2" {
  id = "subnet-abcdef0123456789" # Reemplaza con tu subnet ID
}

# Security Group for RDS
resource "aws_security_group" "rds_sg" {
  vpc_id = data.aws_vpc.selected.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.lambda_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for Lambda
resource "aws_security_group" "lambda_sg" {
  vpc_id = data.aws_vpc.selected.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# DB Subnet Group
resource "aws_db_subnet_group" "default" {
  name       = "my-db-subnet-group"
  subnet_ids = [data.aws_subnet.subnet1.id, data.aws_subnet.subnet2.id]

  tags = {
    Name = "my-db-subnet-group"
  }
}

# RDS Instance
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
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name  = aws_db_subnet_group.default.name
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  inline_policy {
    name = "lambda_policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "rds:*",
            "logs:*",
            "cloudwatch:*",
            "apigateway:*",
            "lambda:*"
          ]
          Effect = "Allow"
          Resource = "*"
        }
      ]
    })
  }
}

# Lambda Function
resource "aws_lambda_function" "my_lambda" {
  function_name = "hiberus-lambda"
  s3_bucket     = var.lambda_s3_bucket
  s3_key        = var.lambda_s3_key
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "handler.lambda_handler"
  runtime       = "python3.8"
  vpc_config {
    subnet_ids         = [data.aws_subnet.subnet1.id, data.aws_subnet.subnet2.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
  environment {
    variables = {
      DB_HOST     = aws_db_instance.default.address
      DB_NAME     = aws_db_instance.default.db_name
      DB_USER     = var.db_username
      DB_PASSWORD = var.db_password
    }
  }
}

# API Gateway
resource "aws_apigatewayv2_api" "api" {
  name          = "my_api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id             = aws_apigatewayv2_api.api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.my_lambda.invoke_arn
}

resource "aws_apigatewayv2_route" "lambda" {
  api_id   = aws_apigatewayv2_api.api.id
  route_key = "GET /"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id     = aws_apigatewayv2_api.api.id
  name       = "$default"
  auto_deploy = true
}

output "api_endpoint" {
  value = aws_apigatewayv2_api.api.api_endpoint
}
