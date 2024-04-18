# data "aws_iam_policy_document" "assume_role" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["lambda.amazonaws.com"]
#     }

#     actions = ["sts:AssumeRole"]
#   }
# }

# resource "aws_iam_role" "iam_for_lambda" {
#   name               = "iam_for_lambda"
#   assume_role_policy = data.aws_iam_policy_document.assume_role.json
# }



data "archive_file" "lambda-move" {
  type        = "zip"
  source_file = "./aws_s3_lambda_move_files.py"
  output_path = "./aws_s3_lambda_move_files.zip"
}
data "archive_file" "lambda-sftp" {
  type        = "zip"
  source_file = "./aws_lambda_sftp_put_files.py"
  output_path = "./aws_lambda_sftp_put_files.zip"
}


resource "aws_lambda_function" "lambda-move-files" {
  filename      = "aws_s3_lambda_move_files.zip"
  function_name = "lambda-move-files"
  role          = "arn:aws:iam::921975613299:role/lambda-execution-role" # this role should be created in terraform
  handler       = "aws_s3_lambda_move_files.lambda_handler"

  # layers = ["arn:aws:lambda:eu-west-1:898466741470:layer:paramiko-py37:1"]
#   vpc_config {

#     subnet_ids         = ["subnet-088e668521462dd74"]
#     security_group_ids = ["sg-0766234f29166b99b"]
#   }

#   source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.7"

}

resource "aws_lambda_function" "lambda-send-files" {
  filename      = "aws_lambda_sftp_put_files.zip"
  function_name = "lambda-send-files"
  role          = "arn:aws:iam::921975613299:role/lambda-execution-role" # this role should be created in terraform
  handler       = "aws_lambda_sftp_put_files.lambda_handler"

  layers = ["arn:aws:lambda:eu-west-1:898466741470:layer:paramiko-py37:1"]
  vpc_config {

    subnet_ids         = ["subnet-05f65449e8116f1ed"]
    security_group_ids = ["sg-030519c478add75b2"]
  }

   source_code_hash = data.archive_file.lambda-sftp.output_base64sha256

  runtime = "python3.7"

}


resource "aws_lambda_permission" "allow_public_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda-move-files.arn
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::clvrtpxprt-public-bucket"
}

resource "aws_lambda_permission" "allow_private_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda-send-files.arn
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::clvrtpxprt-private-bucket"
}





# Adding S3 bucket as trigger to my lambda and giving the permissions
resource "aws_s3_bucket_notification" "public_bucket_notification" {
  bucket = "clvrtpxprt-public-bucket"

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda-move-files.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_public_bucket]
}

resource "aws_s3_bucket_notification" "private_bucket_notification" {
  bucket = "clvrtpxprt-private-bucket"

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda-send-files.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_private_bucket]
}

