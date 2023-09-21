resource "aws_db_subnet_group" "tf_subnet_group" {
  name = "tf-subnet-group"
  subnet_ids = [for subnet in aws_subnet.tf_pri_subnet : subnet.id]

  tags = {
    Name = "tf-subnet-group"
  }
}

resource "aws_db_instance" "tf_rds" {
  allocated_storage = 10
  db_name = "wordpress"
  engine = "mysql"
  engine_version = "8.0.33"
  instance_class = "db.t3.small"
  username = "admin"
  password = "QNobQX0jtWYrCcdKeRy1"
  db_subnet_group_name = aws_db_subnet_group.tf_subnet_group.name
  vpc_security_group_ids = [aws_security_group.tf_rds_sg.id]
  skip_final_snapshot = true
  identifier = "tf-rds"
}