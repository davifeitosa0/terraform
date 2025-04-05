resource "aws_instance" "app_server" {
  tags = {
    Name = var.instance_name
  }

  ami                         = "ami-084568db4383264d4"
  instance_type               = "t2.micro"
  key_name                    = var.key_pair_name
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  associate_public_ip_address = var.has_public_ip

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 30
    volume_type = "standard"
  }
}
