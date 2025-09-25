main.tf
 
provider "aws" {
  region = "eu-north-1" # change if needed
}
 
# IAM role for Lambda
resource "aws_iam_role" "lambda_exec" {
  name = "basic_lambda_exec_role"
 
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}
 
# Attach basic execution policy (for logging)
resource "aws_iam_role_policy_attachment" "lambda_logging" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
 
# Lambda function
resource "aws_lambda_function" "hello" {
  function_name = "basic_hello_lambda"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"

}
