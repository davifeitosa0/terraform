
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
    Name = "subnet_public"
  }
}

resource "aws_subnet" "subnet_private" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.0.32/27"

  tags = {
    Name = "subnet_private"
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

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "internet_gateway"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = {
    Name = "my-public-route-table"
  }
}
resource "aws_route_table_association" "public_route_association" {
  subnet_id      = aws_subnet.subnet_public.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_eip" "nat_gateway_eip" {
  domain = "vpc"
  tags = {
    Name = "nat_gateway_eip"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.subnet_public.id
  tags = {
    Name = "nat_gateway"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = {
    Name = "private_route_table"
  }
}

resource "aws_route_table_association" "private_route_association" {
  subnet_id      = aws_subnet.subnet_private.id
  route_table_id = aws_route_table.private_route_table.id
}


resource "aws_network_acl" "public_network_acl" {
  vpc_id = aws_vpc.main_vpc.id

  subnet_ids = [aws_subnet.subnet_public.id]
  tags = {
    Name = "public-network-acl"
  }
}

resource "aws_network_acl" "private_network_acl" {
  vpc_id = aws_vpc.main_vpc.id

  subnet_ids = [aws_subnet.subnet_private.id]
  tags = {
    Name = "private-network-acl"
  }
}

resource "aws_network_acl_rule" "public_allow_all_inbound_rule" {
  network_acl_id = aws_network_acl.public_network_acl.id
  rule_number    = 100
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 65535
}

resource "aws_network_acl_rule" "public_allow_all_outbound_rule" {
  network_acl_id = aws_network_acl.public_network_acl.id
  rule_number    = 100
  protocol       = "tcp"
  egress         = true
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 65535
}

resource "aws_network_acl_rule" "public_80" {
  network_acl_id = aws_network_acl.public_network_acl.id
  rule_number    = 200
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "public_80_outbound" {
  network_acl_id = aws_network_acl.public_network_acl.id
  rule_number    = 200
  protocol       = "tcp"
  egress         = true
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "public_443" {
  network_acl_id = aws_network_acl.public_network_acl.id
  rule_number    = 300
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "public_443_outbound" {
  network_acl_id = aws_network_acl.public_network_acl.id
  rule_number    = 300
  protocol       = "tcp"
  egress         = true
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "public_22" {
  network_acl_id = aws_network_acl.public_network_acl.id
  rule_number    = 400
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "public_22_outbound" {
  network_acl_id = aws_network_acl.public_network_acl.id
  rule_number    = 400
  protocol       = "tcp"
  egress         = true
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "private_inbound_rule_all" {
  network_acl_id = aws_network_acl.private_network_acl.id
  rule_number    = 100
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 65535
}
resource "aws_network_acl_rule" "private_outbound_rule_all" {
  network_acl_id = aws_network_acl.private_network_acl.id
  rule_number    = 100
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 65535
}

resource "aws_network_acl_rule" "private_to_public_inbound_rule" {
  network_acl_id = aws_network_acl.private_network_acl.id
  rule_number    = 150
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "10.0.0.0/25"
  from_port      = 3000
  to_port        = 65535
}
resource "aws_network_acl_rule" "private_to_public_outbound_rule" {
  network_acl_id = aws_network_acl.private_network_acl.id
  rule_number    = 150
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "10.0.0.0/25"
  from_port      = 3000
  to_port        = 65535
}

resource "aws_network_acl_rule" "private_80" {
  network_acl_id = aws_network_acl.private_network_acl.id
  rule_number    = 200
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "private_80_outbound" {
  network_acl_id = aws_network_acl.private_network_acl.id
  rule_number    = 200
  protocol       = "tcp"
  egress         = true
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "private_443" {
  network_acl_id = aws_network_acl.private_network_acl.id
  rule_number    = 300
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "private_443_outbound" {
  network_acl_id = aws_network_acl.private_network_acl.id
  rule_number    = 300
  protocol       = "tcp"
  egress         = true
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "private_22" {
  network_acl_id = aws_network_acl.private_network_acl.id
  rule_number    = 400
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "private_22_outbound" {
  network_acl_id = aws_network_acl.private_network_acl.id
  rule_number    = 400
  protocol       = "tcp"
  egress         = true
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 22
  to_port        = 22
}
