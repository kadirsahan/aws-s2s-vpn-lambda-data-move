resource "aws_secretsmanager_secret" "sftpserver-1G" {
  name = "sftpserver-1G"

}

resource "aws_secretsmanager_secret_version" "sversion" {
  secret_id     = aws_secretsmanager_secret.sftpserver-1G.id
    secret_string = <<EOF
        {
        "username": "demo",
        "password": "demo"
        }
    EOF
}

output "sftp-secret-arn" {
  description = "sftp-secret-arn"
  value = try(aws_secretsmanager_secret.sftpserver-1G.arn,"")
}
