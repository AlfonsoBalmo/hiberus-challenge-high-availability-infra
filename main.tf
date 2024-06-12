provider "aws" {
  region = "us-east-1"
}

resource "aws_db_instance" "challenge-hiberus" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t2.micro"
  name                 = "hiberus-challenge"
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.mysql8.0"
  publicly_accessible  = false
  skip_final_snapshot  = true
}

resource "aws_lambda_function" "my_lambda" {
  function_name = "hiberus-lambda"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "handler.lambda_handler"
  runtime       = "python3.8"
  filename      = "lambda_function.zip"

  environment {
    variables = {
      DB_HOST     = aws_db_instance.default.address
      DB_NAME     = "hiberus-challenge"
      DB_USER     = var.db_username
      DB_PASSWORD = var.db_password
    }
  }
}

resource "aws_iam_role" "lambda_exec" {
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
            "cloudwatch:*"
          ]
          Effect = "Allow"
          Resource = "*"
        }
      ]
    })
  }
}
