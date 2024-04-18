output "sftpserver_public_ip" {
  description = "The public IP address of the sftpserver"
  value = try(aws_instance.sftpserver.public_ip,"")
}
