data "aws_ec2_managed_prefix_list" "st_network" {
  filter {
    name = "prefix-list-id"
    values = ["pl-07cc899f44baef5e5"]
  }
}

data "aws_key_pair" "ssh_keypair" {
  filter {
    name = "key-name"
    values = ["lab-st-thinhnguyen-ap-southeast-1"]
  }
}

data "aws_iam_role" "ecs_instance_role" {
  name = "ecsInstanceRole"
}

data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

data "aws_acm_certificate" "ssl" {
  domain = "final.lab-st-thinhnguyen.online"
  statuses = ["ISSUED"]
}

data "aws_route53_zone" "route53" {
  name = "lab-st-thinhnguyen.online."
  private_zone = false
}

data "aws_ami" "ecs_instance" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}