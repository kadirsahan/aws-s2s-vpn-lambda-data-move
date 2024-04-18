#use the aws provider and find the default profile in the aws credentials file
provider "aws" {
  region = "eu-west-1"
  profile = "default"
}
terraform {
  required_providers {

    aws = {
      source = "hashicorp/aws"
    }
    pgp = {
      source = "ekristen/pgp"
    }
  }
}
