provider "aws" {
  region = "eu-west-2"
  access_key = "poo"
  secret_key = "Poo"
  skip_credentials_validation = true
  skip_metadata_api_check     = true

  endpoints {
    iam = "http://localhost:4566"
    s3 = "http://localhost:4566"
    lambda = "http://localhost:4566"
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "LambdaBasicExecution"
  assume_role_policy = file("policies/trust-policy.json")
}

resource "aws_iam_role_policy_attachment" "lambda_exec_policy_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_s3_bucket" "robin_bucket" {
  bucket = "robinsbucket"
}

resource "aws_s3_bucket_ownership_controls" "robin_bucket_controls" {
  bucket = aws_s3_bucket.robin_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "robin_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.robin_bucket_controls]

  bucket = aws_s3_bucket.robin_bucket.id
  acl    = "private"
}

resource "aws_iam_policy" "bucket_policy" {
  name        = "robinbucketpolicy"
  path        = "/"
  description = "Policy for accessing robinsbucket"
  policy      = file("policies/robinbucketpolicy.json")
}

resource "aws_iam_role_policy_attachment" "bucket_policy_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.bucket_policy.arn
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "lambda/robin.py"
  output_path = "function.zip"
}

resource "aws_lambda_function" "lambda" {
  function_name = "robinslambda"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "robin.lambda_handler"
  runtime       = "python3.8"
  filename      = data.archive_file.lambda_zip.output_path
}