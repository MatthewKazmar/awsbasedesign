#This design deploys a base AWS design without Aviatrix: 3 VPCs with EC2 VMs, Transit GW, VPN to on-prem
#Purpose: Provide a base design for which to promote connectivity to Azure using Aviatrix.

provider "aws" {
  profile = "default"
  region = var.region

}

resource "aws_key_pair" "key_pair" {
  key_name   = "aws_base_design"
  public_key = file("key.pub")
}

resource "aws_vpc" "vpc" {
  for_each = var.vpcs
  cidr_block = each.value.cidr
  tags = {
    Name = each.value.name
  }
}

resource "aws_subnet" "subnet" {
  for_each = var.vpcs
  vpc_id = aws_vpc.vpc[each.key].id
  cidr_block = cidrsubnet(each.value.cidr,2,0)
  availability_zone = each.value.av_zone
}

resource "aws_internet_gateway" "mgmt_gw" {
  vpc_id = aws_vpc.vpc["mgmt"].id
}

resource "aws_route" "mgmt_default" {
  route_table_id = aws_vpc.vpc["mgmt"].default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.mgmt_gw.id
}

resource "aws_security_group" "sg" {
  for_each = var.vpcs
  
  vpc_id = aws_vpc.vpc[each.key].id
  name = "${each.key}_rdp_sg"
  ingress {
    description = "RDP"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8","172.16.0.0/12","192.168.0.0/16","${var.my_public_ip}/32"]
  }
  ingress {
    description = "ICMP"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "vm" {
  for_each = var.vpcs
  instance_type = "t3.large"
  ami = var.ami_id
  subnet_id = aws_subnet.subnet[each.key].id
  #associate_public_ip_address = false
  vpc_security_group_ids = [aws_security_group.sg[each.key].id]
  key_name = aws_key_pair.key_pair.key_name
  tags = {
    Name = "${each.key}_vm"
  }
}

resource "aws_eip" "mgmt_eip" {
  instance = aws_instance.vm["mgmt"].id
  vpc = true
}

resource "aws_ec2_transit_gateway" "tgw" {
  amazon_side_asn = 64750
  tags = {
    name = "aws_base_tgw"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attachment" {
  for_each = var.vpcs
  
  subnet_ids = [aws_subnet.subnet[each.key].id]
  vpc_id = aws_vpc.vpc[each.key].id
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "route_default" {
  for_each = { for k, v in var.vpcs : k => v if ! contains([k], "mgmt") }

  route_table_id = aws_vpc.vpc[each.key].default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "route_10" {
  for_each = var.vpcs

  route_table_id = aws_vpc.vpc[each.key].default_route_table_id
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "route_172" {
  for_each = var.vpcs

  route_table_id = aws_vpc.vpc[each.key].default_route_table_id
  destination_cidr_block = "172.16.0.0/12"
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "route_192" {
  for_each = var.vpcs

  route_table_id = aws_vpc.vpc[each.key].default_route_table_id
  destination_cidr_block = "192.168.0.0/16"
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
}

resource "aws_customer_gateway" "my_gateway" {
  bgp_asn = var.my_asn
  ip_address = var.my_public_ip
  type = "ipsec.1"
  tags = {
    name = "my_vpn_gateway"
  }
}

resource "aws_vpn_connection" "my_connection" {
  customer_gateway_id = aws_customer_gateway.my_gateway.id
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  type = aws_customer_gateway.my_gateway.type
}