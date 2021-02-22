output tunnel1 {
  value = {
    "tunnel1_public" = aws_vpn_connection.my_connection.tunnel1_address
    "tunnel1_cgw_ip" = aws_vpn_connection.my_connection.tunnel1_cgw_inside_address
    "tunnel1_tgw_ip" = aws_vpn_connection.my_connection.tunnel1_vgw_inside_address
    "tunnel1_asn" = aws_vpn_connection.my_connection.tunnel1_bgp_asn
    "tunnel1_psk" = aws_vpn_connection.my_connection.tunnel1_preshared_key
  }
}

output tunnel2 {
  value = {
    "tunnel2_public" = aws_vpn_connection.my_connection.tunnel1_address
    "tunnel2_cgw_ip" = aws_vpn_connection.my_connection.tunnel1_cgw_inside_address
    "tunnel2_tgw_ip" = aws_vpn_connection.my_connection.tunnel1_vgw_inside_address
    "tunnel2_asn" = aws_vpn_connection.my_connection.tunnel1_bgp_asn
    "tunnel2_psk" = aws_vpn_connection.my_connection.tunnel1_preshared_key
  }
}

output mgmt {
  value = {
    "mgmt_jump_box_ip" = aws_eip.mgmt_eip.public_ip
    "mgmt_vpc_id" = aws_vpc.vpc["mgmt"].id
    "mgmt_subnet_id" = aws_subnet.subnet["mgmt"].id
    "mgmt_subnet_availability_zone" = aws_subnet.subnet["mgmt"].availability_zone
  }
}