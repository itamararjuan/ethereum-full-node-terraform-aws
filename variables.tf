variable "application" {
  default = "ethereum"
}

variable "provisionersrc" {
  default = "itamararjuan/ethereum-full-node-terraform-aws"
}

variable "vpc_cidr_block" {
  description = "The VPC CIDR address range"

  #https://docs.docker.com/docker-for-aws/faqs/#recommended-vpc-and-subnet-setup
  default = "172.31.0.0/16"
}

variable "region" {
  default = "us-east-2"
}

variable "aws_profile" {
  default = "default"
}