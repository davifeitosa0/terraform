
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/26"

  tags = {
    Name = "main_vpc"
  }
}

resource "aws_subnet" "subnet_public" {
    vpc_id     = aws_vpc.main_vpc.id
    cidr_block = "10.0.0.0/27"
}

resource "aws_subnet" "subnet_private" {
  vpc_id = aws_vpc.main_vpc.id
    cidr_block = "10.0.0.32/27"
}

resource "aws_security_group" "basic_security" {
  name        = "basic_security"
  description = "Allow SSH access"
  vpc_id      = main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



output "main_vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "basic_security_group_id" {
  value = aws_security_group.basic_security.id
}