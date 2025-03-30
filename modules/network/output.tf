output "main_vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.subnet_public.id
  
}

output "subnet_private_id" {
  value = aws_subnet.subnet_private.id
  
}

output "public_security_group_id" {
  value = aws_security_group.public_security_group.id
}

output "private_security_group_id" {
  value = aws_security_group.private_security_group.id
  
}