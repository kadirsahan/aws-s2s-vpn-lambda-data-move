resource "aws_s3_bucket" "clvrtpxprt-public-bucket" {
  bucket = "clvrtpxprt-public-bucket"

  tags = {
    Name        = "clvrtpxprt-public-bucket"
  }
}

output "clvrtpxprt-public-bucket-arn" {
  description = "clvrtpxprt-public-bucket-arn"
  value = try(aws_s3_bucket.clvrtpxprt-public-bucket.arn,"")
}


output "clvrtpxprt-public-bucket-id" {
  description = "clvrtpxprt-public-bucket-id"
  value = try(aws_s3_bucket.clvrtpxprt-public-bucket.id,"")
}


# resource "aws_s3_bucket_versioning" "clvrtpxprt-public-bucket-versioning" {
#   bucket = aws_s3_bucket.clvrtpxprt-public-bucket.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# Creating s3 resource for invoking to lambda function
resource "aws_s3_bucket" "clvrtpxprt-private-bucket" {
  bucket = "clvrtpxprt-private-bucket"

}

output "clvrtpxprt-private-bucket-arn" {
  description = "clvrtpxprt-private-bucket-arn"
  value = try(aws_s3_bucket.clvrtpxprt-private-bucket.arn,"")
}
output "clvrtpxprt-private-bucket-id" {
  description = "clvrtpxprt-private-bucket-id"
  value = try(aws_s3_bucket.clvrtpxprt-private-bucket.id,"")
}


# resource "aws_s3_bucket_versioning" "clvrtpxprt-private-bucket-versioning" {
#   bucket = aws_s3_bucket.clvrtpxprt-private-bucket.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# resource "aws_s3_bucket_ownership_controls" "clvrtpxprt-private-bucket-ownership" {
#   bucket = aws_s3_bucket.clvrtpxprt-private-bucket.id
#   rule {
#     object_ownership = "BucketOwnerPreferred"
#   }
# }

# resource "aws_s3_bucket_acl" "example" {
#   depends_on = [aws_s3_bucket_ownership_controls.clvrtpxprt-private-bucket-ownership]

#   bucket = aws_s3_bucket.clvrtpxprt-private-bucket.id
#   acl    = "private"
# }

# resource "aws_s3_bucket_policy" "clvrtpxprt-public-bucket-ip-policy" {
#   bucket = "clvrtpxprt-public-bucket"
#   policy = <<POLICY
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Principal": {
#                 "AWS": "arn:aws:iam::921975613299:user/clvrtpxprt"
#             },
#             "Action": "s3:PutObject*",
#             "Resource": "arn:aws:s3:::clvrtpxprt-public-bucket/*",
#             "Condition": {
#                 "IpAddress": {
#                     "aws:SourceIp": [
#                         "52.209.30.153",
#                         "54.72.72.185",
#                         "34.249.27.35",
#                         "34.250.139.131",
#                         "52.211.10.78",
#                         "3.251.214.224/27",
#                         "3.251.214.225",
#                         "3.251.214.254"

#                     ]
#                 }
#             }
#         }
#     ]
# }
# POLICY
# depends_on = [
#     aws_s3_bucket.clvrtpxprt-public-bucket
#   ]
# }

# resource "aws_s3_bucket_policy" "s3-test-policy" {
#   bucket = "kfmrgnmn-test-bucket"
#   policy = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": "*",
#       "Action": [
#         "s3:GetObject"
#       ],
#       "Resource": "arn:aws:s3:::kfmrgnmn-test-bucket/*"
#     }
#   ]
# }
# POLICY
# depends_on = [
#     aws_s3_bucket.clvrtpxprt-public-bucket
#   ]
# }


# #Create an IAM Role for Ec2 for testing/demo purpose
# resource "aws_iam_role" "demo-role" {
#   name = "ec2_role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Sid    = "RoleForEC2"
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         }
#       },
#     ]
#   })
# }

# #Create an IAM Policy
# resource "aws_iam_policy" "demo-s3-policy" {
#   name        = "S3-Bucket-Access-Policy"
#   description = "Provides permission to access S3"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = [
#           "s3:GetObject",
#         ]
#         Effect   = "Allow"
#         Resource = [
#  "arn:aws:s3:::kfmrgnmn-test-bucket",
#  "arn:aws:s3:::kfmrgnmn-test-bucket/*" ]
#       },
#     ]
#   })
# }

# resource "aws_iam_policy_attachment" "demo-attach" {
#   name       = "demo-attachment"
#   roles      = [aws_iam_role.demo-role.name]
#   policy_arn = aws_iam_policy.demo-s3-policy.arn
# }

# resource "aws_iam_instance_profile" "demo-profile" {
#   name = "demo_profile"
#   role = aws_iam_role.demo-role.name
# }

