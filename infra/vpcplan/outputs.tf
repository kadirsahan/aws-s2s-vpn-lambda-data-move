output "vpc-id" {
  description = "the vpc id"
  value = try(aws_vpc.clvrtp-test.id,"")
}
output "private-subnet-id" {
  description = "the private subnet id"
  value = try(aws_subnet.private_subnet_a.id,"")
}
output "security-sftpclient-group-id" {
  description = "the security group id"
  value = try(aws_security_group.sftpclient_sg.id,"")
}

