variable "prefix" {
  default = "sftpclient"
}
variable "instance_type" {
  default = "t3.nano"
}

variable "region" {
  default = "eu-west-1"
}

variable "project_tagging" {
  description = "Project tagging"
  type        = string
  default     = "clevertap"
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
          from_port   = 0
          to_port     = 65535
          protocol    = "tcp"
          cidr_block  = "10.200.0.0/16"
          description = "ssh"
        },
        {
          from_port   = -1
          to_port     = -1
          protocol    = "icmp"
          cidr_block  = "10.200.0.0/16"
          description = "ping"
        }

    ]
}


###change



variable "vpc_cidr" {
  default = "10.100.0.0/16"
}

variable "public_subnets_cidr" {
  type        = list
  default = ["10.100.1.0/24"]
}

variable "private_subnets_cidr" {
  type        = list
  default = ["10.100.0.0/24"]
}
