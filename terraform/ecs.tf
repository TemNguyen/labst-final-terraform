resource "aws_ecs_cluster" "tf_ecs_cluster" {
  name = "tf_ecs_cluster"
}

resource "aws_network_interface" "tf_ecs_ec2_eni" {
  subnet_id = aws_subnet.tf_pri_subnet[0].id
  security_groups = [aws_security_group.tf_ecs_sg.id]

  tags = {
    Name = "tf_ecs_ec2_eni"
  }
}

resource "aws_instance" "tf_ecs_ec2" {
  ami = var.ecs-ami
  instance_type = "t3.medium"
  key_name = data.aws_key_pair.ssh_keypair.key_name
  user_data = <<EOF
  #!/bin/bash
  echo ECS_CLUSTER=${aws_ecs_cluster.tf_ecs_cluster.name} >> /etc/ecs/ecs.config
  EOF

  network_interface {
    network_interface_id = aws_network_interface.tf_ecs_ec2_eni.id
    device_index = 0
  }

  iam_instance_profile = data.aws_iam_role.ecs_instance_role.name

  tags = {
    Name = "tf_ecs_ec2"
  }
}

resource "aws_ecs_task_definition" "tf_phpmyadmin" {
  family = "tf-phpmyadmin"
  requires_compatibilities = ["EC2"]

  runtime_platform {
   operating_system_family =  "LINUX"
   cpu_architecture = "X86_64"
  }

  network_mode = "host"
  cpu = 512
  memory = 1024
  task_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn

  container_definitions = <<DEFINITION
  [
    {
      "name": "phpmyadmin",
      "image": "${var.phpmyadmin-image}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80
        }
      ],
      "environment": [
        {
          "name": "PMA_HOST",
          "value": "${split(":", aws_db_instance.tf_rds.endpoint)[0]}"
        },
        {
          "name": "PMA_PORT",
          "value": "3306"
        }
      ]
    }
  ]
  DEFINITION
}

resource "aws_ecs_task_definition" "tf_wordpress" {
  family = "tf-wordpress"
  requires_compatibilities = ["EC2"]

  runtime_platform {
   operating_system_family =  "LINUX"
   cpu_architecture = "X86_64"
  }

  network_mode = "host"
  cpu = 512
  memory = 1024
  task_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn

  container_definitions = <<DEFINITION
  [
    {
      "name": "wordpress",
      "image": "${var.wordpress-image}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 8080,
          "hostPort": 8080
        },
        {
          "containerPort": 8443,
          "hostPort": 8443
        }
      ],
      "environment": [
        {
          "name": "WORDPRESS_DATABASE_HOST",
          "value": "${split(":", aws_db_instance.tf_rds.endpoint)[0]}"
        },
        {
          "name": "WORDPRESS_DATABASE_NAME",
          "value": "${aws_db_instance.tf_rds.db_name}"
        },
        {
          "name": "WORDPRESS_DATABASE_PORT_NUMBER",
          "value": "3306"
        },
        {
          "name": "WORDPRESS_DATABASE_USER",
          "value": "${aws_db_instance.tf_rds.username}"
        },
        {
          "name": "WORDPRESS_DATABASE_PASSWORD",
          "value": "${aws_db_instance.tf_rds.password}"
        }
      ]
    }
  ]
  DEFINITION
}

resource "aws_ecs_service" "phpmyadmin" {
  name = "phpmyadmin"
  cluster = aws_ecs_cluster.tf_ecs_cluster.id
  launch_type = "EC2"
  task_definition = aws_ecs_task_definition.tf_phpmyadmin.arn
  desired_count = 1

  load_balancer {
    target_group_arn = aws_lb_target_group.tf_tg_80.arn
    container_name = "phpmyadmin"
    container_port = 80
  }
}

resource "aws_ecs_service" "wordpress" {
  name = "wordpress"
  cluster = aws_ecs_cluster.tf_ecs_cluster.id
  launch_type = "EC2"
  task_definition = aws_ecs_task_definition.tf_wordpress.arn
  desired_count = 1

  load_balancer {
    target_group_arn = aws_lb_target_group.tf_tg_8080.arn
    container_name = "wordpress"
    container_port = 8080
  }
}