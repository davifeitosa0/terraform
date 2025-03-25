variable "key_pair_name" {
  type    = string
  default = "id_rsa"
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_pair_name
  public_key = file("id_rsa.pem.pub")
}

resource "aws_instance" "app_server" {
  ami                    = "ami-084568db4383264d4"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [aws_security_group.basic_security.id]
  
  ebs_block_device {
    device_name = "dev/sda1"
    volume_size = 30
    volume_type = "standard"
  }

  tags = {
    Name = "ec2-terraform"
  }
}
