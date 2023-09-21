resource "aws_vpc" "lab_st_thinhnguyen_tf_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "lab_st_thinhnguyen_tf_vpc"
  }
}

##########################
# CREATE INTENET GATEWAY #
##########################

resource "aws_internet_gateway" "lab_st_thinhnguyen_tf_igw" {
  vpc_id = aws_vpc.lab_st_thinhnguyen_tf_vpc.id

  tags = {
    Name = "lab_st_thinhnguyen_tf_ig"
  }
}

##################
# CREATE SUBNETS #
##################

resource "aws_subnet" "tf_pub_subnet" {
  count = length(var.pub_subnets_cidr)
  vpc_id = aws_vpc.lab_st_thinhnguyen_tf_vpc.id
  cidr_block = element(var.pub_subnets_cidr, count.index)
  availability_zone = element(var.azs, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "tf-pub-subnet-0${count.index+1}"
  }
}

resource "aws_subnet" "tf_pri_subnet" {
  count = length(var.pri_subnets_cidr)
  vpc_id = aws_vpc.lab_st_thinhnguyen_tf_vpc.id
  cidr_block = element(var.pri_subnets_cidr, count.index)
  availability_zone = element(var.azs, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name = "tf-pri-subnet-0${count.index+1}"
  }
}

#############################
# CREATE PUBLIC ROUTE TABLE #
#############################

resource "aws_route_table" "lab_st_thinhnguyen_tf_pub_rtb" {
  vpc_id = aws_vpc.lab_st_thinhnguyen_tf_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab_st_thinhnguyen_tf_igw.id
  }

  tags = {
    Name = "lab_st_thinhnguyen_tf_pub_rtb"
  }
}

resource "aws_route_table_association" "pub_rtb_association" {
  count = length(var.pub_subnets_cidr)
  subnet_id = element(aws_subnet.tf_pub_subnet.*.id, count.index)
  route_table_id = aws_route_table.lab_st_thinhnguyen_tf_pub_rtb.id
}

##############################
# CREATE PRIVATE ROUTE TABLE #
##############################

resource "aws_route_table" "lab_st_thinhnguyen_tf_pri_rtb" {
  vpc_id = aws_vpc.lab_st_thinhnguyen_tf_vpc.id

  tags = {
    Name = "lab_st_thinhnguyen_tf_pri_rtb"
  }
}

resource "aws_route_table_association" "pri_rtb_association" {
  count = length(var.pri_subnets_cidr)
  subnet_id = element(aws_subnet.tf_pri_subnet.*.id, count.index)
  route_table_id = aws_route_table.lab_st_thinhnguyen_tf_pri_rtb.id
}