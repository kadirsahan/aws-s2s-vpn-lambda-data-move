variable "prefix" {
  default = "mock-onprem"
}
variable "instance_type" {
  default = "t3.nano"
}
variable "docker_image_tag" {
  default = "latest"
}

variable "region" {
  default = "us-east-1"
}

variable "sg_ingress_rules" {
    type = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_block  = string
      description = string
    }))
    default     = [
        {
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_block  = "0.0.0.0/0"
          description = "ssh"
        },
        {
          from_port   = 2222
          to_port     = 2222
          protocol    = "tcp"
          cidr_block  = "0.0.0.0/0"
          description = "sftp"
        },
    ]
}
