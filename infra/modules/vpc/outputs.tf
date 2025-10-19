output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_ids" {
  value = [for s in aws_subnet.public : s.id]
}

output "private_subnet_ids" {
  value = [for s in aws_subnet.private : s.id]
}

output "private_route_table_ids" {
  value = [for rt in aws_route_table.private : rt.id]
}

output "endpoint_ids" {
  value = [for ep in aws_vpc_endpoint.interface : ep.id]
}

output "endpoint_sg_id" {
  value = aws_security_group.vpc_endpoint_sg.id
}
