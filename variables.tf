variable "db_username" {
  description = "The username for the RDS instance"
  type        = string
  default     = "adminuser"
}

variable "db_password" {
  description = "The password for the RDS instance"
  type        = string
  sensitive   = true
}

variable "lambda_s3_bucket" {
  description = "The S3 bucket where the Lambda package is stored"
  type        = string
  default     = "unique-lambda-bucket-abcdef123456"
}

variable "lambda_s3_key" {
  description = "The S3 key for the Lambda package"
  type        = string
  default     = "lambda_function.zip"
}
