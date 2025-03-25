terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}
provider "aws" {
  region = "us-east-1"
}

module "ec2" {
  source = "./modules/ec2"
}

# resource "aws_instance" "app_server" {
#   ami           = "ami-084568db4383264d4"
#   instance_type = "t2.micro"
#   tags = {
#     Name = "ExampleAppServerInstance"
#   }
# }
