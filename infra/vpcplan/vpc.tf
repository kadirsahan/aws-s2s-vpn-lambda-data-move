resource "aws_vpc" "clvrtp-test" {
 cidr_block = "10.100.0.0/16"
 
 tags = {
   Name = "aws-onprem integration project"
 }
 #tenancy is default
}


data "aws_ami" "amazon_linux_2" {
 most_recent = true

 filter {
   name   = "name"
   values = ["amzn2-ami-hvm*"]
 }

 filter {
   name = "architecture"
   values = ["x86_64"]
 }

 owners = ["137112412989"] #amazon
}



# resource "aws_security_group" "ssh_access" {
#   vpc_id      = "${aws_vpc.clvrtp-test.id}"
#   name        = "${var.prefix}-ssh_access"
#   description = "SSH access group"

#   ingress {
#     from_port = 22
#     to_port = 22
#     protocol = "tcp"
#     cidr_blocks = ["10.200.0.0/16"]
#   }

#   tags = {
#     Name = "Allow sftp"
#   }
# }
