#############################################
# NAT Instance Module (AWS Provider v5+)
#############################################

resource "aws_eip" "nat_eip" {
  tags = merge(var.tags, { Name = "${var.name}-nat-eip" })
}

resource "aws_instance" "nat" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_id
  associate_public_ip_address  = true
  source_dest_check            = false

  vpc_security_group_ids = var.security_group_ids

  tags = merge(var.tags, { Name = "${var.name}-nat-instance" })
}

resource "aws_eip_association" "nat_assoc" {
  instance_id   = aws_instance.nat.id
  allocation_id = aws_eip.nat_eip.id
}

resource "aws_route" "private_default" {
  count                  = length(var.private_route_table_ids)
  route_table_id         = var.private_route_table_ids[count.index]
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_instance.nat.primary_network_interface_id
}
