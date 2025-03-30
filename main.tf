terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.2.0"
}
provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "generated_key" {
  key_name   = "id_rsa"
  public_key = file("id_rsa.pem.pub")
}

module "network" {
  source = "./modules/network"
}

module "ec2_public" {
  source            = "./modules/ec2"
  key_pair_name     = aws_key_pair.generated_key.key_name
  instance_name     = "ec2_public"
  subnet_id         = module.network.public_subnet_id
  security_group_id = module.network.public_security_group_id
  has_public_ip     = true
}

module "ec2_private" {
  source            = "./modules/ec2"
  key_pair_name     = aws_key_pair.generated_key.key_name
  instance_name     = "ec2_private"
  subnet_id         = module.network.subnet_private_id
  security_group_id = module.network.private_security_group_id
}