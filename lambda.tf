provider "aws" {
  region = "us-east-1"
}

# Reference existing IAM role by name
data "aws_iam_role" "existing_lambda_role" {
  name = "basic_lambda_exec_role_03"  # <-- Your existing role name here
}

# Create the lambda function using the existing role ARN
resource "aws_lambda_function" "hello" {
  function_name = "basic_hello_lambda_01"
  role          = data.aws_iam_role.existing_lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}

# Create a temporary zip file containing Lambda code
data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda_function_payload.zip"

  source {
    content  = <<EOF
def lambda_handler(event, context):
    return {
        'statusCode': 200,
        'body': 'Hello from Terraform Lambda!'
    }
EOF
    filename = "lambda_function.py"
  }
}
