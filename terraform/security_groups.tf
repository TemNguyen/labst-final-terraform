resource "aws_security_group" "tf_nat_bastion_sg" {
  name = "tf_nat_bastion_sg"
  description = "Allow SSH, ICMP inbound traffic from ST network; Allow all TCP inbound traffic from pri-subnets."
  vpc_id = aws_vpc.lab_st_thinhnguyen_tf_vpc.id

  ingress {
    description = "SSH traffic from ST network"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    prefix_list_ids = [data.aws_ec2_managed_prefix_list.st_network.id]
  }

  ingress {
    description = "ICMP traffic from ST network and pri-subnets"
    from_port = -1
    to_port = -1
    protocol = "icmp"
    prefix_list_ids = [data.aws_ec2_managed_prefix_list.st_network.id]
    cidr_blocks = ["10.0.0.0/23"]
  }

  ingress {
    description = "All TCP traffic from pri-subnets"
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["10.0.0.0/23"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "tf_alb_sg" {
  name = "tf_alb_sg"
  description = "Allow HTTP, HTTPS from all network."
  vpc_id = aws_vpc.lab_st_thinhnguyen_tf_vpc.id

  ingress {
    description = "HTTP traffic from all network."
    from_port = 80
    to_port = 81
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS traffic from all network."
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "tf_ecs_sg" {
  name = "tf_ecs_sg"
  description = "Allow SSH, ICMP inbound traffic from Bastion; Allow all tcp traffic from Load Balancer."
  vpc_id = aws_vpc.lab_st_thinhnguyen_tf_vpc.id

  ingress {
    description = "SSH traffic from Bastion"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_groups = [aws_security_group.tf_nat_bastion_sg.id]
  }

  ingress {
    description = "ICMP traffic from Bastion"
    from_port = -1
    to_port = -1
    protocol = "icmp"
    security_groups = [aws_security_group.tf_nat_bastion_sg.id]
  }

  ingress {
    description = "All tcp traffic from ALB"
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    security_groups = [aws_security_group.tf_alb_sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "tf_rds_sg" {
  name = "tf_rds_sg"
  description = "Allow Mysql connection from Nat bastion and ECS EC2 instance"
  vpc_id = aws_vpc.lab_st_thinhnguyen_tf_vpc.id

  ingress {
    description = "Mysql connection from bastion"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = [aws_security_group.tf_nat_bastion_sg.id]
  }

  ingress {
    description = "Mysql connection from ecs"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = [aws_security_group.tf_ecs_sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}