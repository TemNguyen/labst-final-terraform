variable "aws_region" {
  default = "ap-southeast-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/22"
}

variable "pri_subnets_cidr" {
  type = list
  default = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "pub_subnets_cidr" {
  type = list
  default = ["10.0.2.0/24", "10.0.3.0/24"]
}

variable "azs" {
  type = list
  default = ["ap-southeast-1a", "ap-southeast-1c"]
}

variable "amz2023_ami" {
  default = "ami-0db1894e055420bc0"
}

variable "ubuntu_ami" {
  default = "ami-0df7a207adb9748c7"
}

variable "ecs_ami" {
  default = "ami-003c37e0e7439d3ab"
}

variable "phpmyadmin_image" {
  default = "public.ecr.aws/docker/library/phpmyadmin:latest"
}

variable "wordpress_image" {
  default = "public.ecr.aws/bitnami/wordpress:latest"
}

variable "ghost_image" {
  default = "public.ecr.aws/docker/library/ghost:latest"
}