### Front end

resource "aws_security_group" "sftpserver_sg" {
  vpc_id      = "${aws_vpc.vpc.id}"
  name        = "${var.prefix}-sftpserver"
  description = "Security group for sftpserver"

  tags = {
    Name = "SG for sftpserver"
    createdBy = "infra-${var.prefix}/news"
  }
}

# Allow all outbound connections
resource "aws_security_group_rule" "sftpserver_all_out" {
  type        = "egress"
  to_port           = 0
  from_port         = 0
  protocol          = "-1"
  cidr_blocks = [ "0.0.0.0/0" ]
  security_group_id = "${aws_security_group.sftpserver_sg.id}"
}

data "template_file" "init" {
  template = "${file("scripts/sftp_provision.sh")}"
  vars = {
        AWS_DEFAULT_REGION = "${var.region}"
  }

}

resource "aws_key_pair" "tf-key-pair" {
key_name = "tf-key-pair"
public_key = tls_private_key.rsa.public_key_openssh
}
resource "tls_private_key" "rsa" {
algorithm = "RSA"
rsa_bits  = 4096
}
resource "local_file" "tf-key" {
content  = tls_private_key.rsa.private_key_pem
filename = "tf-key-pair"
}


resource "aws_instance" "sftpserver" {
  ami           = "${data.aws_ami.amazon_linux_2.id}"
  instance_type = "${var.instance_type}"
  # key_name      = "${aws_key_pair.ssh_key.key_name}"
  key_name = "tf-key-pair"
  associate_public_ip_address = true


  connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ec2-user"
      private_key = file("certificate/id_rsa")
      timeout     = "4m"
   }

  root_block_device {
    volume_type = "gp2"
    volume_size = 8
    delete_on_termination = true
  }

  #iam_instance_profile = "${var.prefix}-news_host"

  availability_zone = "${var.region}a"

  subnet_id = "${aws_subnet.public_subnet_a.id}"

  vpc_security_group_ids = [
    "${aws_security_group.sftpserver_sg.id}",
    "${aws_security_group.ssh_access.id}"
  ]

  user_data = "${data.template_file.init.rendered}"

}

# Allow public access to the front-end server
resource "aws_security_group_rule" "sftpserver" {
  count = length(var.sg_ingress_rules)
  type        = "ingress"
  from_port         = var.sg_ingress_rules[count.index].from_port
  to_port           = var.sg_ingress_rules[count.index].to_port
  protocol          = var.sg_ingress_rules[count.index].protocol
  cidr_blocks       = [var.sg_ingress_rules[count.index].cidr_block]
  description       = var.sg_ingress_rules[count.index].description

  security_group_id = "${aws_security_group.sftpserver_sg.id}"
}
### end of front-end





