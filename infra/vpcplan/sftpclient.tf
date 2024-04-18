

data "template_file" "init" {
  template = "${file("scripts/sftpclient_provision.sh")}"
  vars = {
        AWS_DEFAULT_REGION = "${var.region}"
  }

}

resource "aws_key_pair" "tf-sftpclient-key-pair" {
key_name = "tf-sftpclient-key-pair"
public_key = tls_private_key.rsa.public_key_openssh
}
resource "tls_private_key" "rsa" {
algorithm = "RSA"
rsa_bits  = 4096
}
resource "local_file" "tf-sftpclient-key" {
content  = tls_private_key.rsa.private_key_pem
filename = "tf-sftpclient-key-pair"
}


resource "aws_instance" "sftpclient" {
  ami           = "${data.aws_ami.amazon_linux_2.id}"
  instance_type = "${var.instance_type}"
  # key_name      = "${aws_key_pair.ssh_key.key_name}"
  key_name = "tf-sftpclient-key-pair"
  # iam_instance_profile = aws_iam_instance_profile.demo-profile.name
  associate_public_ip_address = false


  root_block_device {
    volume_type = "gp2"
    volume_size = 8
    delete_on_termination = true
  }

  #iam_instance_profile = "${var.prefix}-news_host"


  subnet_id = "${aws_subnet.private_subnet_a.id}"

  vpc_security_group_ids = [
    "${aws_security_group.sftpclient_sg.id}"
    # ,"${aws_security_group.ssh_access.id}"
  ]

  user_data = "${data.template_file.init.rendered}"

  tags = {
    Name = "My Private sftpclient Instance"
  }

}

# Allow public access to the front-end server
resource "aws_security_group_rule" "sftpclient" {
  count = length(var.sg_ingress_rules)
  type        = "ingress"
  from_port         = var.sg_ingress_rules[count.index].from_port
  to_port           = var.sg_ingress_rules[count.index].to_port
  protocol          = var.sg_ingress_rules[count.index].protocol
  cidr_blocks       = [var.sg_ingress_rules[count.index].cidr_block]
  description       = var.sg_ingress_rules[count.index].description

  security_group_id = "${aws_security_group.sftpclient_sg.id}"
}

resource "aws_security_group" "sftpclient_sg" {
  vpc_id      = "${aws_vpc.clvrtp-test.id}"
  name        = "${var.prefix}-sftpclient"
  description = "Security group for sftpclient"

  tags = {
    Name = "SG for sftpclient"
  }
}

# Allow all outbound connections
resource "aws_security_group_rule" "sftpclient_all_out" {
  type        = "egress"
  to_port           = 0
  from_port         = 0
  protocol          = "-1"
  cidr_blocks = [ "0.0.0.0/0" ]
  security_group_id = "${aws_security_group.sftpclient_sg.id}"
}





