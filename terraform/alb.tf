resource "aws_lb_target_group" "tf_tg_80" {
  name = "tf-tg-80"
  port = 80
  protocol = "HTTP"
  target_type = "instance"
  vpc_id = aws_vpc.lab_st_thinhnguyen_tf_vpc.id
}

resource "aws_lb_target_group" "tf_tg_8080" {
  name = "tf-tg-8080"
  port = 8080
  protocol = "HTTP"
  target_type = "instance"
  vpc_id = aws_vpc.lab_st_thinhnguyen_tf_vpc.id
}

resource "aws_alb" "tf_alb" {
  name = "tf-alb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.tf_alb_sg.id]
  subnets = [for subnet in aws_subnet.tf_pub_subnet : subnet.id]
}

resource "aws_lb_listener" "listener_80" {
  load_balancer_arn = aws_alb.tf_alb.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.tf_tg_8080.arn
  }
}

resource "aws_lb_listener" "listener_81" {
  load_balancer_arn = aws_alb.tf_alb.arn
  port = "81"
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.tf_tg_80.arn
  }
}