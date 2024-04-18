# resource "aws_iam_user" "clvrtpxprt" {
#   name = "clvrtpxprt"
# }

# resource "aws_iam_access_key" "clvrtpxprt" {
#   user = aws_iam_user.clvrtpxprt.name
# }

# data "aws_iam_policy_document" "clvrtpxprt_ro" {
#   statement {
#     effect    = "Allow"
#     actions   = ["ec2:Describe*"]
#     resources = ["*"]
#   }
# }

# resource "aws_iam_user_policy" "lb_ro" {
#   name   = "test"
#   user   = aws_iam_user.clvrtpxprt.name
#   policy = data.aws_iam_policy_document.clvrtpxprt_ro.json
# }

# output "secret-1" {
#   description = "aws access id-1"
#   value = aws_iam_access_key.clvrtpxprt.id
# }
# output "secret-2" {
#   description = "aws access id-2"
#   value = aws_iam_access_key.clvrtpxprt.encrypted_secret
# }
# output "secret-3" {
#   description = "aws access id-3"
#   sensitive = true
#   value = aws_iam_access_key.clvrtpxprt.secret
# }
# output "secret-4" {
#   description = "aws access id-4"
#   sensitive = true
#   value = aws_iam_access_key.clvrtpxprt.ses_smtp_password_v4
# }
# output "secret-5" {
#   description = "aws access id-5"
#   value = aws_iam_access_key.clvrtpxprt.pgp_key
# }
# output "secret-6" {
#   description = "aws access id-6"
#   value = aws_iam_access_key.clvrtpxprt.key_fingerprint
# }

#create clvrtpxprt user

locals {
  users = {
    "clvrtpxprt" = {
      name  = "clvrtpxprt"
      email = ""
    } 
  }
}

resource "aws_iam_user" "clvrtpxprt" {
  for_each = local.users

  name          = each.key
  force_destroy = false
}

resource "aws_iam_access_key" "user_access_key" {
  for_each = local.users
  
  user       = each.key
  depends_on = [aws_iam_user.clvrtpxprt]
}

resource "pgp_key" "user_login_key" {
  for_each = local.users

  name    = each.value.name
  email   = each.value.email
  comment = "PGP Key for ${each.value.name}"
}

resource "aws_iam_user_login_profile" "user_login" {
  for_each = local.users

  user                    = each.key
  pgp_key                 = pgp_key.user_login_key[each.key].public_key_base64
  password_reset_required = true

  depends_on = [aws_iam_user.clvrtpxprt, pgp_key.user_login_key]
}

data "pgp_decrypt" "user_password_decrypt" {
  for_each = local.users

  ciphertext          = aws_iam_user_login_profile.user_login[each.key].encrypted_password
  ciphertext_encoding = "base64"
  private_key         = pgp_key.user_login_key[each.key].private_key
}

# output "credentials" {
#   value = {
#     for k, v in local.users : k => {
#       "key"      = aws_iam_access_key.user_access_key[k].id
#       "secret"   = aws_iam_access_key.user_access_key[k].secret
#       "password" = data.pgp_decrypt.user_password_decrypt[k].plaintext
#     }
#   }
#   sensitive = true
# }

# create aws lambda role
resource "aws_iam_role" "lambda-execution-role" {
  name = "lambda-execution-role"
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


output "lambda-role-arn" {
  description = "lambda-role-arn"
  value = try(aws_iam_role.lambda-execution-role.arn,"")
}


 
resource "aws_iam_policy" "lambda-access-policy" {
  name        = "lambda-access-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:Get*",
        "s3:Delete*"
      ]
      Resource = ["arn:aws:s3:::clvrtpxprt-public-bucket/*"]
    },{
      Effect = "Allow"
      Action = [
        "s3:Put*",
        "s3:Get*"
      ]
      Resource = ["arn:aws:s3:::clvrtpxprt-private-bucket/*"]
    },
    {
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue"
      ]
      Resource = ["arn:aws:secretsmanager:eu-west-1:921975613299:secret:sftpserver-1G-WR7FPB"]
    },
     {
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = ["*"]
    },
    {
      Effect = "Allow"
      Action = [
        "ec2:CreateNetworkInterface",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DetachNetworkInterface"
      ]
      Resource = ["*"]
    }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda-role-attachment" {
  policy_arn = aws_iam_policy.lambda-access-policy.arn
  role = aws_iam_role.lambda-execution-role.name
}


#  s3 bucket policy
resource "aws_s3_bucket_policy" "clvrtpxprt-public-bucket-ip-policy" {
  bucket = "clvrtpxprt-public-bucket"
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::921975613299:user/clvrtpxprt"
            },
            "Action": "s3:PutObject*",
            "Resource": "arn:aws:s3:::clvrtpxprt-public-bucket/*",
            "Condition": {
                "IpAddress": {
                    "aws:SourceIp": [
                        "52.209.30.153",
                        "54.72.72.185",
                        "34.249.27.35",
                        "34.250.139.131",
                        "52.211.10.78",
                        "3.251.214.224/27",
                        "3.251.214.225",
                        "3.251.214.254"

                    ]
                }
            }
        }
    ]
}
POLICY
depends_on = [
    aws_s3_bucket.clvrtpxprt-public-bucket
  ]
}