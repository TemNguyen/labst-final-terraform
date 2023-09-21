resource "aws_network_interface" "tf_nat_bastion_eni" {
  subnet_id = aws_subnet.tf_pub_subnet[0].id
  security_groups = [aws_security_group.tf_nat_bastion_sg.id]
  source_dest_check = false

  tags = {
    Name = "tf_nat_bastion_eni"
  }
}

resource "aws_route" "route_to_nat" {
  route_table_id = aws_route_table.lab_st_thinhnguyen_tf_pri_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id = aws_network_interface.tf_nat_bastion_eni.id
}

resource "aws_instance" "tf_nat_bastion" {
  ami = var.nat-ami
  instance_type = "t3.small"
  key_name = data.aws_key_pair.ssh_keypair.key_name
  user_data = "${file("nat-user-data.sh")}"

  network_interface {
    network_interface_id = aws_network_interface.tf_nat_bastion_eni.id
    device_index = 0
  }

  tags = {
    Name = "tf_nat_bastion"
  }
}