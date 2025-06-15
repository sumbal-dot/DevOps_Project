# main.tf

provider "aws" {
  region = var.region
}

#variable "vpc_id" {
#  description = "The ID of the VPC in which to create resources"
#  default     = "vpc-040fc261" # Replace with your VPC ID
#}

#module "ec2" {
#  source = "./ec2"
#}
