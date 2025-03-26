
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/26"

  tags = {
    Name = "main_vpc"
  }
}

resource "aws_subnet" "subnet_public" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.0.0/27"

  tags = {
    Name = "subnet-public"
  }
}

resource "aws_subnet" "subnet_private" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.0.32/27"

  tags = {
    Name = "subnet-private"
  }
}

resource "aws_security_group" "public_security_group" {
  name        = "public_security_group"
  description = "Allow SSH access"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
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

resource "aws_security_group" "private_security_group" {
  name        = "private_security_group"
  description = "Allow access only from public EC2"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public_security_group.id]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.public_security_group.id]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.public_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private_security_group"
  }
}
