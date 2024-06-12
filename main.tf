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
  function_name = "hiberus-lambda"
  s3_bucket     = var.lambda_s3_bucket
  s3_key        = var.lambda_s3_key
  role          = "arn:aws:iam::471112872744:role/lambda_exec_role"
  handler       = "handler.lambda_handler"
  runtime       = "python3.8"

  environment {
    variables = {
      DB_HOST     = aws_db_instance.default.endpoint
      DB_NAME     = "hiberus"
      DB_USER     = var.db_username
      DB_PASSWORD = var.db_password
    }
  }
}
